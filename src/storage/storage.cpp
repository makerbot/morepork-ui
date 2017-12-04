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
      QImage thumbnail = file_meta_reader.getMediumThumbnail();
      if(thumbnail.isNull())
        return QPixmap::fromImage(QImage(":/img/makerbot_logo_110x80.png"));
      else
        return QPixmap::fromImage(thumbnail);
    }
  }
  else
#endif
    return QPixmap::fromImage(QImage(":/img/makerbot_logo_110x80.png"));
}


MoreporkStorage::MoreporkStorage(){
  storage_watcher_ = new QFileSystemWatcher();
  connect(storage_watcher_, SIGNAL(directoryChanged(const QString)),
          this, SLOT(updateStorageFileList(const QString)));
}


void MoreporkStorage::updateStorageFileList(const bool kInternal,
    const QString kDirectory){
  const QString kThingsDir = kDirectory.isEmpty() ?
    (kInternal ? INTERNAL_STORAGE_PATH : getUsbDir()) : kDirectory;
  storage_watcher_->removePath(prev_thing_dir_);
  prev_thing_dir_ = kThingsDir;
  storage_watcher_->addPath(kThingsDir);
  QStringList file_list;
  if(QDir(kThingsDir).exists()){
    QDirIterator it(kThingsDir, QDir::Dirs | QDir::Files |
      QDir::NoDotAndDotDot | QDir::Readable);
    QList<QObject*> print_file_list;
    while(it.hasNext()){
      const QFileInfo kFileInfo = QFileInfo(it.next());
      if(kFileInfo.suffix() == "makerbot" || kFileInfo.isDir()){
        unsigned int time_estimate = 0;
#ifdef HAVE_LIBTINYTHING
        MakerbotFileMetaReader file_meta_reader(kFileInfo);
        if(file_meta_reader.loadMetadata()){
          auto &meta_data = file_meta_reader.meta_data_;
          print_file_list.append(
            new PrintFileInfo(kThingsDir,
                              kFileInfo.fileName(),
                              kFileInfo.baseName(),
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
            new PrintFileInfo(kThingsDir,
                              kFileInfo.fileName(),
                              kFileInfo.baseName(),
                              kFileInfo.isDir()));
#else
        print_file_list.append(
          new PrintFileInfo(kThingsDir,
                            kFileInfo.fileName(),
                            kFileInfo.baseName(),
                            kFileInfo.isDir()));
#endif
      }
    }
    if(print_file_list.empty())
      printFileListReset();
    else
      printFileListSet(print_file_list);
  }
  else
    printFileListReset();
}


QString MoreporkStorage::getUsbDir(){
  return USB_STORAGE_PATH;
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
  QList<QObject*> print_file_list;
  print_file_list.append(new PrintFileInfo("/null/path",
    "No Items Present", "No Items Present", false));
  print_file_list.append(new PrintFileInfo("/null/path",
    "No Items Present", "No Items Present", true));
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

