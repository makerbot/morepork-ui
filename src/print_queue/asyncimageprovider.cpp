#include "asyncimageprovider.h"
#include <QEventLoop>
#include <QNetworkReply>
#include <QNetworkAccessManager>

AsyncImageProvider::AsyncImageProvider() {
    pool_.setMaxThreadCount(16);
}

QQuickImageResponse* AsyncImageProvider::requestImageResponse(const QString &id,
                                                const QSize &requestedSize) {
    AsyncImageResponse *response = new AsyncImageResponse(id, requestedSize, &pool_);
    return response;
}

AsyncImageResponse::AsyncImageResponse(const QString &id, const QSize &requestedSize,
                                                                QThreadPool *pool) {
    auto runnable = new AsyncImageResponseRunnable(id, requestedSize);
    connect(runnable, &AsyncImageResponseRunnable::done, this, &AsyncImageResponse::handleDone);
    pool->start(runnable);
}

AsyncImageResponseRunnable::AsyncImageResponseRunnable(const QString &id,
                                                       const QSize &requestedSize)
    : id_(id), requestedSize_(requestedSize) {}

void AsyncImageResponseRunnable::run() {
    QStringList list = id_.split("+");
    QString urlPrefix = list[0];
    QString jobId = list[1];
    QString token = list[2];

    QString thumbnail_name;
    QString error_image;
    switch(requestedSize_.width()) {
    case ImageWidth::Small:
        thumbnail_name = "thumbnail_140x106.png";
        error_image = "file_no_preview_small.png";
        break;
    case ImageWidth::Medium:
        thumbnail_name = "thumbnail_212x300.png";
        error_image = "file_no_preview_medium.png";
        break;
    case ImageWidth::Large:
        thumbnail_name = "thumbnail_960x1460.png";
        error_image = "file_no_preview_medium.png";
        break;
    default:
        thumbnail_name = "thumbnail_140x106.png";
        error_image = "file_no_preview_medium.png";
        break;
    }
    // To temporarily address cloudprint bug -
    // https://makerbot.atlassian.net/browse/AB-1885
    urlPrefix = "https://cloudprint.mbot.me/api/queue/jobs/";

    QNetworkReply *reply = nullptr;
    QNetworkRequest request(QUrl(urlPrefix + jobId + "/info/" + thumbnail_name));
    request.setRawHeader(QByteArray("Authorization"),
                         QByteArray(QString("Bearer " + token).toUtf8()));

    QNetworkAccessManager n;
    reply = n.get(request);

    QObject::connect(&n, &QNetworkAccessManager::sslErrors,
            reply, [=]{reply->ignoreSslErrors();});

    QEventLoop loop;
    QObject::connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
    loop.exec();

    QImage image;
    if(reply->error() != QNetworkReply::NoError) {
        image = QImage(":/img/" + error_image);
    } else {
        image = QImage::fromData(reply->readAll());
    }
    reply->deleteLater();
    emit done(image);
}
