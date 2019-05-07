#include <algorithm>
#include <fstream>
#include <jsoncpp/json/value.h>
#include <jsoncpp/json/reader.h>
#include "storage/storage.h"
#include "error_utils.h"
#include "logging.h"
#ifdef HAVE_LIBTINYTHING
#include "storage/makerbot_file_meta_reader.h"
#endif


QPixmap ThumbnailPixmapProvider::requestPixmap(const QString &kAbsoluteFilePath,
    QSize *size, const QSize &requestedSize) {
#ifdef HAVE_LIBTINYTHING
  const QFileInfo kFileInfo(kAbsoluteFilePath);
  if(kFileInfo.exists()) {
      if(kFileInfo.isDir()) {
          return QPixmap::fromImage(QImage(":/img/directory_icon.png"));
      } else {
          MakerbotFileMetaReader file_meta_reader(kFileInfo);
          QImage thumbnail;
          switch(requestedSize.width()) {
              case ThumbnailWidth::Small:
                thumbnail = file_meta_reader.getSmallThumbnail();
                break;
              case ThumbnailWidth::Medium:
                thumbnail = file_meta_reader.getMediumThumbnail();
                break;
              case ThumbnailWidth::Large:
                thumbnail = file_meta_reader.getLargeThumbnail();
                break;
              default:
                break;
          }
          if(!thumbnail.isNull()) {
              return QPixmap::fromImage(thumbnail);
          }
      }
  }
  else
#endif
  {
      return QPixmap::fromImage(QImage(":/img/file_no_preview.png"));
  }
}


MoreporkStorage::MoreporkStorage()
    : usbStoragePath(USB_STORAGE_PATH) {
  storage_watcher_ = new QFileSystemWatcher();
  usb_storage_watcher_ = new QFileSystemWatcher();
  usb_storage_watcher_->addPath("/dev/disk/by-path");
  prev_thing_dir_ = "";
  m_sortType = PrintFileInfo::StorageSortType::DateAdded;
  connect(storage_watcher_, SIGNAL(directoryChanged(const QString)),
          this, SLOT(updatePrintFileList(const QString)));
  connect(storage_watcher_, SIGNAL(directoryChanged(const QString)),
          this, SLOT(updateFirmwareFileList(const QString)));
  connect(usb_storage_watcher_, SIGNAL(directoryChanged(const QString)),
          this, SLOT(updateUsbStorageConnected()));
  connect(this, SIGNAL(sortTypeChanged()), this, SLOT(newSortType()));

  prog_copy_ = new ProgressCopy();
  connect(prog_copy_, SIGNAL(progressChanged(double)),
           this, SLOT(setFileCopyProgress(double)));
  connect(this, SIGNAL(cancelCopyThread()), prog_copy_, SLOT(cancel()));
  connect(prog_copy_, SIGNAL(finished(bool)),
          this, SLOT(setFileCopySucceeded(bool)));

#ifdef MOREPORK_UI_QT_CREATOR_BUILD
  usbStorageConnectedSet(true);
#else
  usbStorageConnectedSet(false);
#endif
  storageIsEmptySet(true);
  fileIsCopyingSet(false);
  fileCopySucceededSet(false);
  fileCopyProgressSet(0);
  storageFileTypeSet(MoreporkStorage::StorageFileType::Print);

  QDir dir(TEST_PRINT_PATH);
  if (!dir.exists()) {
      // Creates TEST_PRINT_PATH
      dir.mkpath(".");
  }
  if(!QFileInfo(TEST_PRINT_PATH + "/test_print.makerbot").exists() ||
     !QFileInfo(TEST_PRINT_PATH + "/test_print.makerbot").isFile() ||
     (QFile(TEST_PRINT_PATH + "/test_print.makerbot").size() !=
      QFile(":/test_files/test_print.makerbot").size())) {
      QFile::remove(TEST_PRINT_PATH + "/test_print.makerbot");
      // Tiny test file 74 kb, so okay to do I/O in constructor I guess.
      QFile::copy(":/test_files/test_print.makerbot",
                  TEST_PRINT_PATH + "/test_print.makerbot");
  }

  updateUsbStorageConnected();
}


void MoreporkStorage::setStorageFileType(
    const MoreporkStorage::StorageFileType type) {
  storageFileTypeSet(type);
}


// Check if the firmware zip contains a manifest.json file and there exists a
// PID key within that file with a valid value.
bool MoreporkStorage::firmwareIsValid(const QString file_path) {
  const QString kUnzippedManifestFilePath = FIRMWARE_FOLDER_PATH + "/manifest.json";
  bool fw_is_valid = false;

  if (QFileInfo(file_path).exists()) {
    // remove a manifest.json file if one already exists
    if (QFileInfo(kUnzippedManifestFilePath).exists()) {
      QString cmd = "rm -f " + kUnzippedManifestFilePath;
      const int ret_val = system(cmd.toStdString().c_str());
    }
    QString cmd = "unzip " + file_path +
                  " manifest.json -d " + FIRMWARE_FOLDER_PATH;
    const int ret_val = system(cmd.toStdString().c_str());
    if (QFileInfo(kUnzippedManifestFilePath).exists()) {
      std::ifstream manifest_file_strm(kUnzippedManifestFilePath.toStdString());
      Json::Reader json_reader;
      Json::Value root_jval;
      if (manifest_file_strm &&
          json_reader.parse(manifest_file_strm, root_jval)) {
        if (root_jval.isMember("supported_machines")) {
          const Json::Value &supported_mach = root_jval["supported_machines"];
          if (supported_mach.isArray()) {
            for (int i = 0; i < supported_mach.size(); ++i) {
              const Json::Value &sm = supported_mach[i];
              if (sm.isMember("pid")) {
                const Json::Value &pid_jval = sm["pid"];
                if (pid_jval.isNumeric()) {
                  const int manifest_pid = pid_jval.asInt();
                  for (auto pid : kValidMachinePid) {
                    if (fw_is_valid = pid == manifest_pid) {
                      break;
                    }
                  }
                }
              }
            }
          }
        }
      }
      QString cmd = "rm -f " + kUnzippedManifestFilePath;
      const int ret_val = system(cmd.toStdString().c_str());
    }
  }
  return fw_is_valid;
}


