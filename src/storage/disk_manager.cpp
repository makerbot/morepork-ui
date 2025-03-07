#include "storage/disk_manager.h"
StorageVolume::StorageVolume(const QString path,
                             int reserved_space_mb)
    : reserved_space_mb_(reserved_space_mb){
    QDir dir(path);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
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
