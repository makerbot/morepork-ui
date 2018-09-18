#include <algorithm>
#include "storage/storage.h"
#include "error_utils.h"
#ifdef HAVE_LIBTINYTHING
#include "storage/makerbot_file_meta_reader.h"
#endif


QPixmap ThumbnailPixmapProvider::requestPixmap(const QString &kAbsoluteFilePath,
    QSize *size, const QSize &requestedSize){
#ifdef HAVE_LIBTINYTHING
  const QFileInfo kFileInfo(kAbsoluteFilePath);
  if(kFileInfo.exists()){
    if(kFileInfo.isDir())
      return QPixmap::fromImage(QImage(":/img/directory_icon.png"));
    else{
      MakerbotFileMetaReader file_meta_reader(kFileInfo);
      QImage thumbnail;
      switch(requestedSize.width()) {
      case 140:
          thumbnail = file_meta_reader.getSmallThumbnail();
          break;
      case 212:
          thumbnail = file_meta_reader.getMediumThumbnail();
          break;
      case 960:
          thumbnail = file_meta_reader.getLargeThumbnail();
          break;
      default:
          break;
      }
      if(thumbnail.isNull())
        return QPixmap::fromImage(QImage(":/img/file_no_preview.png"));
      else
        return QPixmap::fromImage(thumbnail);
    }
  }
  else
#endif
    return QPixmap::fromImage(QImage(":/img/file_no_preview.png"));
}


MoreporkStorage::MoreporkStorage()
    : usbStoragePath(USB_STORAGE_PATH) {
  storage_watcher_ = new QFileSystemWatcher();
  usb_storage_watcher_ = new QFileSystemWatcher();
  usb_storage_watcher_->addPath("/dev/disk/by-path");
  prev_thing_dir_ = "";
  m_sortType = PrintFileInfo::StorageSortType::Alphabetic;
  connect(storage_watcher_, SIGNAL(directoryChanged(const QString)),
          this, SLOT(updateStorageFileList(const QString)));
  connect(usb_storage_watcher_, SIGNAL(directoryChanged(const QString)),
          this, SLOT(updateUsbStorageConnected()));
  connect(this, SIGNAL(sortTypeChanged()), this, SLOT(newSortType()));
  usbStorageConnectedSet(false);
  storageIsEmptySet(true);
}


void MoreporkStorage::updateCurrentThing(){
  if(QDir(CURRENT_THING_PATH).exists()){
      QDirIterator current_thing_dir(CURRENT_THING_PATH, QDir::Files |
                                QDir::NoDotAndDotDot | QDir::Readable);
      PrintFileInfo* current_thing = nullptr;
      if(current_thing_dir.hasNext()){
        const QFileInfo kFileInfo = QFileInfo(current_thing_dir.next());
        if(kFileInfo.suffix() == "makerbot"){
  #ifdef HAVE_LIBTINYTHING
          MakerbotFileMetaReader file_meta_reader(kFileInfo);
          if(file_meta_reader.loadMetadata()){
            auto &meta_data = file_meta_reader.meta_data_;
            current_thing = new PrintFileInfo(kFileInfo.absolutePath(),
                                kFileInfo.fileName(),
                                kFileInfo.completeBaseName(),
                                kFileInfo.lastRead(),
                                kFileInfo.isDir(),
                                meta_data->extrusion_mass_g[1],
                                meta_data->extrusion_mass_g[0],
                                meta_data->extruder_temperature[1],
                                meta_data->extruder_temperature[0],
                                meta_data->chamber_temperature,
                                meta_data->shells,
                                meta_data->layer_height,
                                meta_data->infill_density,
                                meta_data->duration_s,
                                meta_data->uses_support,
                                meta_data->uses_raft,
                                QString::fromStdString(meta_data->material[1]),
                                QString::fromStdString(meta_data->material[0]),
                                QString::fromStdString(meta_data->slicer_name));
          }
  #else
          current_thing = new PrintFileInfo(CURRENT_THING_PATH,
                              kFileInfo.fileName(),
                              kFileInfo.fileName(),
                              kFileInfo.lastRead(),
                              kFileInfo.isDir());
  #endif
        }
      }
      if(current_thing != nullptr)
          currentThingSet(current_thing);
      else
          currentThingReset();
  }
}


PrintFileInfo* MoreporkStorage::currentThing() const{
  return current_thing_;
}


void MoreporkStorage::currentThingSet(PrintFileInfo* current_thing){
  current_thing_ = current_thing;
}


void MoreporkStorage::currentThingReset(){
  PrintFileInfo* temp = new PrintFileInfo("/null/path", "null", "null", QDateTime(), false);
  currentThingSet(temp);
}


