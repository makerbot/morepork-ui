// Copyright 2017 Makerbot Industries

#include "local_jsonrpc.h"

#include <iostream>

#include <jsonrpc/jsonrpcoutputstream.h>

class LocalJsonRpc::Output : public JsonRpcOutputStream {
  public:
    explicit Output(QLocalSocket* socket) : m_socket(socket) {}
    void send(const char * buf, size_t length) {
        m_socket->write(buf, length);
    }
  private:
    // Owned by the LocalJsonRpc that also owns us.
    QLocalSocket* m_socket;
};

LocalJsonRpc::LocalJsonRpc(const char * socket_path) :
        jsonrpc(),
        m_socket(),
        m_output(std::make_shared<Output>(&m_socket)) {
    connect(&m_socket, &QLocalSocket::connected, [this](){
        jsonrpc.setOutputStream(m_output);
        emit connected();
    });
    connect(&m_socket, &QLocalSocket::readyRead, [this](){
        auto data = m_socket.readAll();
        jsonrpc.feedInput(data.data(), data.size());
    });
    connect(&m_socket, &QLocalSocket::disconnected, [this](){
        emit disconnected();
    });
    // TODO: retry loop for connecting to kaiten?
    m_socket.connectToServer(socket_path);
}
