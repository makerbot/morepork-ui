// Copyright 2017 Makerbot Industries

#ifndef _SRC_NETWORK_H
#define _SRC_NETWORK_H

#include <memory>
#include <QNetworkAccessManager>

class QNetworkReply;

// workaround for XMLHttpRequest not working on the bot -- perhaps once the SSL
// error is fixed, it will work and we won't need this class...
class Network : public QObject {
  Q_OBJECT

  public:
    Network(QNetworkAccessManager * nam);
    Q_INVOKABLE void GetMakerBotToken(QString username, QString password);
  signals:
    void GetMakerBotTokenFinished(QString token);
    void GetMakerBotTokenFailed();

  private:
    void HandleMakerBotTokenResponse();
    void HandleSSLError(const QList<QSslError> &errors);

    QNetworkAccessManager * m_nam;
    QNetworkReply * m_reply;
    bool m_requestPending;
};

#endif  // SRC_NETWORK_H
