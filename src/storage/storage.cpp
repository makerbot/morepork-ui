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


QPixmap ThumbnailPixmapProvider::requestPixmap(
    const QString &absolute_file_path,
    QSize *size, const QSize &requestedSize) {
#ifdef HAVE_LIBTINYTHING
  const QFileInfo file_info(absolute_file_path);
  if (file_info.exists()) {
    if (file_info.isDir()) {
      return QPixmap::fromImage(QImage(":/img/directory_icon.png"));
    } else {
      MakerbotFileMetaReader file_meta_reader(file_info);
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
      if (!thumbnail.isNull()) {
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


MoreporkStorage::MoreporkStorage() :
    usbStoragePath(USB_STORAGE_PATH) {
  storage_watcher_ = new QFileSystemWatcher();
  usb_storage_watcher_ = new QFileSystemWatcher();
  usb_storage_watcher_->addPath("/dev/disk/by-path");
  prev_thing_dir_ = "";
  m_sortType = MoreporkFileInfo::StorageSortType::DateAdded;

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
  if (!QFileInfo::exists(TEST_PRINT_PATH + "/test_print.makerbot") ||
      !QFileInfo(TEST_PRINT_PATH + "/test_print.makerbot").isFile()) {
    // Tiny test file 74 kb, so okay to do I/O in constructor I guess.
    QFile::copy(":/test_files/smallcircle.makerbot",
                TEST_PRINT_PATH + "/test_print.makerbot");
  }
}


void MoreporkStorage::setStorageFileType(
    const MoreporkStorage::StorageFileType type) {
  storageFileTypeSet(type);
}


// Check if the firmware zip contains a manifest.json file and there exists a
// PID key within that file with a valid value.
bool MoreporkStorage::firmwareIsValid(const QString file_path) {
  const QString kUnzippedManifestFilePath = DISK_FW_PATH + "/manifest.json";
  bool fw_is_valid = false;

  if (QFileInfo(file_path).exists()) {
    // remove a manifest.json file if one already exists
    if (QFileInfo(kUnzippedManifestFilePath).exists()) {
      QString cmd = "rm -f " + kUnzippedManifestFilePath;
      const int ret_val = system(cmd.toStdString().c_str());
    }
    QString cmd = "unzip " + file_path +
                  " manifest.json -d " + DISK_FW_PATH;
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
                               DISK_FW_PATH + "/" + DEFAULT_FW_FILE_NAME);
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
    fileListReset();
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
          new MoreporkFileInfo(file_info.absolutePath(),
                               file_info.fileName(),
                               file_info.completeBaseName(),
                               file_info.lastRead(),
                               file_info.isDir()));
      }
    }

    if (fw_file_list.empty()) {
      fileListReset();
    } else {
      std::sort(fw_file_list.begin(), fw_file_list.end(),
                MoreporkFileInfo::accessDateGreaterThan);
      foreach (auto obj, fw_file_list) {
        MP_QINFO(static_cast<MoreporkFileInfo*>(obj)->fileBaseName())
      }
      fileListSet(fw_file_list);
      storageIsEmptySet(false);
    }
  } else {
    fileListReset();
  }
}


