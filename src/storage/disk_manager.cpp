#include "storage/disk_manager.h"
StorageVolume::StorageVolume(const QString path,
                             int reserved_space_mb)
    : reserved_space_mb_(reserved_space_mb){
   storage_ = new QStorageInfo();
   watcher_ = new QFileSystemWatcher();
   watcher_->addPath(path);
   connect(watcher_, SIGNAL(directoryChanged(const QString)),
           this, SLOT(storageUpdated()));
   storage_->setPath(path);
   storage_->refresh();
}

DiskManager::DiskManager() {
    internal_  = new StorageVolume(INTERNAL_PATH, 2000); //2GB reserved
    connect(internal_, SIGNAL(storageInfoUpdated(float)),
            this, SLOT(setInternalUsage(float)));
    updateInternalUsage();
/*
    usb_ = new StorageVolume(USB_PATH);
    connect(usb_, SIGNAL(storageInfoUpdated(float)),
            this, SLOT(setUsbUsage(float)));
    updateUsbUsage();
*/
}

void DiskManager::setInternalUsage(float usage) {
    internalUsed_= usage;
}

void DiskManager::updateInternalUsage() {
    internalUsed_ = internal_->getUsage();
    emit internalChanged();
}

float DiskManager::internalUsed() const {
    return internalUsed_;
}

/*
void DiskManager::setUsbUsage(float usage) {
    usbUsed_ = usage;
}

void DiskManager::updateUsbUsage() {
    usbUsed_ = usb_->getUsage();
    emit usbChanged();
}

float DiskManager::usbUsed() const {
    return usbUsed_;
}
*/
