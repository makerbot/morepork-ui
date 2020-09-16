import asyncio
import contextlib
import errno
import json
import logging
import io
import os
import socket
import sys
import types

from . import json_reader

def jsonrpc(func):
    func._jsonrpc = True
    immediate = getattr(func, '_jsonrpc_immediate', False)
    if immediate or asyncio.iscoroutinefunction(func):
        return func
    else:
        return asyncio.coroutine(func)

def immediate(func):
    if getattr(func, '_jsonrpc', False):
        raise RuntimeError('@jsonrpc.immediate must be below @jsonrpc.jsonrpc')
    elif asyncio.iscoroutinefunction(func):
        raise RuntimeError('@jsonrpc.immediate cannot handle coroutines')
    func._jsonrpc_immediate = True
    return func

def pass_callback(func):
    func._jsonrpc_callback = True
    return func

def pass_client(func):
    func._jsonrpc_client = True
    return func

def install(jsonrpc, obj):
    """
    Installs all callable components of obj that have been decorated with
    this module.  We have intentionally avoided inspect here
    for performance reasons.

    We allow both normal functions and generator functions, though some
    modifier decorators (pass_callback, jsonrpc_immediate) do not
    support generators and will raise a runtime error when a generator
    they decorate is invoked.
    """
    for attribute_name in dir(obj):
        attr = getattr(obj, attribute_name)
        # If it quacks like a function...
        if hasattr(attr, '__call__') and getattr(attr, '_jsonrpc', False):
            exported_name = attribute_name
            jsonrpc.addmethod(attribute_name, attr)

class JsonRpcException(Exception):
    def __init__(self, code, message, data=None):
        Exception.__init__(self, code, message)
        self.code = code
        self.message = message
        self.data = data

    def __str__(self):
        return "Code: %s, Message: %s, Data: %s"%(self.code, self.message,
            self.data)

def exc_to_error(e):
    """
    When running a pass_callback method and a JsonRpcException e is raised,
    call callback(error=jsonrpc.exc_to_error(e))
    """
    error = { 'code': e.code, 'message': e.message }
    if None is not e.data:
        error['data'] = e.data
    return error

