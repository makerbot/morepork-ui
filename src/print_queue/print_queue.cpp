#include "print_queue.h"
#include <QtConcurrent/QtConcurrent>
#include <QFuture>

PrintQueue::PrintQueue(QNetworkAccessManager *nam)
    : nam(nam),
      metaReply_(nullptr) {
    QThreadPool::globalInstance()->setMaxThreadCount(16);
}

void PrintQueue::fetchPrintMetadata(QString urlPrefix, QString jobId, QString token) {
    if(metaReply_) {
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
