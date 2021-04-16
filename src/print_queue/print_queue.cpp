#include "print_queue.h"

PrintQueue::PrintQueue(QNetworkAccessManager *nam)
    : nam(nam),
      metaReply_(nullptr) {
}

void PrintQueue::fetchPrintMetadata(QString urlPrefix, QString jobId, QString token) {
    if(metaReply_) {
        LOG(info) << "Busy handling an existing network request";
        emit FetchMetadataFailed();
        return;
    }
    // To temporarily address cloudprint bug -
    // https://makerbot.atlassian.net/browse/AB-1885
    urlPrefix = "https://cloudprint.mbot.me/api/queue/jobs/";

    QNetworkRequest request;
    request.setUrl(QUrl(urlPrefix + jobId + "/info/meta.json"));

    request.setRawHeader(QByteArray("Authorization"),
                         QByteArray(QString("Bearer " + token).toUtf8()));

    metaReply_ = nam->get(request);

    connect(metaReply_, &QNetworkReply::finished,
            this, &PrintQueue::handleResponseFetchMetadata);
}

void PrintQueue::handleResponseFetchMetadata() {
    if (metaReply_->error() == QNetworkReply::OperationCanceledError ||
        metaReply_->url().toString() == cancelledRequest_.toString()) {
        cleanup();
        return;
    }
    if (metaReply_->error() != QNetworkReply::NoError) {
        emit FetchMetadataFailed();
        qWarning() << "Error No: " << metaReply_->error() << "for url: " << metaReply_->url().toString();
        qWarning() << "Request failed, " << metaReply_->errorString();
        qWarning() << "Headers: " <<  metaReply_->rawHeaderList() << "content: " << metaReply_->readAll();
        cleanup();
        return;
    }

    QString data = metaReply_->readAll();
    QJsonDocument json = QJsonDocument::fromJson(data.toUtf8());
    if (!json.isNull() && json.isObject()) {
        emit FetchMetadataSuccessful(json.toVariant());
    } else {
        emit FetchMetadataFailed();
    }
    cleanup();
}

void PrintQueue::cancelRequest(QString urlPrefix, QString jobId) {
    // To temporarily address cloudprint bug -
    // https://makerbot.atlassian.net/browse/AB-1885
    urlPrefix = "https://cloudprint.mbot.me/api/queue/jobs/";
    if(metaReply_) {
        cancelledRequest_ = QUrl(urlPrefix + jobId + "/info/meta.json");
        metaReply_->abort();
    }
    emit FetchMetadataCancelled();
}

void PrintQueue::cleanup() {
    cancelledRequest_.clear();
    metaReply_->deleteLater();
    metaReply_ = nullptr;
}

void PrintQueue::startQueuedPrint(QString urlPrefix, QString jobId, QString token) {
    // To temporarily address cloudprint bug -
    // https://makerbot.atlassian.net/browse/AB-1885
    urlPrefix = "https://cloudprint.mbot.me/api/queue/jobs/";
    QNetworkRequest request;
    request.setUrl(QUrl(urlPrefix + jobId + "/start"));

    request.setRawHeader(QByteArray("Authorization"),
                         QByteArray(QString("Bearer " + token).toUtf8()));

    nam->post(request, QString("").toUtf8());
}

QPixmap PrintQueueImageLoader::requestPixmap(const QString &id, QSize *size,
                      const QSize &requestedSize) {
    QStringList list = id.split("+");
    QString urlPrefix = list[0];
    QString jobId = list[1];
    QString token = list[2];

    QString thumbnail_name;
    switch(requestedSize.width()) {
    case ImageWidth::Small:
        thumbnail_name = "thumbnail_140x106.png";
        break;
    case ImageWidth::Medium:
        thumbnail_name = "thumbnail_212x300.png";
        break;
    case ImageWidth::Large:
        thumbnail_name = "thumbnail_960x1460.png";
        break;
    default:
        thumbnail_name = "thumbnail_140x106.png";
        break;
    }
    // To temporarily address cloudprint bug -
    // https://makerbot.atlassian.net/browse/AB-1885
    urlPrefix = "https://cloudprint.mbot.me/api/queue/jobs/";

    QNetworkRequest request;
    request.setUrl(QUrl(urlPrefix + jobId + "/info/" + thumbnail_name));
    request.setRawHeader(QByteArray("Authorization"),
                         QByteArray(QString("Bearer " + token).toUtf8()));

    imageReply_ = printQueue_->nam->get(request);

    QEventLoop loop;
    QObject::connect(imageReply_, SIGNAL(finished()), &loop, SLOT(quit()));
    loop.exec();

    QImage image = QImage::fromData(imageReply_->readAll());
    imageReply_->deleteLater();
    return QPixmap::fromImage(image);
}
