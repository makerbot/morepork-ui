#ifndef PRINTQUEUE_H
#define PRINTQUEUE_H
#include "logging.h"

#include <QNetworkAccessManager>
#include <QJsonDocument>
#include <QImage>
#include <QQuickImageProvider>
#include <QEventLoop>
#include <QNetworkReply>
#include <QFile>


class QNetworkReply;
class PrintQueueImageLoader;

class PrintQueue : public QObject {
    Q_OBJECT
public:
    explicit PrintQueue(QNetworkAccessManager *nam);

    Q_INVOKABLE void fetchPrintMetadata(QString urlPrefix, QString jobId, QString token);
    Q_INVOKABLE void cancelRequest(QString urlPrefix, QString jobId);

    Q_INVOKABLE void downloadSlice(QString urlPrefix, QString jobId, QString token, QString fileName);
    Q_INVOKABLE void cancelDownload();
    Q_PROPERTY(long downloadProgressBytes READ downloadProgressBytes NOTIFY downloadProgressBytesChanged);
    Q_PROPERTY(long downloadTotalBytes READ downloadTotalBytes NOTIFY downloadTotalBytesChanged);
    Q_PROPERTY(bool downloading READ downloading NOTIFY downloadingChanged);
    Q_PROPERTY(bool downloadingSucceeded READ downloadingSucceeded NOTIFY downloadingSucceededChanged);
    Q_PROPERTY(bool downloadingFailed READ downloadingFailed NOTIFY downloadingFailedChanged);
    long downloadProgressBytes();
    long downloadTotalBytes();
    bool downloading();
    bool downloadingSucceeded();
    bool downloadingFailed();

    Q_INVOKABLE void startQueuedPrint(QString urlPrefix, QString jobId, QString token);

    Q_INVOKABLE void asyncFetchMeta(QString urlPrefix, QString jobId, QString token, const QJSValue &callback);
    QVariant fetchMeta(QString urlPrefix, QString jobId, QString token);

signals:
    void FetchMetadataSuccessful(QVariant meta);
    void FetchMetadataFailed();
    void FetchMetadataCancelled();

    void downloadProgressBytesChanged();
    void downloadTotalBytesChanged();
    void downloadingChanged();
    void downloadingSucceededChanged();
    void downloadingFailedChanged();

public slots:
    void handleResponseFetchMetadata();
    void handleReadyReadDownloadSlice();
    void handleProgressDownloadSlice(qint64 bytesRead, qint64 totalBytes);
    void handleResponseDownloadSlice();

public:
    QNetworkAccessManager *nam;

private:
    QNetworkReply *metaReply_;
    QNetworkReply *downloadReply_;
    QFile *downloadFile_;
    QUrl cancelledRequest_;
    bool cancelledDownload_;
    bool downloadingSucceeded_;
    bool downloadingFailed_;
    long downloadProgressBytes_;
    long downloadTotalBytes_;
    QString getDestination(const QString & fileName);
    void cleanupFetchMetadata();
    void cleanupDownloadSlice(bool failed = true);
};

#endif // PRINTQUEUE_H