void MoreporkStorage::copyFirmwareToDisk(const QString file_path) {
  if (QFileInfo(file_path).exists()) {
    fileCopySucceededSet(false);
    prog_copy_->setSrcDstFiles(file_path,
                               FIRMWARE_FOLDER_PATH + "/" + DEFAULT_FW_FILE_NAME);
    fileIsCopyingSet(true);
    prog_copy_->process();
  }
}


// Q_INVOKABLE called from UI
void MoreporkStorage::cancelCopy() {
  emit cancelCopyThread();
}


// called by SIGNAL emitted from prog_copy_
void MoreporkStorage::setFileCopyProgress(double progress) {
  fileCopyProgressSet(progress);
}


// called by SIGNAL emitted from prog_copy_
void MoreporkStorage::setFileCopySucceeded(bool success) {
  // tell UI if file copy was success. UI logic will handle brooklyn_upload call
  fileCopySucceededSet(success);
  fileIsCopyingSet(false);
}


void MoreporkStorage::updateFirmwareFileList(const QString directory_path) {
  if (m_storageFileType != MoreporkStorage::StorageFileType::Firmware) {
    printFileListReset();
    return;
  }

  QString fw_file_dir;
  if (directory_path == "?root_usb?")
    fw_file_dir = USB_STORAGE_PATH;
  else
    fw_file_dir = directory_path;

  if (QFileInfo(prev_thing_dir_).exists())
    storage_watcher_->removePath(prev_thing_dir_);

  prev_thing_dir_ = fw_file_dir;
  storage_watcher_->addPath(fw_file_dir);

  if (QDir(fw_file_dir).exists()) {
    QDirIterator it(fw_file_dir, QDir::Dirs | QDir::Files |
      QDir::NoDotAndDotDot | QDir::Readable);
    QList<QObject*> fw_file_list;

    while (it.hasNext()) {
      const QFileInfo file_info = QFileInfo(it.next());
      if (file_info.suffix() == "zip" || file_info.isDir()) {
        fw_file_list.append(
          new PrintFileInfo(file_info.absolutePath(),
                               file_info.fileName(),
                               file_info.completeBaseName(),
                               file_info.lastRead(),
                               file_info.isDir()));
      }
    }

    if (fw_file_list.empty()) {
      printFileListReset();
    } else {
      std::sort(fw_file_list.begin(), fw_file_list.end(),
                PrintFileInfo::accessDateGreaterThan);
//      foreach (auto obj, fw_file_list) {
//        MP_QINFO(static_cast<MoreporkFileInfo*>(obj)->fileBaseName())
//      }
      printFileListSet(fw_file_list);
      storageIsEmptySet(false);
    }
  } else {
    printFileListReset();
  }
}




void MoreporkStorage::updateCurrentThing(const bool is_test_print) {
  const QString dir_path = (is_test_print ? TEST_PRINT_PATH : CURRENT_THING_PATH);
  if(QDir(dir_path).exists()){
      QDirIterator current_thing_dir(dir_path, QDir::Files |
                                QDir::NoDotAndDotDot | QDir::Readable);
      PrintFileInfo* current_thing = nullptr;
      if(current_thing_dir.hasNext()){
        const QFileInfo kFileInfo = QFileInfo(current_thing_dir.next());
        if(kFileInfo.suffix() == "makerbot"){
  #ifdef HAVE_LIBTINYTHING
          MakerbotFileMetaReader file_meta_reader(kFileInfo);
          if(file_meta_reader.loadMetadata()){
            auto &meta_data = file_meta_reader.meta_data_;
            QString material_name_a = QString::fromStdString(meta_data->material[1]);
            updateMaterialNames(material_name_a);
            QString material_name_b = QString::fromStdString(meta_data->material[0]);
            updateMaterialNames(material_name_b);
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
                                material_name_a,
                                material_name_b,
                                QString::fromStdString(meta_data->slicer_name));
          }
  #else
          current_thing = new PrintFileInfo(dir_path,
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


void MoreporkStorage::updatePrintFileList(const QString kDirectory){
  if(m_storageFileType != MoreporkStorage::StorageFileType::Print) {
    printFileListReset();
    return;
  }

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
          QString material_name_a = QString::fromStdString(meta_data->material[1]);
          updateMaterialNames(material_name_a);
          QString material_name_b = QString::fromStdString(meta_data->material[0]);
          updateMaterialNames(material_name_b);
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
                              material_name_a,
                              material_name_b,
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
    updatePrintFileList(prev_thing_dir_);
}


void MoreporkStorage::updateUsbStorageConnected(){
  const bool kUsbStorConnected = QFileInfo(USB_STORAGE_DEV_BY_PATH).exists();
  const bool kUsbLegacyConnected = QFileInfo(LEGACY_USB_DEV_BY_PATH).exists();
  usbStorageConnectedSet(kUsbStorConnected || kUsbLegacyConnected);
  if (!kUsbStorConnected) {
      prog_copy_->cancel(); // cancel copy if one is ongoing
      printFileListReset();
  }
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
    tr("No Items Present"), tr("No Items Present"), QDateTime(), false));
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

void MoreporkStorage::updateMaterialNames(QString &name) {
    if(name == "im-pla") {
        name = "tough";
    } else if(name == "generic_model") {
        name = "unknown";
    }
}
