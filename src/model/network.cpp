#include <QNetworkReply>

#include "network.h"
#include "logging.h"

Network::Network(QNetworkAccessManager * nam)
    : m_nam(nam),
      m_reply(nullptr) {
    // SSL errors for all request from this network manager will
    // be handled by this function.
    connect(m_nam, &QNetworkAccessManager::sslErrors,
            this, &Network::handleSSLErrors);
}

void Network::authenticateWithCredentials(QString username, QString password) {
    if (m_reply) {
        LOG(info) << "Busy handling an existing network request";
        emit AuthWithCredentialsFailed();
        return;
    }

    // TODO(shirley): move these to a config
    QNetworkRequest req(QStringLiteral(
            "https://www.thingiverse.com/login/oauth/access_token"));
    req.setHeader(
            QNetworkRequest::ContentTypeHeader,
            QStringLiteral("application/x-www-form-urlencoded"));

    QString data(
            "client_id=682cb30bf432d934dee3&"
            "client_secret=76bd0530229cc606949811c7c438a698&"
            "username=%1"
            "&password=%2"
            "&grant_type=password");

    // Url encode username and password
    username = QUrl::toPercentEncoding(username).constData();
    password = QUrl::toPercentEncoding(password).constData();

    m_reply = m_nam->post(req, data.arg(username, password).toUtf8());

    connect(
        m_reply,
        &QNetworkReply::finished,
        this,
        &Network::handleRespAuthWithCredentials);
}

void Network::handleRespAuthWithCredentials() {
    if (m_reply->error()) {
        LOG(info) << "Network error " << m_reply->error() << ": "
                  << m_reply->errorString().toStdString().c_str();
        emit AuthWithCredentialsFailed();
        m_reply->deleteLater();
        m_reply = nullptr;
        return;
    }

    // expect response that looks like this:
    // `access_token=(token)&token_type=Bearer`
    QString res(QString::fromUtf8(m_reply->readAll()));
    QStringList l = res.split("&");
    if (l.size() == 2) {
        l = l[0].split("=");
        if (l.size() == 2) {
            emit AuthWithCredentialsSucceeded(l[1]);

            m_reply->deleteLater();
            m_reply = nullptr;
            return;
        }
    }

    LOG(info) << "Got unexpected response: " << res.toStdString().c_str();
    emit AuthWithCredentialsFailed();

    m_reply->deleteLater();
    m_reply = nullptr;
}

void Network::initiateAuthWithCode(QString printer_id,
                                   QString printer_name,
                                   QString printer_type,
                                   QString printer_ip) {
    QNetworkRequest request;
    request.setUrl(QUrl("https://cloudauth.mbot.me/session"));
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      QString("application/json"));

    QVariantMap data;
    data["name"] = printer_name;
    data["type"] = printer_type;
    data["ip"] = printer_ip;
    data["id"] = printer_id;

    m_reply = m_nam->post(request, QJsonDocument::fromVariant(data).toJson());

    connect(m_reply, &QNetworkReply::finished,
            this, &Network::handleRespInitiateAuthWithCode);
}

void Network::handleRespInitiateAuthWithCode() {
    if (m_reply->error() != QNetworkReply::NoError) {
        emit InitiateAuthWithCodeFailed();
        qWarning() << "Error No: " << m_reply->error() << "for url: " << m_reply->url().toString();
        qWarning() << "Request failed, " << m_reply->errorString();
        qWarning() << "Headers: " <<  m_reply->rawHeaderList() << "content: " << m_reply->readAll();
        m_reply->deleteLater();
        m_reply = nullptr;
        return;
    }

    QString data = m_reply->readAll();
    QJsonDocument json_resp = QJsonDocument::fromJson(data.toUtf8());
    if (!json_resp.isNull() && json_resp.isObject()) {
        QString otp = json_resp["oneTimePassword"].toString();
        QString polling_token = json_resp["pollingToken"].toString();
        emit InitiateAuthWithCodeSucceeded(otp, polling_token);
        m_reply->deleteLater();
        m_reply = nullptr;
        return;
    }

    emit InitiateAuthWithCodeFailed();
}

void Network::checkAuthWithCode(QString otp, QString polling_token) {
    QNetworkRequest request;
    request.setUrl(QUrl("https://cloudauth.mbot.me/session/" + otp));
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      QString("application/json"));
    request.setRawHeader(QByteArray("Authorization"),
                         QByteArray(QString("Bearer " + polling_token).toUtf8()));

    m_reply = m_nam->get(request);

    connect(m_reply, &QNetworkReply::finished,
            this, &Network::handleRespCheckAuthWithCode);
}

void Network::handleRespCheckAuthWithCode() {
    if (m_reply->error() != QNetworkReply::NoError ) {
        qWarning() << "Error No: " << m_reply->error() << "for url: " << m_reply->url().toString();
        qWarning() << "Request failed, " << m_reply->errorString();
        qWarning() << "Headers: " <<  m_reply->rawHeaderList() << "content: " << m_reply->readAll();
        m_reply->deleteLater();
        m_reply = nullptr;
        return;
    }

    QString data = m_reply->readAll();
    QJsonDocument json_resp = QJsonDocument::fromJson(data.toUtf8());
    if (!json_resp.isNull() && json_resp.isObject()) {
        if(json_resp["authed"].toBool()) {
            QString username = json_resp["username"].toString();
            QString oauth_token = json_resp["oauthToken"].toString();
            emit CheckAuthWithCodeSucceeded(username, oauth_token);
        }
    }
    m_reply->deleteLater();
    m_reply = nullptr;
}

void Network::handleSSLErrors(QNetworkReply *reply, const QList<QSslError> &errors) {
    for (const QSslError & err : errors) {
        LOG(info) << "SSL Error " << err.error() << ": "
                  << err.errorString().toStdString().c_str();
    }
    LOG(info) << "Ignoring SSL errors";
    reply->ignoreSslErrors();
}
