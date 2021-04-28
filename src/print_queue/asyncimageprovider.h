#ifndef ASYNCIMAGEPROVIDER_H
#define ASYNCIMAGEPROVIDER_H
#include <QQuickAsyncImageProvider>
#include <QImage>
#include <QThreadPool>

class QNetworkReply;

class AsyncImageProvider : public QQuickAsyncImageProvider {
public:
    explicit AsyncImageProvider();
    QQuickImageResponse* requestImageResponse(const QString &id, const QSize &requestedSize) override;

private:
    QThreadPool pool_;
};

class AsyncImageResponse : public QQuickImageResponse {
public:
    explicit AsyncImageResponse(const QString &id, const QSize &requestedSize,
                       QThreadPool *pool);

    void handleDone(QImage image) {
        image_ = image;
        emit finished();
    }

    QQuickTextureFactory *textureFactory() const override {
        return QQuickTextureFactory::textureFactoryForImage(image_);
    }

    QImage image_;
};

class AsyncImageResponseRunnable : public QObject, public QRunnable {
    Q_OBJECT
public:
    explicit AsyncImageResponseRunnable(const QString &id, const QSize &requestedSize);

    void run() override;

    enum ImageWidth {
        Small = 140,
        Medium = 212,
        Large = 960
    };

signals:
    void done(QImage image);

private:
    QString id_;
    QSize requestedSize_;
};

#endif // ASYNCIMAGEPROVIDER_H
