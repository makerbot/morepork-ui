#ifndef __MOREPORK_STORAGE_H__
#define __MOREPORK_STORAGE_H__

#include <QFileSystemWatcher>
#include <QList>
#include <QDebug>
#include <QDirIterator>
#include <QImage>
#include <QQuickImageProvider>
#include <QStack>
#include <QDateTime>
#include "model/base_model.h"
#include "storage/progress_copy.h"

#define DEFAULT_FW_FILE_NAME QString("firmware.zip")
#define TEST_PRINT_FILE_PREFIX QString("test_print_")
#ifdef MOREPORK_UI_QT_CREATOR_BUILD
// desktop linux path
#define INTERNAL_STORAGE_PATH QString("/home/")+qgetenv("USER")+"/things"
#define USB_STORAGE_PATH QString("/home/")+qgetenv("USER")+"/usb_storage"
#define CURRENT_THING_PATH QString("/home/")+qgetenv("USER")+"/current_thing"
#define TEST_PRINT_PATH QString("/home/")+qgetenv("USER")+"/test_prints/"
#define FIRMWARE_FOLDER_PATH QString("/home/")+qgetenv("USER")+"/firmware"
#define USB_STORAGE_DEV_BY_PATH_FRNT_PNL QString()
#define USB_STORAGE_DEV_BY_PATH_MOBO_PORT_2 QString()
#define USB_STORAGE_DEV_BY_PATH_MOBO_PORT_3 QString()
#define USB_STORAGE_DEV_BY_PATH_WITH_ACCESSORY_PORT_1 QString()
#define USB_STORAGE_DEV_BY_PATH_WITH_ACCESSORY_PORT_2 QString()
#ifdef SETTINGS_FILE_DIR
#define MACHINE_PID_PATH SETTINGS_FILE_DIR + std::string("/mock_PID")
#endif
#else
// embedded linux path
#define INTERNAL_STORAGE_PATH QString("/home/things")
#define USB_STORAGE_PATH QString("/home/usb_storage0")
#define CURRENT_THING_PATH QString("/home/current_thing")
#define TEST_PRINT_PATH QString("/usr/test_prints/")
#define FIRMWARE_FOLDER_PATH QString("/home/firmware")
#define USB_STORAGE_DEV_BY_PATH_FRNT_PNL \
QString("/dev/disk/by-path/platform-xhci-hcd.1.auto-usb-0:1.1:1.0-scsi-0:0:0:0")
// MOBO_PORT_2 and MOBO_PORT_3 introduced with motherboard rev-6 (Sunflower)
#define USB_STORAGE_DEV_BY_PATH_MOBO_PORT_2 \
QString("/dev/disk/by-path/platform-xhci-hcd.1.auto-usb-0:1.2:1.0-scsi-0:0:0:0")
#define USB_STORAGE_DEV_BY_PATH_MOBO_PORT_3 \
QString("/dev/disk/by-path/platform-xhci-hcd.1.auto-usb-0:1.3:1.0-scsi-0:0:0:0")
#define USB_STORAGE_DEV_BY_PATH_WITH_ACCESSORY_PORT_1 \
QString("/dev/disk/by-path/platform-xhci-hcd.1.auto-usb-0:1.1.1:1.0-scsi-0:0:0:0")
#define USB_STORAGE_DEV_BY_PATH_WITH_ACCESSORY_PORT_2 \
QString("/dev/disk/by-path/platform-xhci-hcd.1.auto-usb-0:1.1.2:1.0-scsi-0:0:0:0")
#define MACHINE_PID_PATH std::string("/usr/settings/PID")
#endif

class PrintFileInfo : public QObject {
  Q_OBJECT

  Q_PROPERTY(QString filePath READ filePath NOTIFY fileInfoChanged)
  Q_PROPERTY(QString fileName READ fileName NOTIFY fileInfoChanged)
  Q_PROPERTY(QString fileBaseName READ fileBaseName NOTIFY fileInfoChanged)
  Q_PROPERTY(QDateTime fileLastRead READ fileLastRead NOTIFY fileInfoChanged)
  Q_PROPERTY(bool isDir READ isDir NOTIFY fileInfoChanged)

