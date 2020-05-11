// Copyright 2017 Makerbot Industries

#ifndef _SRC_NETWORK_H
#define _SRC_NETWORK_H

#include <memory>
#include <QNetworkAccessManager>
#include <QJsonDocument>

class QNetworkReply;

/*
This class manages two ways of authorizing a printer to a MakerBot account.
1.) Using username & password
2.) Using one time password
Either way the goal is to retrieve a user's oauth token and pass it to Kaiten.
*/
class Network : public QObject {
  Q_OBJECT

  public:
    Network(QNetworkAccessManager * nam);

    /*
    Authorize with credentials
    Directly get oauth token from the web service using username and password.
    */
    Q_INVOKABLE void authenticateWithCredentials(QString username, QString password);

    /*
    Authorize with code
    Initial setup call to fetch one time password to display on the printer which
    users will then input into MB Website/Teams/Print etc.
    */
    Q_INVOKABLE void initiateAuthWithCode(QString printer_id, QString printer_name,
                                       QString printer_type, QString printer_ip);
    /*
    Authorize with code
    Called periodically after initial setup to check for authorization, whether
    someone used the one time password and associated this printer with their MB
    account. If so, the user's oauth token is returned by the web service to this
    call.
    */
    Q_INVOKABLE void checkAuthWithCode(QString otp, QString polling_token);

  signals:
    void AuthWithCredentialsSucceeded(QString token);
    void AuthWithCredentialsFailed();

    void InitiateAuthWithCodeSucceeded(QString otp, QString polling_token);
    void InitiateAuthWithCodeFailed();
    void CheckAuthWithCodeSucceeded(QString username, QString oauth_token);

  public slots:
    void handleRespAuthWithCredentials();

    void handleRespInitiateAuthWithCode();
    void handleRespCheckAuthWithCode();

    void handleSSLErrors(QNetworkReply *reply, const QList<QSslError> &errors);

  private:
    QNetworkAccessManager * m_nam;
    QNetworkReply * m_reply;
};

#endif  // SRC_NETWORK_H