class JsonRpc(asyncio.Protocol):
    """ JsonRpc handles a json stream, to guarantee the output file pointer
    gets entire valid JSON blocks of data to process, by buffering up data
    into complete blocks and only passing on entire JSON blocks
    """
    def __init__(self, open_cb, close_cb):
        """
        @param open_cb: Invoked when the connection is opened
        @param close_cb: Invoked when the connection is closed
        """
        self._log = logging.getLogger('JsonRpc')
        self._open_cb = open_cb
        self._close_cb = close_cb
        self._jsonreader = json_reader.JsonReader(self._jsonreaderresp, False)
        self._methods = {}
        self._jobs = {}
        self._id_counter = 0
        self._transport = None
        self._raw_handler = None

    def connection_made(self, transport):
        self._transport = transport
        self._open_cb(self)

    def connection_lost(self, exc):
        self._log.info('Lost connection: %s', exc)
        self._close_cb(self)
        self._transport = None

    #
    # Common part
    #

    def _get_id(self):
        new_id = self._id_counter
        self._id_counter += 1
        return new_id

    def _jsonreaderresp(self, indata):
        """
        Fired off when a complete jsonrpc packet is parsed by the json reader.
        The json blob is marshalled into a python data type and queued for execution
        depending on its structure:
            dict:
                hasID-> handled as request.  The result is sent back to the caller
                noID-> handled as notification.  No result is sent back to the
                    caller (even in the case of an error
            array:
                iterated over.  Aggregate of results (if components are requests)
                    are stored and sent back to the caller
        The different "handle" function calls return dicts for their response.
        Typically requests are queued for later execution, so the response is
        None.  But parsing errors or "immediate" requests return a dict, which
        is then queued for sending.
        """
        try:
            parsed = json.loads(indata)
        except ValueError:
            response = self._parse_error()
        else:
            if isinstance(parsed, dict):
                # This is checked here and not in handle_object, since arrays
                # are not supposed to have responses in them and we DONT want
                # to support that.
                if self._is_response(parsed):
                    self._handle_response(parsed)
                    # We return here, since theres no more work to be done
                    return
                else:
                    response = self._handle_object(parsed)
            else:
                response = self._invalid_request(None)
        if None is not response:
            #self._log.debug('response=%r', response)
            outdata = json.dumps(response)
            self._send(outdata)

    def _handle_object(self, parsed):
        """
        Handles a parsed object.  Depending on the contents of the parsed dict,
        it will either invoke it as a notification or as a request.  Depending
        on the method, this will either directly execute the function or queue
        it for later execution.
        """
        # We check is parsed is a dict again here to support _handle_array
        if not isinstance(parsed, dict):
            return self._invalid_request(None)
        else:
            is_request = self._is_request(parsed)
            is_notification = self._is_notification(parsed)
            if is_request or is_notification:
                method = parsed["method"]
                if method in self._methods:
                    func = self._methods[method]
                    if is_request:
                        self._handle_request(parsed)
                    else:
                        self._handle_notification(parsed)
                elif is_request:
                    return self._method_not_found(parsed.get("id"))
            else:
                return self._invalid_request(parsed.get("id"))

    def _handle_response(self, parsed):
        """
        Handles a response.  We assume the parsed blob is correctly formatted.
        We fire off the callback passed in during the self.request call.  We
        support both generators and function calls.
        """
        #self._log.debug("Handling response %r", parsed)
        if parsed['id'] in self._jobs:
            response_blob = {}
            if 'error' in parsed:
                response_blob['error'] = parsed['error']
            else:
                response_blob['result'] = parsed['result']
            coro = self._jobs[parsed['id']](response_blob)
            asyncio.ensure_future(coro)
            self._jobs.pop(parsed['id'])
        else:
            pass #self._log.debug("Response not in jobs dict: %r", parsed)

    def _is_request(self, parsed):
        """
        Determines if this dict is a request.  Requests have an ID field, and
        are expected to return some sort of result.
        """
        result = (
            'jsonrpc' in parsed
            and '2.0' == parsed['jsonrpc']
            and 'method' in parsed
            and isinstance(parsed['method'], str)
            and 'id' in parsed)
        return result

    def _is_notification(self, parsed):
        """
        Determines if this dict is a notification. Notifications are the same
        as requests, except that they do not have an 'ID' field
        """
        result = (
            'jsonrpc' in parsed
            and '2.0' == parsed['jsonrpc']
            and 'method' in parsed
            and isinstance(parsed['method'], str)
            and 'id' not in parsed)
        return result

    def _is_response(self, parsed):
        """
        Determines if this dict is a response to a previously sent message.
        """
        result = (self._is_success_response(parsed)
            or self._is_error_response(parsed))
        return result

    def _is_success_response(self, parsed):
        """
        Success responses have a result and no error, and the ID of the calling
        RPC
        """
        result = (
            'jsonrpc' in parsed and parsed['jsonrpc'] == "2.0" and 'id' in parsed
            and 'error' not in parsed and 'result' in parsed)
        return result

    def _is_error_response(self, parsed):
        """
        Error responses have an error and no result, and the ID of the calling
        RPC
        """
        result = (
            'jsonrpc' in parsed and parsed['jsonrpc'] == "2.0" and 'id' in parsed
            and 'error' in parsed and 'result' not in parsed)
        return result

    def _success_response(self, id, result):
        response = {'jsonrpc': '2.0', 'result': result, 'id': id}
        return response

    def _errorresponse(self, id, code, message, data=None):
        error = {'code': code, 'message': message}
        if None is not data:
            error['data'] = data
        response = {'jsonrpc': '2.0', 'error': error, 'id': id}
        return response

    def _parse_error(self):
        response = self._errorresponse(None, -32700, 'parse error')
        return response

    def _invalid_request(self, id):
        response = self._errorresponse(id, -32600, 'invalid request')
        return response

    def _method_not_found(self, id):
        response = self._errorresponse(id, -32601, 'method not found')
        return response

    def _invalid_params(self, id):
        response = self._errorresponse(id, -32602, 'invalid params')
        return response

    def _send(self, data, extra=None):
        data = bytes(data, 'utf-8')
        if None is not extra:
            self._transport.writelines((data, extra))
        else:
            self._transport.write(data)

    def data_received(self, data):
        try:
            self._feed(data)
        except Exception:
            self._log.error('Stream error', exc_info=True)

    def _feed(self, data):
        """
        Feed a chunk of data to either to the main json parser or a custom raw
        data parser.  Every time the json parser yields we check if there is a
        custom parser; the custom parser is done as soon as it yields data.
        """
        while data:
            if None is self._raw_handler:
                for index in self._jsonreader.feed_iter(data):
                    if None is not self._raw_handler:
                        data = data[index:]
                        break
                else:
                    return
            else:
                try:
                    data = self._raw_handler.send(data)
                    if data:
                        self._raw_handler.close()
                        self._raw_handler = None
                except StopIteration:
                    self._raw_handler = None
                    return

    def close(self):
        try:
            self.connection.close()
        except Exception as e:
            pass #self._log.debug('handled exception', exc_info=True)

    #
    # Client part
    #

    def notify(self, method, params, extra=None):
        """
        Sends a notification to a connected client.

        @param method: The method to be called on the client
        @param params: A dict of parameters (param arrays are discouraged)
        @param extra: This can contain an extra byte array which will be sent
            directly over the connection immediately after the notification.
        """
        #self._log.debug('method=%r, params=%r', method, params)
        request = {'jsonrpc': '2.0', 'method': method, 'params': params}
        data = json.dumps(request)
        self._send(data, extra)

    def request(self, method, params, result_callback, extra=None):
        """
        Sends a request to a connected client.

        @param method: The method to be called on the client
        @param params: A dict of parameters (param arrays are discouraged)
        @param request_callback: Invoked if and when the client responds with
            the full response dict as a single argument.  The callback can also
            be a coroutine.
        @param extra: This can contain an extra byte array which will be sent
            directly over the connection immediately after the request.
        """
        #self._log.debug("method=%r, params=%r", method, params)
        _id = self._get_id()
        request = {'jsonrpc': '2.0', 'method': method, 'params': params, 'id': _id}
        data = json.dumps(request)
        if not asyncio.iscoroutinefunction(result_callback):
            result_callback = asyncio.coroutine(result_callback)
        self._jobs[_id] = result_callback
        self._send(data, extra)

    def set_raw_handler(self, generator):
        """
        Replace the json packet parser with a custom generator.  This can only
        be called safely when the other end of this connection is blocked from
        sending anything until it receives something from us.
        @param generator: This is fed the incoming data with .send().  Once it
            has received all of the data it needs, it must stop iteration.
            If it instead receives more data than it requires, it must yield
            back the extra data, at which point it will be closed.
        """
        self._raw_handler = generator
        next(self._raw_handler)

    #
    # Server part
    #

    def _get_args_kwargs(self, json_blob):
        """
        Gets the correct args and kwargs from the json_blob and returns them
        """
        if "params" not in json_blob:
            return ((), {})
        elif json_blob['params'] is None:
            return ((), {})
        elif isinstance(json_blob["params"], dict):
            params = json_blob["params"].copy()
            return ((), params)
        elif isinstance(json_blob["params"], list):
            return (json_blob["params"], {})
        else:
            raise AttributeError

    def _handle_notification(self, notification):
        """
        Processes a notification.  Assumes the packet is valid.
        Since its a notification, we catch all errors and do nothing
        with them.  We support generator methods, so this function is
        itself a generator.
        """
        #self._log.debug("notification=%r" % (notification))
        method = notification['method']
        func = None

        @contextlib.contextmanager
        def guard():
            try:
                yield
            except Exception as e:
                self._log.error("Error executing notification %r",
                                notification, exc_info=True)
        with guard():
            (args, kwargs) = self._get_args_kwargs(notification)
            func = self._methods[method]
        if func:
            self._invoke_method(func, args, kwargs, guard)

    def _handle_request(self, request):
        """
        Handles a request.  Assumes the packet is valid and the method exists.
        Since its a request, we need to handle each error case and return an
        error packet.
        """
        _id = request["id"]
        #self._log.debug('request=%r, id=%r', request, _id)
        method = request['method']
        try:
            (args, kwargs) = self._get_args_kwargs(request)
        except AttributeError as e:
            self._log.error('handled exception', exc_info=True)
            self._send(json.dumps(self._invalid_params(_id)))
        func = self._methods[method]

        @contextlib.contextmanager
        def guard():
            response = None
            try:
                yield
            except TypeError as e:
                self._log.error('handled exception: ' + str(e), exc_info=True)
                response = self._invalid_params(_id)
            except JsonRpcException as e:
                self._log.warning('handled exception', exc_info=True)
                response = self._errorresponse(_id, e.code, e.message, e.data)
            except Exception as e:
                self._log.warning('uncaught exception', exc_info=True)
                e = sys.exc_info()[1]
                data = {'name': e.__class__.__name__, 'args': e.args}
                response = self._errorresponse(
                    _id, -32000, 'uncaught exception', data)
            if response:
                self._send(json.dumps(response))

        def callback(result):
            response = self._success_response(_id, result)
            #self._log.debug('response=%r', result)
            self._send(json.dumps(response))

        if getattr(func, '_jsonrpc_callback', False):
            self._invoke_callback_method(_id, func, args, kwargs)
        else:
            self._invoke_method(func, args, kwargs, guard, callback)

    def _fix_kwargs(self, kwargs):
        kwargs1 = {}
        for k, v in kwargs.items():
            k = str(k)
            kwargs1[k] = v
        return kwargs1

    def _invoke_method(self, func, args, kwargs, guard, callback=None):
        """
        Invokes a method under the context of a given guard
        """
        def task_callback(task):
            with guard():
                result = task.result()
                if callback:
                    callback(result)
        if getattr(func, '_jsonrpc_client', False):
            kwargs['client'] = self
        with guard():
            kwargs = self._fix_kwargs(kwargs)
            result = func(*args, **kwargs)
            if asyncio.iscoroutine(result):
                task = asyncio.ensure_future(result)
                task.add_done_callback(task_callback)

    def _invoke_callback_method(self, _id, func, args, kwargs, guard):
        """
        Invokes a method which will not return a result immediately, but will
        invoke a callback when the result is ready
        """
        def request_callback(result=None, error=None, **kwargs):
            """
            Add generic kwargs that are ignored so that jsonrpc responses can be
            passed straight through with callback(**response)
            """
            try:
                if None is not error:
                    response = self._errorresponse(_id, **error)
                else:
                    response = self._success_response(_id, result)
            except Exception as e:
                self._log.error('Error in request callback', exc_info=True)
                response = self._errorresponse(_id, -32603, 'internal error')
            outdata = json.dumps(response)
            self._queue_callback(self._send(outdata))
        kwargs['callback'] = request_callback
        self._invoke_method(func, args, kwargs, guard)

    def addmethod(self, method, func):
        #self._log.debug('method=%r, func=%r', method, func)
        self._methods[method] = func

    def getmethods(self):
        return self._methods
