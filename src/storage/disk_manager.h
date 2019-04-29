#ifndef DISK_MANAGER_H
#define DISK_MANAGER_H

#include <QObject>
#include <QStorageInfo>
#include <QFileSystemWatcher>
#include <QDebug>

#ifdef MOREPORK_UI_QT_CREATOR_BUILD
// desktop linux path
#define INTERNAL_PATH QString("/home/")+qgetenv("USER")+"/things"
#define USB_PATH QString("/home/")+qgetenv("USER")+"/things"
#else
// embedded linux path
#define INTERNAL_PATH QString("/home/things")
#define USB_PATH QString("/home/usb_storage0")
#endif

class StorageVolume : public QObject {
    Q_OBJECT
private:
    QStorageInfo *storage_;
    QFileSystemWatcher *watcher_;
    int reserved_space_mb_;

    inline float getFreeSpace() {
        return storage_->bytesAvailable()/1000/1000; // MB
    }

    inline float getTotalSpace() {
        return storage_->bytesTotal()/1000/1000; // MB
    }

public:
    explicit StorageVolume(const QString path,
                           int reserved_space_mb = 0);

    inline float getUsage() {
        float used = getTotalSpace() - getFreeSpace()
                        + reserved_space_mb_;
        return (used*100/getTotalSpace());
    }

public slots:
    inline void storageUpdated() {
        storage_->refresh();
        emit storageInfoUpdated(getUsage());
    }
signals:
    void storageInfoUpdated(float);
};

class DiskManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(float internalUsed
               READ internalUsed
               WRITE setInternalUsage
               NOTIFY internalChanged)
    /*
    Q_PROPERTY(float usbUsed
               READ usbUsed
               WRITE setUsbUsage
               NOTIFY usbChanged)
    */
public:
    explicit DiskManager();

    float internalUsed() const;
    Q_INVOKABLE void updateInternalUsage();
    /*
     float usbUsed() const;
     Q_INVOKABLE void updateUsbUsage();
    */

public slots:
    void setInternalUsage(float);
    /*
     void setUsbUsage(float);
    */

signals:
    void internalChanged();
    /*
     void usbChanged();
    */

private:
    StorageVolume *internal_;
    float internalUsed_;
    /*
     StorageVolume *usb_;
     float usbUsed_;
    */
};

#endif // DISK_MANAGER_H