MoreporkFileInfo* MoreporkStorage::parseMakerbotFile(
    const QFileInfo &file_info,
    const QString default_file_path,
    const bool return_null_on_parse_fail) {
#ifdef HAVE_LIBTINYTHING
  MakerbotFileMetaReader file_meta_reader(file_info);
  if (file_meta_reader.loadMetadata()) {
    auto &meta_data = file_meta_reader.meta_data_;
    QString material_name_a = QString::fromStdString(meta_data->material[1]);
    // TODO(praveen): Make this less hacky. not good.
    if (material_name_a == "im-pla")
      material_name_a = "tough";
    QString material_name_b = QString::fromStdString(meta_data->material[0]);
    // TODO(praveen): Make this less hacky. not good.
    if (material_name_b == "im-pla")
      material_name_b = "tough";
    return new MoreporkFileInfo(
      file_info.absolutePath(),
      file_info.fileName(),
      file_info.completeBaseName(),
      file_info.lastRead(),
      file_info.isDir(),
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
  } else if (return_null_on_parse_fail) {
    return nullptr;
  } else {
    return new MoreporkFileInfo(
      default_file_path,
      file_info.fileName(),
      file_info.fileName(), // For dirs get the complete name including
                            // after the '.', because they're part of the name
      file_info.lastRead(),
      file_info.isDir());
  }
#else
  return new MoreporkFileInfo(
    default_file_path,
    file_info.fileName(),
    file_info.fileName(), // If tinything library is unavailable, get everything
    file_info.lastRead(),
    file_info.isDir());
#endif
}


void MoreporkStorage::updateCurrentThing(const bool is_test_print) {
  const QString dir_path = (is_test_print ? TEST_PRINT_PATH :
                                            CURRENT_THING_PATH);
  if (QDir(dir_path).exists()) {
    QDirIterator current_thing_dir(dir_path, QDir::Files |
                                   QDir::NoDotAndDotDot | QDir::Readable);
    MoreporkFileInfo* current_thing = nullptr;
    if (current_thing_dir.hasNext()) {
      const QFileInfo file_info = QFileInfo(current_thing_dir.next());
      if (file_info.suffix() == "makerbot")
        current_thing = parseMakerbotFile(file_info, dir_path, true);
    }
    if (current_thing != nullptr)
      currentThingSet(current_thing);
    else
      currentThingReset();
  }
}


MoreporkFileInfo* MoreporkStorage::currentThing() const{
  return current_thing_;
}


void MoreporkStorage::currentThingSet(MoreporkFileInfo* current_thing) {
  current_thing_ = current_thing;
}


void MoreporkStorage::currentThingReset() {
  MoreporkFileInfo* temp =
    new MoreporkFileInfo("/null/path", "null", "null", QDateTime(), false);
  currentThingSet(temp);
}


void MoreporkStorage::updatePrintFileList(const QString directory) {
  if(m_storageFileType != MoreporkStorage::StorageFileType::Print) {
    fileListReset();
    return;
  }

  QString things_dir;
  if (directory == "?root_internal?")
    things_dir = INTERNAL_STORAGE_PATH;
  else if (directory == "?root_usb?")
    things_dir = USB_STORAGE_PATH;
  else
    things_dir = directory;

  if (QFileInfo(prev_thing_dir_).exists())
    storage_watcher_->removePath(prev_thing_dir_);

  prev_thing_dir_ = things_dir;
  storage_watcher_->addPath(things_dir);

  if (QDir(things_dir).exists()) {
    QDirIterator it(things_dir, QDir::Dirs | QDir::Files |
      QDir::NoDotAndDotDot | QDir::Readable);
    QList<QObject*> file_list;

    while(it.hasNext()) {
      const QFileInfo file_info = QFileInfo(it.next());
      if (file_info.suffix() == "makerbot" || file_info.isDir())
        file_list.append(parseMakerbotFile(file_info, things_dir, false));
    }
    if (file_list.empty()) {
      fileListReset();
    } else {
      if (m_sortType == MoreporkFileInfo::StorageSortType::Alphabetic) {
        std::sort(file_list.begin(), file_list.end(),
                  MoreporkFileInfo::fileNameLessThan);
      } else if (m_sortType == MoreporkFileInfo::StorageSortType::PrintTime) {
        std::sort(file_list.begin(), file_list.end(),
                  MoreporkFileInfo::timeEstimateSecLessThan);
      } else if (m_sortType == MoreporkFileInfo::StorageSortType::DateAdded) {
        std::sort(file_list.begin(), file_list.end(),
                  MoreporkFileInfo::accessDateGreaterThan);
      }
      fileListSet(file_list);
      storageIsEmptySet(false);
    }
  } else {
    fileListReset();
  }
}


void MoreporkStorage::newSortType() {
  if (prev_thing_dir_ != "")
    updatePrintFileList(prev_thing_dir_);
}


void MoreporkStorage::updateUsbStorageConnected() {
  usbStorageConnectedSet(QFileInfo(USB_STORAGE_DEV_BY_PATH).exists());
  if (!m_usbStorageConnected) {
    prog_copy_->cancel(); // cancel copy if one is ongoing
    fileListReset();
  }
  const QString usb_storage_path = USB_STORAGE_PATH;
  if (prev_thing_dir_.left(usb_storage_path.size()) == usb_storage_path &&
     !m_usbStorageConnected) {
    backStackClear();
  }
}


void MoreporkStorage::deletePrintFile(QString file_name) {
  qDebug() << FL_STRM << "called with file name: " << file_name;
  QString abs_file_path = INTERNAL_STORAGE_PATH + "/" + file_name;
  QFileInfo file_info(abs_file_path);
  EXP_CHK(file_info.exists() && file_info.suffix() == "makerbot", return)
  QFile file(abs_file_path);
  file.remove();
}


QList<QObject*> MoreporkStorage::fileList() const {
  return file_list_;
}


void MoreporkStorage::fileListSet(const QList<QObject*> &file_list) {
  auto temp = file_list_;
  file_list_ = file_list;
  emit fileListChanged();
  qDeleteAll(temp);
  temp.clear();
}


void MoreporkStorage::fileListReset() {
  storageIsEmptySet(true);
  QList<QObject*> file_list;
  file_list.append(
    new MoreporkFileInfo("/null/path", "No Items Present",
                         "No Items Present", QDateTime(), false));
  fileListSet(file_list);
}


void MoreporkStorage::backStackPush(const QString directory_path) {
  if (QFileInfo(directory_path).isDir())
    back_dir_stack_.push(directory_path);
}


QString MoreporkStorage::backStackPop() {
  return back_dir_stack_.empty() ? "" : back_dir_stack_.pop();
}


void MoreporkStorage::backStackClear() {
  back_dir_stack_.clear();
}
