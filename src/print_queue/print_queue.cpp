#include "print_queue.h"
#include <QtConcurrent/QtConcurrent>
#include <QFuture>

#include "storage/storage.h"

PrintQueue::PrintQueue(QNetworkAccessManager *nam)
    : nam(nam),
      metaReply_(nullptr),
      downloadReply_(nullptr),
      downloadFile_(nullptr),
      cancelledDownload_(false),
      downloadingSucceeded_(false),
      downloadingFailed_(false),
      downloadProgressBytes_(0),
      downloadTotalBytes_(0) {
    QThreadPool::globalInstance()->setMaxThreadCount(16);
}

void PrintQueue::fetchPrintMetadata(QString urlPrefix, QString jobId, QString token) {
    if (metaReply_) {
        LOG(info) << "Busy handling an existing network request";
        emit FetchMetadataFailed();
        return;
    }

    QNetworkRequest request;
    request.setUrl(QUrl(urlPrefix + jobId + "/info/meta.json"));
    request.setRawHeader(QByteArray("Authorization"),
                         QByteArray(QString("Bearer " + token).toUtf8()));

    metaReply_ = nam->get(request);

    connect(metaReply_, &QNetworkReply::finished,
            this, &PrintQueue::handleResponseFetchMetadata);
}

QString PrintQueue::getDestination(const QString & fileName) {
    // Avoid directory traversal attacks by disallowing slash characters
    QString safeFileName = fileName;
    safeFileName.replace('/', '_');

    // Get the base file name
    if (safeFileName.endsWith(".makerbot")) {
        safeFileName.chop(9);
    }

    // Keep searching for a filename that does not already exist
    int i = 1;
    QString baseDestination = INTERNAL_STORAGE_PATH + "/" + safeFileName;
    QString destination = baseDestination + ".makerbot";
    while (QFile::exists(destination)) {
        destination = baseDestination + QString("_%1.makerbot").arg(i++);
    }

    return destination;
}
    

void PrintQueue::downloadSlice(QString urlPrefix, QString jobId,
        QString token, QString fileName) {
    if (downloadReply_) {
        LOG(error) << "Cannot download slices concurrently";
        return;
    }

    downloadFile_ = new QFile(getDestination(fileName));
    if (!downloadFile_->open(QIODevice::WriteOnly)) {
        LOG(info) << "Failed to open destination for writing";
        downloadingFailed_ = true;
        emit downloadingFailedChanged();
        delete downloadFile_;
        downloadFile_ = nullptr;
        return;
    }

    QNetworkRequest request;
    request.setUrl(QUrl(urlPrefix + jobId + "/info/teams-" + jobId + "-job.makerbot"));
    request.setRawHeader(QByteArray("Authorization"),
                         QByteArray(QString("Bearer " + token).toUtf8()));

    downloadReply_ = nam->get(request);

    connect(downloadReply_, &QNetworkReply::readyRead,
            this, &PrintQueue::handleReadyReadDownloadSlice);
    connect(downloadReply_, &QNetworkReply::downloadProgress,
            this, &PrintQueue::handleProgressDownloadSlice);
    connect(downloadReply_, &QNetworkReply::finished,
            this, &PrintQueue::handleResponseDownloadSlice);

    emit downloadingChanged();
}

void PrintQueue::handleResponseFetchMetadata() {
    if (metaReply_->error() == QNetworkReply::OperationCanceledError ||
        metaReply_->url().toString() == cancelledRequest_.toString()) {
        cleanupFetchMetadata();
        return;
    }
    if (metaReply_->error() != QNetworkReply::NoError) {
        emit FetchMetadataFailed();
        qWarning() << "Error No: " << metaReply_->error() << "for url: " << metaReply_->url().toString();
        qWarning() << "Request failed, " << metaReply_->errorString();
        qWarning() << "Headers: " <<  metaReply_->rawHeaderList() << "content: " << metaReply_->readAll();
        cleanupFetchMetadata();
        return;
    }

    QString data = metaReply_->readAll();
    QJsonDocument json = QJsonDocument::fromJson(data.toUtf8());
    if (!json.isNull() && json.isObject()) {
        emit FetchMetadataSuccessful(json.toVariant());
    } else {
        emit FetchMetadataFailed();
    }
    cleanupFetchMetadata();
}

void PrintQueue::handleReadyReadDownloadSlice() {
    if (downloadFile_) downloadFile_->write(downloadReply_->readAll());
}

long PrintQueue::downloadProgressBytes() {
    return downloadProgressBytes_;
}

long PrintQueue::downloadTotalBytes() {
    return downloadTotalBytes_;
}

bool PrintQueue::downloading() {
    return downloadFile_ != nullptr;
}

bool PrintQueue::downloadingSucceeded() {
    return downloadingSucceeded_;
}

bool PrintQueue::downloadingFailed() {
    return downloadingFailed_;
}

