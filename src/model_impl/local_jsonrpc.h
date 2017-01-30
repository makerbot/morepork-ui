// Copyright 2017 Makerbot Industries

#ifndef _SRC_LOCAL_JSONRPC_H
#define _SRC_LOCAL_JSONRPC_H

#include <memory>

#include <QObject>
#include <QLocalSocket>
#include <jsonrpc/jsonrpc.h>

/// Connect to a local unix domain socket and attach a jsonrpc
/// object to that object.
class LocalJsonRpc : public QObject {
    Q_OBJECT
  public:
    /// Constructor to immediately start connecting to a socket
    LocalJsonRpc(const char * socket_path);

    /// The jsonrpc object that will (eventually) be connected to the socket
    /// Calling invoke on this object will raise an exception if connected()
    /// has not yet been fired or if the socket has been disconnected, which
    /// may occur before we fire our disconnected event.
    // TODO: Fix this terrible race condition.
    JsonRpc jsonrpc;

  signals:
    /// This event is fired whenever the socket controlled by this class
    /// connects to its defined endpoint.
    void connected();

    /// This event is fired whenever the socket controlled by this class
    /// disconnects from its defined endpovoid.
    void disconnected();

    // This event is fired whenever the socket connect loop exceeds its
    // retry count when attempting to connect.
    void timeout();

  private:
    QLocalSocket m_socket;
    class Output;
    std::shared_ptr<Output> m_output;
};

#endif  // _SRC_LOCAL_JSONRPC_H
