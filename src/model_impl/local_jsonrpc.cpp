// Copyright 2017 Makerbot Industries

#include "local_jsonrpc.h"

#include <QTimer>

#include <jsonrpc/jsonrpcoutputstream.h>

class LocalJsonRpc::Output : public JsonRpcOutputStream {
  public:
    explicit Output(QLocalSocket* socket) : m_socket(socket) {}
    void send(const char * buf, size_t length) {
        // TODO: Figure out if this can raise if we call this in between
        //       a socket disconnecting and handling the disconnect signal.
        m_socket->write(buf, length);
    }
  private:
    // Owned by the LocalJsonRpc that also owns us.
    QLocalSocket* m_socket;
};

class LocalJsonRpc::DummyOutput : public JsonRpcOutputStream {
  public:
    void send(const char * buf, size_t length) {}
};

LocalJsonRpc::LocalJsonRpc(const char * socket_path) :
        jsonrpc(),
        m_socketPath(socket_path),
        m_watchPath(m_socketPath.dir()),
        m_watcher(new QFileSystemWatcher()),
        m_socket(new QLocalSocket()),
        m_output(new Output(m_socket.data())),
        m_dummyOutput(new DummyOutput()),
        m_doTimeout(true) {

    auto socket = m_socket.data();
    connect(socket, &QLocalSocket::connected,
            this, &LocalJsonRpc::sockConnected);
    connect(socket, &QLocalSocket::readyRead,
            this, &LocalJsonRpc::readyRead);
    connect(socket, &QLocalSocket::disconnected,
            this, &LocalJsonRpc::sockDisconnected);
    connect(socket, &QLocalSocket::stateChanged,
            this, &LocalJsonRpc::stateChanged);

    auto watcher = m_watcher.data();
    connect(watcher, &QFileSystemWatcher::directoryChanged,
            this, &LocalJsonRpc::directoryChanged);

    QTimer::singleShot(30000, this, &LocalJsonRpc::initialTimeout);
    checkConnect();
}

/// If the socket exists and we are in an unconnected state, start the
/// connection process.
void LocalJsonRpc::checkConnect() {
    // Return if the socket path does not exist, and try to make sure that
    // we are watching its containing directory iff it does not exist (but
    // be absolutely sure that we cannot return early here when we are not
    // watching the directory).
    if (m_socketPath.exists()) {
        if (!m_watcher->directories().empty()) {
            m_watcher->removePath(m_watchPath.path());
        }
    } else {
        if (!m_watcher->directories().empty()) return;
        m_watcher->addPath(m_watchPath.path());
        if (!m_socketPath.exists()) return;
        m_watcher->removePath(m_watchPath.path());
    }

    if (m_socket->state() == QLocalSocket::UnconnectedState)
        m_socket->connectToServer(m_socketPath.filePath());
}

void LocalJsonRpc::initialTimeout() {
    if (m_doTimeout) emit timeout();
}

void LocalJsonRpc::sockConnected() {
    jsonrpc.setOutputStream(m_output);
    m_doTimeout = false;
    emit connected();
}

void LocalJsonRpc::readyRead() {
    auto data = m_socket->readAll();
    jsonrpc.feedInput(data.data(), data.size());
}

void LocalJsonRpc::sockDisconnected() {
    jsonrpc.setOutputStream(m_dummyOutput);
    emit disconnected();
}

void LocalJsonRpc::stateChanged(QLocalSocket::LocalSocketState state) {
    if (state == QLocalSocket::UnconnectedState)
        // We NEED to defer this call because this signal can be
        // directly invoked from checkConnect().  This is really
        // only here as a convenience for developers anyway...
        QTimer::singleShot(500, this, &LocalJsonRpc::checkConnect);
}

void LocalJsonRpc::directoryChanged(const QString &) {
    checkConnect();
}