  // see morepork-libtinything/include/tinything/TinyThingReader.hh for a
  // complete list of the available meta items.
  Q_PROPERTY(bool extruderUsedA READ extruderUsedA NOTIFY fileInfoChanged)
  Q_PROPERTY(float extruderUsedB READ extruderUsedB NOTIFY fileInfoChanged)
  Q_PROPERTY(float extrusionMassGramsA READ extrusionMassGramsA NOTIFY fileInfoChanged)
  Q_PROPERTY(float extrusionMassGramsB READ extrusionMassGramsB NOTIFY fileInfoChanged)
  Q_PROPERTY(int extruderTempCelciusA READ extruderTempCelciusA NOTIFY fileInfoChanged)
  Q_PROPERTY(int extruderTempCelciusB READ extruderTempCelciusB NOTIFY fileInfoChanged)
  Q_PROPERTY(int chamberTempCelcius READ chamberTempCelcius NOTIFY fileInfoChanged)
  Q_PROPERTY(int buildplaneTempCelcius READ buildplaneTempCelcius NOTIFY fileInfoChanged)
  Q_PROPERTY(int buildplatformTempCelcius READ buildplatformTempCelcius NOTIFY fileInfoChanged)
  Q_PROPERTY(int numShells READ numShells NOTIFY fileInfoChanged)
  Q_PROPERTY(float layerHeightMM READ layerHeightMM NOTIFY fileInfoChanged)
  Q_PROPERTY(float infillDensity READ infillDensity NOTIFY fileInfoChanged)
  Q_PROPERTY(float timeEstimateSec READ timeEstimateSec NOTIFY fileInfoChanged)
  Q_PROPERTY(bool usesSupport READ usesSupport NOTIFY fileInfoChanged)
  Q_PROPERTY(bool usesRaft READ usesRaft NOTIFY fileInfoChanged)
  Q_PROPERTY(QString materialA READ materialA NOTIFY fileInfoChanged)
  Q_PROPERTY(QString materialB READ materialB NOTIFY fileInfoChanged)
  Q_PROPERTY(QString slicerName READ slicerName NOTIFY fileInfoChanged)

  QString file_name_, file_path_, file_base_name_;
  QDateTime file_last_read_;
  bool is_dir_;
  bool extruder_used_a_, extruder_used_b_;
  float extrusion_mass_grams_a_, extrusion_mass_grams_b_;
  int extruder_temp_celcius_a_, extruder_temp_celcius_b_,
      chamber_temp_celcius_, buildplane_temp_celcius_,
      buildplatform_temp_celcius_, num_shells_;
  float layer_height_mm_, infill_density_, time_estimate_sec_;
  bool uses_support_, uses_raft_;
  QString material_a_, material_b_, slicer_name_;

  public:
    //MOREPORK_QML_ENUM
    enum StorageSortType {
        Alphabetic,
        DateAdded,
        PrintTime
    };
    Q_ENUM(StorageSortType)

    PrintFileInfo(QObject *parent = 0) : QObject(parent) { }
    PrintFileInfo(const QString &file_path,
                  const QString &file_name,
                  const QString &file_base_name,
                  const QDateTime &file_last_read,
                  const bool &is_dir,
                  const bool extruder_used_a = false,
                  const bool extruder_used_b = false,
                  const float extrusion_mass_grams_a = 0.0f,
                  const float extrusion_mass_grams_b = 0.0f,
                  const int extruder_temp_celcius_a = 0,
                  const int extruder_temp_celcius_b = 0,
                  const int chamber_temp_celcius = 0,
                  const int buildplane_temp_celcius = 0,
                  const int buildplatform_temp_celcius = 0,
                  const int num_shells = 0,
                  const float layer_height_mm = 0.0f,
                  const float infill_density = 0.0f,
                  const float time_estimate_sec = 0.0f,
                  const bool uses_support = false,
                  const bool uses_raft = false,
                  const QString &material_a = "null",
                  const QString &material_b = "null",
                  const QString &slicer_name = "null",
                  QObject *parent = 0) :
                  QObject(parent),
                  file_path_(file_path),
                  file_name_(file_name),
                  file_base_name_(file_base_name),
                  file_last_read_(file_last_read),
                  is_dir_(is_dir),
                  extruder_used_a_(extruder_used_a),
                  extruder_used_b_(extruder_used_b),
                  extrusion_mass_grams_a_(extrusion_mass_grams_a),
                  extrusion_mass_grams_b_(extrusion_mass_grams_b),
                  extruder_temp_celcius_a_(extruder_temp_celcius_a),
                  extruder_temp_celcius_b_(extruder_temp_celcius_b),
                  chamber_temp_celcius_(chamber_temp_celcius),
                  buildplane_temp_celcius_(buildplane_temp_celcius),
                  buildplatform_temp_celcius_(buildplatform_temp_celcius),
                  num_shells_(num_shells),
                  layer_height_mm_(layer_height_mm),
                  infill_density_(infill_density),
                  time_estimate_sec_(time_estimate_sec),
                  uses_support_(uses_support),
                  uses_raft_(uses_raft),
                  material_a_(material_a),
                  material_b_(material_b),
                  slicer_name_(slicer_name) { }