void MoreporkStorage::updateStorageFileList(const QString kDirectory){
  QString things_dir;
  if(kDirectory == "?root_internal?")
    things_dir = INTERNAL_STORAGE_PATH;
  else if(kDirectory == "?root_usb?")
    things_dir = USB_STORAGE_PATH;
  else
    things_dir = kDirectory;
  if(QFileInfo(prev_thing_dir_).exists())
    storage_watcher_->removePath(prev_thing_dir_);
  prev_thing_dir_ = things_dir;
  storage_watcher_->addPath(things_dir);
  if(QDir(things_dir).exists()){
    QDirIterator it(things_dir, QDir::Dirs | QDir::Files |
      QDir::NoDotAndDotDot | QDir::Readable);
    QList<QObject*> print_file_list;
    while(it.hasNext()){
      const QFileInfo kFileInfo = QFileInfo(it.next());
      if(kFileInfo.suffix() == "makerbot" || kFileInfo.isDir()){
#ifdef HAVE_LIBTINYTHING
        MakerbotFileMetaReader file_meta_reader(kFileInfo);
        if(file_meta_reader.loadMetadata()){
          auto &meta_data = file_meta_reader.meta_data_;
          print_file_list.append(
            new PrintFileInfo(kFileInfo.absolutePath(),
                              kFileInfo.fileName(),
                              kFileInfo.completeBaseName(), // For .makerbot's look until last '.'
                              kFileInfo.lastRead(),
                              kFileInfo.isDir(),
                              meta_data->extrusion_mass_g[1],
                              meta_data->extrusion_mass_g[0],
                              meta_data->extruder_temperature[1],
                              meta_data->extruder_temperature[0],
                              meta_data->chamber_temperature,
                              meta_data->shells,
                              meta_data->layer_height,
                              meta_data->infill_density,
                              meta_data->duration_s,
                              meta_data->uses_support,
                              meta_data->uses_raft,
                              QString::fromStdString(meta_data->material[1]),
                              QString::fromStdString(meta_data->material[0]),
                              QString::fromStdString(meta_data->slicer_name)));
        }
        else
          print_file_list.append(
            new PrintFileInfo(things_dir,
                              kFileInfo.fileName(),
                              kFileInfo.fileName(), // For dirs get the complete name including
                                                    // after the '.', because they're part of the name
                              kFileInfo.lastRead(),
                              kFileInfo.isDir()));
#else
        print_file_list.append(
          new PrintFileInfo(things_dir,
                            kFileInfo.fileName(),
                            kFileInfo.fileName(), // If tinything library is unavailable, get everything
                            kFileInfo.lastRead(),
                            kFileInfo.isDir()));
#endif
      }
    }
    if(print_file_list.empty())
      printFileListReset();
    else{
      if(m_sortType == PrintFileInfo::StorageSortType::Alphabetic){
        std::sort(print_file_list.begin(), print_file_list.end(),
                  PrintFileInfo::fileNameLessThan);
      }
      else if(m_sortType == PrintFileInfo::StorageSortType::PrintTime){
        std::sort(print_file_list.begin(), print_file_list.end(),
                  PrintFileInfo::timeEstimateSecLessThan);
      }
      else if(m_sortType == PrintFileInfo::StorageSortType::DateAdded){
        std::sort(print_file_list.begin(), print_file_list.end(),
                  PrintFileInfo::accessDateGreaterThan);
      }
      printFileListSet(print_file_list);
      storageIsEmptySet(false);
    }
  }
  else
    printFileListReset();
}


void MoreporkStorage::newSortType(){
  if(prev_thing_dir_ != "")
    updateStorageFileList(prev_thing_dir_);
}


void MoreporkStorage::updateUsbStorageConnected(){
  const bool kUsbStorConnected = QFileInfo(USB_STORAGE_DEV_BY_PATH).exists();
  const bool kUsbLegacyConnected = QFileInfo(LEGACY_USB_DEV_BY_PATH).exists();
  usbStorageConnectedSet(kUsbStorConnected || kUsbLegacyConnected);
  if(prev_thing_dir_.left(USB_STORAGE_PATH.size()) == USB_STORAGE_PATH &&
     !kUsbStorConnected)
      backStackClear();
}


void MoreporkStorage::deletePrintFile(QString file_name){
  qDebug() << FL_STRM << "called with file name: " << file_name;
  QString abs_file_path = INTERNAL_STORAGE_PATH + "/" + file_name;
  QFileInfo file_info(abs_file_path);
  EXP_CHK(file_info.exists() && file_info.suffix() == "makerbot", return)
  QFile file(abs_file_path);
  file.remove();
}


QList<QObject*> MoreporkStorage::printFileList() const {
  return print_file_list_;
}


void MoreporkStorage::printFileListSet(const QList<QObject*> &print_file_list) {
  auto temp = print_file_list_;
  print_file_list_ = print_file_list;
  emit printFileListChanged();
  qDeleteAll(temp);
  temp.clear();
}


void MoreporkStorage::printFileListReset(){
  storageIsEmptySet(true);
  QList<QObject*> print_file_list;
  print_file_list.append(new PrintFileInfo("/null/path",
    "No Items Present", "No Items Present", QDateTime(), false));
  printFileListSet(print_file_list);
}


void MoreporkStorage::backStackPush(const QString kDirPath){
  if(QFileInfo(kDirPath).isDir())
    back_dir_stack_.push(kDirPath);
}


QString MoreporkStorage::backStackPop(){
  return back_dir_stack_.empty() ? "" : back_dir_stack_.pop();
}


void MoreporkStorage::backStackClear(){
  back_dir_stack_.clear();
}

