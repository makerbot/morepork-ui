// Copyright 2017 Makerbot Industries

#ifndef _SRC_LOCAL_JSONRPC_H
#define _SRC_LOCAL_JSONRPC_H

#include <memory>

#include <QObject>
#include <QLocalSocket>
#include <QFileSystemWatcher>
#include <QFileInfo>
#include <QDir>
#include <jsonrpc/jsonrpc.h>

/// Connect to a local unix domain socket and attach a jsonrpc
/// object to that object.
class LocalJsonRpc : public QObject {
    Q_OBJECT
  public:
    /// Constructor to immediately start connecting to a socket
    LocalJsonRpc(const char * socket_path);

    /// The jsonrpc object that will (eventually) be connected to the socket
    /// Invokations while we are not connected are silently dropped.
    JsonRpc jsonrpc;

  signals:
    /// This event is fired whenever the socket controlled by this class
    /// connects to its defined endpoint.
    void connected();

    /// This event is fired whenever the socket controlled by this class
    /// disconnects from its defined endpoint.
    void disconnected();

    // This event is fired when too much time has passed since initialization
    // without having connected to the socket.  Connection may still occur.
    // This is explicitly only for the initial connection attempt.
    void timeout();

  private:
    void checkConnect();
    void initialTimeout();
    void sockConnected();
    void readyRead();
    void sockDisconnected();
    void stateChanged(QLocalSocket::LocalSocketState);
    void directoryChanged(const QString &);

    QFileInfo m_socketPath;
    QDir m_watchPath;
    QScopedPointer<QFileSystemWatcher, QScopedPointerDeleteLater> m_watcher;
    QScopedPointer<QLocalSocket, QScopedPointerDeleteLater> m_socket;

    class Output;
    std::shared_ptr<Output> m_output;
    class DummyOutput;
    std::shared_ptr<DummyOutput> m_dummyOutput;
    bool m_doTimeout;
};

#endif  // _SRC_LOCAL_JSONRPC_H
