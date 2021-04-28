#ifndef PRINTQUEUE_H
#define PRINTQUEUE_H
#include "logging.h"

#include <QNetworkAccessManager>
#include <QJsonDocument>
#include <QImage>
#include <QQuickImageProvider>
#include <QEventLoop>
#include <QNetworkReply>


class QNetworkReply;
class PrintQueueImageLoader;

class PrintQueue : public QObject {
    Q_OBJECT
public:
    explicit PrintQueue(QNetworkAccessManager *nam);

    Q_INVOKABLE void fetchPrintMetadata(QString urlPrefix, QString jobId, QString token);
    Q_INVOKABLE void cancelRequest(QString urlPrefix, QString jobId);

    Q_INVOKABLE void startQueuedPrint(QString urlPrefix, QString jobId, QString token);
    void cleanup();

    Q_INVOKABLE void asyncFetchMeta(QString urlPrefix, QString jobId, QString token, const QJSValue &callback);
    QVariant fetchMeta(QString urlPrefix, QString jobId, QString token);

signals:
    void FetchMetadataSuccessful(QVariant meta);
    void FetchMetadataFailed();
    void FetchMetadataCancelled();

public slots:
    void handleResponseFetchMetadata();

public:
    QNetworkAccessManager *nam;

private:
    QNetworkReply *metaReply_;
    QUrl cancelledRequest_;
};

#endif // PRINTQUEUE_H
