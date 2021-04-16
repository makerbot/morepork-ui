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

class PrintQueueImageLoader : public QQuickImageProvider {
  public:
    PrintQueueImageLoader(PrintQueue *pqueue)
        : QQuickImageProvider(QQuickImageProvider::Pixmap),
          printQueue_(pqueue),
          imageReply_(nullptr) {}

    enum ImageWidth {
        Small = 140,
        Medium = 212,
        Large = 960
    };

    QPixmap requestPixmap(const QString &jobId, QSize *size,
                          const QSize &requestedSize);

private:
  PrintQueue *printQueue_;
  QNetworkReply *imageReply_;
};

#endif // PRINTQUEUE_H
