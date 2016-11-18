import json

# Set a maximum length for json packets, since our parsing method
# requires us to keep the entire packet in memory.
MAX_PACKET = 8192

def decode(b):
    """
    A utf-8 decoder that works on bytes, bytearrays, and memoryviews thereof.
    """
    return str(b, encoding='utf-8')

class JsonReader(object):
    '''
    A JSON reader that can incrementally parse continuous streams of JSON
    objects or arrays from utf-8 encoded bytes. JavaScript comments are not
    supported.

    The reader invokes callback when it detects the end of a top-level
    JSON object or array.  The callback is passed a de-serialized output,
    unless loads is set to False, in which case it is passed a string.

    If callback raises an exception feed will raise the same exception.
    The reader will be in its initial state with an empty buffer.
    '''

    def __init__(self, callback, loads=True):
        self._callback = callback
        self._loads = loads
        self._reset()

    def _reset(self):
        """
        Resets the json reader to its original state
        """
        self._curly_count = 0
        self._square_count = 0
        self._buffer = ''
        self._quoted = False
        self._escaped = False

    def _consume(self, data):
        """
        State machine that handles grabbing the first complete packet of json.
        We support both dict and array packets.  The state machine operates by
        counting braces; once both counts reach 0, we execute the callback function,
        passing the complete packet in.
        """
        # These keep track of the current string we are evaluating.  String
        # concatentations in python are fairly expensive, so we try to limit
        # the number of concatentations.
        start = 0
        end = 0
        for ch in data:
            # We parse json by counting the number of braces
            check = False
            if self._quoted:
                if not self._escaped and ch == ord('"'):
                    self._quoted = False
                self._escaped = ch == ord('\\') and not self._escaped
            elif ch == ord('"'):
                self._quoted = True
            elif ch == ord('{'):
                self._curly_count += 1
            elif ch == ord('}'):
                self._curly_count -= 1
                check = True
            elif ch == ord('['):
                self._square_count += 1
            elif ch == ord(']'):
                self._square_count -= 1
                check = True
            end += 1
            if check and self._curly_count == 0 and self._square_count == 0:
                udata = decode(data[start:end])
                if len(self._buffer) != 0:
                    self._send(self._buffer + udata)
                    self._buffer = ''
                else:
                    self._send(udata)
                yield end
                # If we send a packet, lets start parsing the next substring
                start = end
        # If we are left with an incomplete packet, we add it to the buffer
        if start != end:
            if len(self._buffer) + end - start > MAX_PACKET:
                raise IOError(7, 'JSON packet overflow') # 7 == E2BIG
            self._buffer += decode(data[start:])

    def _send(self, data):
        '''
        Invokes the callback, sending it the JSON text for the current
        top-level object or array.  Only invoked with a real JSON object.

        Any values yielded by the callback are ignored, and value is yielded
        instead.  Always yields once before terminating.
        '''
        if self._loads:
            data = json.loads(data)
        self._callback(data)

    def feed(self, data):
        ''' Feed data to the reader.'''
        try:
            for index in self._consume(data):
                pass
        except:
            self._reset()
            raise

    def feed_iter(self, data):
        '''
        An iterator to feed data to the reader.  Each iteration occurs at
        the end of a packet, and yields the index in data of the character
        directly following the packet.  This iterator must be completed or
        closed before another call to feed_iter or feed.
        '''
        try:
            yield from self._consume(data)
        except:
            self._reset()
            raise