    PrintFileInfo(const PrintFileInfo &rvalue) {
        file_path_ = rvalue.file_path_;
        file_name_ = rvalue.file_name_;
        file_base_name_ = rvalue.file_base_name_;
        file_last_read_ = rvalue.file_last_read_;
        is_dir_ = rvalue.is_dir_;
        extruder_used_a_ = rvalue.extruder_used_a_;
        extruder_used_b_ = rvalue.extruder_used_b_;
        extrusion_mass_grams_a_ = rvalue.extrusion_mass_grams_a_;
        extrusion_mass_grams_b_ = rvalue.extrusion_mass_grams_b_;
        extruder_temp_celcius_a_ = rvalue.extruder_temp_celcius_a_;
        extruder_temp_celcius_b_ = rvalue.extruder_temp_celcius_b_;
        chamber_temp_celcius_ = rvalue.chamber_temp_celcius_;
        buildplane_temp_celcius_ = rvalue.buildplane_temp_celcius_;
        buildplatform_temp_celcius_ = rvalue.buildplatform_temp_celcius_;
        num_shells_ = rvalue.num_shells_;
        layer_height_mm_ = rvalue.layer_height_mm_;
        infill_density_ = rvalue.infill_density_;
        time_estimate_sec_ = rvalue.time_estimate_sec_;
        uses_support_ = rvalue.uses_support_;
        uses_raft_ = rvalue.uses_raft_;
        material_a_ = rvalue.material_a_;
        material_b_ = rvalue.material_b_;
        slicer_name_ = rvalue.slicer_name_;
    }

    PrintFileInfo& operator=(const PrintFileInfo& rvalue){
        PrintFileInfo* temp = new PrintFileInfo(
                rvalue.file_path_,
                rvalue.file_name_,
                rvalue.file_base_name_,
                rvalue.file_last_read_,
                rvalue.is_dir_,
                rvalue.extruder_used_a_,
                rvalue.extruder_used_b_,
                rvalue.extrusion_mass_grams_a_,
                rvalue.extrusion_mass_grams_b_,
                rvalue.extruder_temp_celcius_a_,
                rvalue.extruder_temp_celcius_b_,
                rvalue.chamber_temp_celcius_,
                rvalue.buildplane_temp_celcius_,
                rvalue.buildplatform_temp_celcius_,
                rvalue.num_shells_,
                rvalue.layer_height_mm_,
                rvalue.infill_density_,
                rvalue.time_estimate_sec_,
                rvalue.uses_support_,
                rvalue. uses_raft_,
                rvalue.material_a_,
                rvalue.material_b_,
                rvalue.slicer_name_);
        return *temp;
    }

    QString filePath() const {
        return file_path_;
    }
    QString fileName() const {
        return file_name_;
    }
    QString fileBaseName() const {
        return file_base_name_;
    }
    QDateTime fileLastRead() const {
        return file_last_read_;
    }
    bool isDir() const {
        return is_dir_;
    }
    bool extruderUsedA() const {
        return extruder_used_a_;
    }
    bool extruderUsedB() const {
        return extruder_used_b_;
    }
    float extrusionMassGramsA() const {
        return extrusion_mass_grams_a_;
    }
    float extrusionMassGramsB() const {
        return extrusion_mass_grams_b_;
    }
    int extruderTempCelciusA() const {
        return extruder_temp_celcius_a_;
    }
    int extruderTempCelciusB() const {
        return extruder_temp_celcius_b_;
    }
    int chamberTempCelcius() const {
        return chamber_temp_celcius_;
    }
    int buildplaneTempCelcius() const {
        return buildplane_temp_celcius_;
    }
    int buildplatformTempCelcius() const {
        return buildplatform_temp_celcius_;
    }
    int numShells() const {
        return num_shells_;
    }
    float layerHeightMM() const {
        return layer_height_mm_;
    }
    float infillDensity() const {
        return infill_density_;
    }
    float timeEstimateSec() const {
        return time_estimate_sec_;
    }
    bool usesSupport() const {
        return uses_support_;
    }
    bool usesRaft() const {
        return uses_raft_;
    }
    QString materialA() const {
        return material_a_;
    }
    QString materialB() const {
        return material_b_;
    }
    QString slicerName() const {
        return slicer_name_;
    }

