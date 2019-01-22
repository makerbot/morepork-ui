#include <QNetworkReply>

#include "network.h"
#include "logging.h"

Network::Network(QNetworkAccessManager * nam)
    : m_nam(nam),
      m_reply(nullptr) {}

void Network::GetMakerBotToken(QString username, QString password) {
    if (m_reply) {
        LOG(info) << "Busy handling an existing network request";
        emit GetMakerBotTokenFailed();
        return;
    }

    // TODO(shirley): move these to a config
    QNetworkRequest req(QStringLiteral(
            "https://staging.thingiverse.com/login/oauth/access_token"));
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
    username = QUrl::toPercentEncoding(username, "", "@%+\\/'!#$^?:,(){}[]~`-_.").constData();
    password = QUrl::toPercentEncoding(password, "", "@%+\\/'!#$^?:,(){}[]~`-_.").constData();

    m_reply = m_nam->post(req, data.arg(username, password).toUtf8());

    connect(
        m_reply,
        &QNetworkReply::finished,
        this,
        &Network::HandleMakerBotTokenResponse);
    connect(
        m_reply,
        &QNetworkReply::sslErrors,
        this,
        &Network::HandleSSLError);
}

void Network::HandleMakerBotTokenResponse() {
    if (m_reply->error()) {
        LOG(info) << "Network error " << m_reply->error() << ": "
                  << m_reply->errorString().toStdString().c_str();
        emit GetMakerBotTokenFailed();
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
            emit GetMakerBotTokenFinished(l[1]);

            m_reply->deleteLater();
            m_reply = nullptr;
            return;
        }
    }

    LOG(info) << "Got unexpected response: " << res.toStdString().c_str();
    emit GetMakerBotTokenFailed();

    m_reply->deleteLater();
    m_reply = nullptr;
}

void Network::HandleSSLError(const QList<QSslError> &errors) {
    // TODO(shirley): make this not happen
    for (const QSslError & err : errors) {
        LOG(info) << "SSL Error " << err.error() << ": "
                  << err.errorString().toStdString().c_str();
    }
    LOG(info) << "Ignoring SSL errors";
    m_reply->ignoreSslErrors();
}
