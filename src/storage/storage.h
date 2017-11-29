#ifndef __MOREPORK_STORAGE_H__
#define __MOREPORK_STORAGE_H__

#include <QFileSystemWatcher>
#include <QList>
#include <QDebug>
#include <QDirIterator>
#include <QImage>
#include <QQuickImageProvider>
#include <QStack>

#ifdef MOREPORK_UI_QT_CREATOR_BUILD
// desktop linux path
#define THINGS_DIR QString("/home/")+qgetenv("USER")+"/things"
#else
// embedded linux path
#define THINGS_DIR QString("/home/things")
#endif


class PrintFileInfo : public QObject {
  Q_OBJECT

  Q_PROPERTY(QString filePath READ filePath NOTIFY fileInfoChanged)
  Q_PROPERTY(QString fileName READ fileName NOTIFY fileInfoChanged)
  Q_PROPERTY(QString fileBaseName READ fileBaseName NOTIFY fileInfoChanged)
  Q_PROPERTY(bool isDir READ isDir NOTIFY fileInfoChanged)

  // see morepork-libtinything/include/tinything/TinyThingReader.hh for a
  // complete list of the meta available meta items.
  Q_PROPERTY(float extrusionMassGramsA READ extrusionMassGramsA NOTIFY fileInfoChanged)
  Q_PROPERTY(float extrusionMassGramsB READ extrusionMassGramsB NOTIFY fileInfoChanged)
  Q_PROPERTY(int extruderTempCelciusA READ extruderTempCelciusA NOTIFY fileInfoChanged)
  Q_PROPERTY(int extruderTempCelciusB READ extruderTempCelciusB NOTIFY fileInfoChanged)
  Q_PROPERTY(int chamberTempCelcius READ chamberTempCelcius NOTIFY fileInfoChanged)
  Q_PROPERTY(int numShells READ numShells NOTIFY fileInfoChanged)
  Q_PROPERTY(float layerHeightMM READ layerHeightMM NOTIFY fileInfoChanged)
  Q_PROPERTY(float infillDensity READ infillDensity NOTIFY fileInfoChanged)
  Q_PROPERTY(float timeEstimateSec READ timeEstimateSec NOTIFY fileInfoChanged)
  Q_PROPERTY(bool usesSupport READ usesSupport NOTIFY fileInfoChanged)
  Q_PROPERTY(bool usesRaft READ usesRaft NOTIFY fileInfoChanged)
  Q_PROPERTY(QString materialNameA READ materialNameA NOTIFY fileInfoChanged)
  Q_PROPERTY(QString materialNameB READ materialNameB NOTIFY fileInfoChanged)
  Q_PROPERTY(QString slicerName READ slicerName NOTIFY fileInfoChanged)

  QString file_name_, file_path_, file_base_name_;
  bool is_dir_;
  float extrusion_mass_grams_a_, extrusion_mass_grams_b_;
  int extruder_temp_celcius_a_, extruder_temp_celcius_b_, chamber_temp_celcius_, num_shells_;
  float layer_height_mm_, infill_density_, time_estimate_sec_;
  bool uses_support_, uses_raft_;
  QString material_name_a_, material_name_b_, slicer_name_;

  public:
    PrintFileInfo(QObject *parent = 0) : QObject(parent) { }
    PrintFileInfo(const QString &file_path,
                  const QString &file_name,
                  const QString &file_base_name,
                  const bool &is_dir,
                  const float extrusion_mass_grams_a = 0.0f,
                  const float extrusion_mass_grams_b = 0.0f,
                  const int extruder_temp_celcius_a = 0,
                  const int extruder_temp_celcius_b = 0,
                  const int chamber_temp_celcius = 0,
                  const int num_shells = 0,
                  const float layer_height_mm = 0.0f,
                  const float infill_density = 0.0f,
                  const float time_estimate_sec = 0.0f,
                  const bool uses_support = false,
                  const bool uses_raft = false,
                  const QString &material_name_a = "null",
                  const QString &material_name_b = "null",
                  const QString &slicer_name = "null",
                  QObject *parent = 0) :
                  QObject(parent),
                  file_path_(file_path),
                  file_name_(file_name),
                  file_base_name_(file_base_name),
                  is_dir_(is_dir),
                  extrusion_mass_grams_a_(extrusion_mass_grams_a),
                  extrusion_mass_grams_b_(extrusion_mass_grams_b),
                  extruder_temp_celcius_a_(extruder_temp_celcius_a),
                  extruder_temp_celcius_b_(extruder_temp_celcius_b),
                  chamber_temp_celcius_(chamber_temp_celcius),
                  num_shells_(num_shells),
                  layer_height_mm_(layer_height_mm),
                  infill_density_(infill_density),
                  time_estimate_sec_(time_estimate_sec),
                  uses_support_(uses_support),
                  uses_raft_(uses_raft),
                  material_name_a_(material_name_a),
                  material_name_b_(material_name_b),
                  slicer_name_(slicer_name) { }

    QString filePath() const {
        return file_path_;
    }
    QString fileName() const {
        return file_name_;
    }
    QString fileBaseName() const {
        return file_base_name_;
    }
    bool isDir() const {
        return is_dir_;
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
    QString materialNameA() const {
        return material_name_a_;
    }
    QString materialNameB() const {
        return material_name_b_;
    }
    QString slicerName() const {
        return slicer_name_;
    }

    signals:
      void fileInfoChanged();
};


class ThumbnailPixmapProvider : public QQuickImageProvider {
  public:
    ThumbnailPixmapProvider() :
      QQuickImageProvider(QQuickImageProvider::Pixmap) {}
    QPixmap requestPixmap(const QString &kAbsoluteFilePath, QSize *size,
      const QSize &requestedSize);
};


class MoreporkStorage : public QObject {
  Q_OBJECT
  QFileSystemWatcher *storage_watcher_;
  QStack<QString> back_dir_stack_;

  public:
    QList<QObject*> print_file_list_;
    MoreporkStorage();
    Q_INVOKABLE void
      updateInternalStorageFileList(const QString kDirectory = "");
    Q_INVOKABLE void deletePrintFile(QString file_name);
    Q_PROPERTY(QList<QObject*> printFileList
      READ printFileList
      WRITE printFileListSet
      RESET printFileListReset
      NOTIFY printFileListChanged)
    QList<QObject*> printFileList() const;
    void printFileListSet(const QList<QObject*> &print_file_list);
    void printFileListReset();
    Q_INVOKABLE void backStackPush(const QString kDirPath);
    Q_INVOKABLE QString backStackPop();
    Q_INVOKABLE void backStackClear();

  signals:
    void printFileListChanged();
};

#endif //__MOREPORK_STORAGE_H__