    static bool fileNameLessThan(const QObject *a, const QObject *b){
        return static_cast<const PrintFileInfo*>(a)->fileName() <
               static_cast<const PrintFileInfo*>(b)->fileName();
    }

    static bool accessDateGreaterThan(const QObject *a, const QObject *b){
        return static_cast<const PrintFileInfo*>(a)->fileLastRead().toSecsSinceEpoch() >
               static_cast<const PrintFileInfo*>(b)->fileLastRead().toSecsSinceEpoch();
    }

    static bool timeEstimateSecLessThan(const QObject *a, const QObject *b){
        return static_cast<const PrintFileInfo*>(a)->timeEstimateSec() <
               static_cast<const PrintFileInfo*>(b)->timeEstimateSec();
    }

    signals:
      void fileInfoChanged();
};


class ThumbnailPixmapProvider : public QQuickImageProvider {
  enum ThumbnailWidth {
      Small = 140,
      Medium = 212,
      Large = 960
  };

  public:
    ThumbnailPixmapProvider() :
      QQuickImageProvider(QQuickImageProvider::Pixmap) {}
    QPixmap requestPixmap(const QString &kAbsoluteFilePath, QSize *size,
      const QSize &requestedSize);
};

class MoreporkStorage : public QObject {
  Q_OBJECT
  public:
    // MOREPORK_QML_ENUM
    enum StorageFileType {
      Print,
      Firmware
    };
    Q_ENUM(StorageFileType)

    QList<QObject*> print_file_list_;
    PrintFileInfo* current_thing_;
    MoreporkStorage();
    Q_PROPERTY(const QString usbStoragePath CONSTANT MEMBER usbStoragePath);
    Q_INVOKABLE void updateFirmwareFileList(const QString directory_path);
    Q_INVOKABLE void copyFirmwareToDisk(const QString file_path);
    Q_INVOKABLE void copyPrintFile(const QString source);
    PrintFileInfo* createPrintFileObject(const QFileInfo kFileInfo);
    Q_INVOKABLE void updatePrintFileList(const QString kDirectory);
    Q_INVOKABLE void deletePrintFile(QString file_name);
    Q_PROPERTY(QList<QObject*> printFileList
      READ printFileList
      WRITE printFileListSet
      RESET printFileListReset
      NOTIFY printFileListChanged)
    QList<QObject*> printFileList() const;
    void printFileListSet(const QList<QObject*> &print_file_list);
    void printFileListReset();
    Q_INVOKABLE bool updateCurrentThing();
    Q_PROPERTY(PrintFileInfo* currentThing
      READ currentThing
      WRITE currentThingSet
      RESET currentThingReset)
    PrintFileInfo* currentThing() const;
    void currentThingSet(PrintFileInfo* current_thing);
    Q_INVOKABLE void currentThingReset();
    Q_INVOKABLE void backStackPush(const QString kDirPath);
    Q_INVOKABLE QString backStackPop();
    Q_INVOKABLE void backStackClear();

    Q_INVOKABLE void cancelCopy();
    Q_INVOKABLE bool firmwareIsValid(const QString file_path);
    Q_INVOKABLE void setStorageFileType(
            const MoreporkStorage::StorageFileType type);
    void setMachinePid();

    Q_INVOKABLE void getTestPrint(const QString test_print_dir,
                                  const QString test_print_name);

  private:
    QFileSystemWatcher *storage_watcher_;
    QFileSystemWatcher *usb_storage_watcher_;
    QStack<QString> back_dir_stack_;
    QString prev_thing_dir_;
    QPointer<ProgressCopy> prog_copy_;
    const QString usbStoragePath;
    int machine_pid_;

    MODEL_PROP(bool, usbStorageConnected, false)
    MODEL_PROP(bool, storageIsEmpty, true)
    MODEL_PROP(bool, fileIsCopying, false)
    MODEL_PROP(double, fileCopyProgress, 0)
    MODEL_PROP(bool, fileCopySucceeded, false)
    MODEL_PROP(PrintFileInfo::StorageSortType, sortType,
               PrintFileInfo::StorageSortType::DateAdded)
    MODEL_PROP(MoreporkStorage::StorageFileType, storageFileType,
               MoreporkStorage::StorageFileType::Print)

  private slots:
    void updateUsbStorageConnected();
    void newSortType();
    void setFileCopyProgress(double progress);
    void setFileCopySucceeded(bool success);

  signals:
    void printFileListChanged();
    void cancelCopyThread();
};

#endif //__MOREPORK_STORAGE_H__