void PrintQueue::handleProgressDownloadSlice(qint64 bytesRead, qint64 totalBytes) {
    bool totalChanged = (totalBytes == downloadTotalBytes_);
    downloadProgressBytes_ = bytesRead;
    downloadTotalBytes_ = totalBytes;
    if (totalChanged) emit downloadTotalBytesChanged();
    emit downloadProgressBytesChanged();
}

void PrintQueue::handleResponseDownloadSlice() {
    if (downloadReply_->error() == QNetworkReply::OperationCanceledError ||
            cancelledDownload_) {
        cleanupDownloadSlice();
        return;
    }
    if (downloadReply_->error() != QNetworkReply::NoError) {
        downloadingFailed_ = true;
        emit downloadingFailedChanged();
        qWarning() << "Error No: " << downloadReply_->error() << "for url: " << downloadReply_->url().toString();
        qWarning() << "Request failed, " << downloadReply_->errorString();
        qWarning() << "Headers: " <<  downloadReply_->rawHeaderList() << "content: " << downloadReply_->readAll();
        cleanupDownloadSlice();
        return;
    }

    downloadingSucceeded_ = true;
    emit downloadingSucceededChanged();
    cleanupDownloadSlice(false);
}

void PrintQueue::cancelRequest(QString urlPrefix, QString jobId) {
    if (metaReply_) {
        cancelledRequest_ = QUrl(urlPrefix + jobId + "/info/meta.json");
        metaReply_->abort();
    }
    emit FetchMetadataCancelled();
}

void PrintQueue::cancelDownload() {
    if (downloadReply_) {
        cancelledDownload_ = true;
        downloadReply_->abort();
    }
    if (downloadingSucceeded_) {
        downloadingSucceeded_ = false;
        emit downloadingSucceededChanged();
    }
    if (downloadingFailed_) {
        downloadingFailed_ = false;
        emit downloadingFailedChanged();
    }
}

void PrintQueue::cleanupFetchMetadata() {
    cancelledRequest_.clear();
    metaReply_->deleteLater();
    metaReply_ = nullptr;
}

void PrintQueue::cleanupDownloadSlice(bool failed) {
    cancelledDownload_ = false;
    downloadReply_->deleteLater();
    downloadReply_ = nullptr;
    downloadFile_->close();
    if (failed) downloadFile_->remove();
    delete downloadFile_;
    downloadFile_ = nullptr;
    emit downloadingChanged();
    downloadProgressBytes_ = downloadTotalBytes_ = 0;
    emit downloadTotalBytesChanged();
    emit downloadProgressBytesChanged();
}

void PrintQueue::startQueuedPrint(QString urlPrefix, QString jobId, QString token) {
    QNetworkRequest request;
    request.setUrl(QUrl(urlPrefix + jobId + "/start"));

    request.setRawHeader(QByteArray("Authorization"),
                         QByteArray(QString("Bearer " + token).toUtf8()));

    nam->post(request, QString("").toUtf8());
}

void PrintQueue::asyncFetchMeta(QString urlPrefix, QString jobId, QString token,
                            const QJSValue &callback) {
    auto *watcher = new QFutureWatcher<QVariant>(this);
        QObject::connect(watcher, &QFutureWatcher<QVariant>::finished,
                         this, [this, watcher, callback]() {
            QVariant res = watcher->result();
            QJSValue cb(callback); // non-const copy
            QJSEngine *engine = qjsEngine(this);
            cb.call(QJSValueList {engine->toScriptValue(res)});
            watcher->deleteLater();
        });
        watcher->setFuture(QtConcurrent::run(this, &PrintQueue::fetchMeta,
                                             urlPrefix, jobId, token));
}

QVariant PrintQueue::fetchMeta(QString urlPrefix, QString jobId, QString token) {
    QNetworkRequest request(QUrl(urlPrefix + jobId + "/info/meta.json"));
    request.setRawHeader(QByteArray("Authorization"),
                         QByteArray(QString("Bearer " + token).toUtf8()));

    QNetworkAccessManager n;
    QNetworkReply *reply = n.get(request);

    connect(&n, &QNetworkAccessManager::sslErrors,
            reply, [=]{reply->ignoreSslErrors();});

    QEventLoop loop;
    QObject::connect(reply, SIGNAL(finished()), &loop, SLOT(quit()));
    loop.exec();

    QVariantMap response;
    response["success"] = false;
    if (reply->error() != QNetworkReply::NoError) {
        qWarning() << "Error No: " << reply->error() << "for url: " << reply->url().toString();
        qWarning() << "Request failed, " << reply->errorString();
        reply->deleteLater();
        return response;
    }

    QString data = reply->readAll();
    QJsonDocument meta_json = QJsonDocument::fromJson(data.toUtf8());
    if (!meta_json.isNull() && meta_json.isObject()) {
        response["success"] = true;
        response["meta"] = meta_json.toVariant();
    }
    reply->deleteLater();
    return response;
}
