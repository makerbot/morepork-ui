#!/usr/bin/python3.4

# This file is a huge pain because both tkinter and asyncio need to run
# their own event loops, and they are each very particular about what
# thread things happen in.  So we have an Application object for tkinter
# events and a Server object for asyncio events.

import asyncio
import logging
import json
import os

from . import jsonrpc

LISTEN_PATH = '/tmp/kaiten.socket'

def init_logging():
    LOG_PATH = '/home/logs/auther.log'
    import logging.handlers
    formatter = logging.Formatter(
        '%(process)05d:%(asctime)s:%(levelname)s:'+
        '%(funcName)s:%(lineno)d: %(message)s'
    )
    handler = logging.handlers.RotatingFileHandler(
        LOG_PATH, maxBytes=1024*1024, backupCount=3,
    )
    handler.setFormatter(formatter)
    logging.basicConfig(
        handlers = [handler],
        level = logging.DEBUG,
    )


class Auther(object):
    """ Handles our connection to the kaiten """
    def __init__(self):
        self._log = logging.getLogger('Auther')
        self._server = None
        self._loop = asyncio.get_event_loop()

        def pf():
            return jsonrpc.JsonRpc(self._open_cb, self._close_cb)
        conn = self._loop.create_unix_connection(pf, LISTEN_PATH)
        self._loop.create_task(conn)

        self._log.info('Auther initialized')

    def _open_cb(self, server):
        """
        Invoked when we sucessfully connect to the server
        """
        self._server = server
        jsonrpc.install(server, self)
        self._loop.call_soon(self.request, 'register_lcd', {})
        self._log.info('Connected to kaiten')

    def _close_cb(self, server):
        """
        Invoked if our server connection gets dropped
        """
        self._server = None
        self._log.warning('Lost kaiten connection')

    def request(self, method, params, callback=None):
        # Invokable from any thread
        if callback is None:
            callback = lambda *a: None
        self._loop.call_soon_threadsafe(
            self._server.request, method, params, callback)

    def notify(self, method, params):
        # Invokable from any thread
        self._loop.call_soon_threadsafe(
            self._server.notify, method, params)

    def run(self):
        self._loop.run_forever()

    def stop(self):
        # Invokable from any thread
        self._loop.call_soon_threadsafe(self._loop.stop)

    @jsonrpc.jsonrpc
    def authorize_user(self, username):
        self._log.info('Authed user %s', username)
        return {'answer': 'accepted'}

    @jsonrpc.jsonrpc
    def allow_unknown_firmware(self):
        self._log.info('Allowing unsigned firmware')
        return 'allow'


if __name__ == '__main__':
    init_logging()
    auther = Auther()
    auther.run()
