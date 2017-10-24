// Copyright 2017 Makerbot Industries

#include <QDirIterator>
#include <QList>
#include "bot_model.h"
#include "../error_utils.h"

#ifdef MOREPORK_UI_QT_CREATOR_BUILD
// desktop linux path
#define THINGS_DIR QString("/home/")+qgetenv("USER")+"/things"
#else
// embedded linux path
#define THINGS_DIR QString("/home/things")
#endif

BotModel::BotModel() {
    reset();
}

void BotModel::cancel() {
    qDebug() << FL_STRM << "called";
}

void BotModel::pausePrint() {
    qDebug() << FL_STRM << "called";
}

void BotModel::print(QString file_name) {
    qDebug() << FL_STRM << "called with file name: " << file_name;
}

void BotModel::updateInternalStorageFileList(){
  qDebug() << FL_STRM << "called";
  QStringList file_list;
  QDirIterator it(THINGS_DIR, QDirIterator::Subdirectories);
  while(it.hasNext())
      if(QFileInfo(it.next()).suffix() == "makerbot")
          file_list.push_back(it.fileInfo().fileName());
  if(file_list.size() > 0)
      internalStorageFileListSet(file_list);
  else
      internalStorageFileListReset();
}

class DummyBotModel : public BotModel {
  public:
    DummyBotModel() {
        m_net.reset(new NetModel());
        m_process.reset(new ProcessModel());
    }
};

void BotModel::deletePrintFile(QString file_name){
    qDebug() << FL_STRM << "called with file name: " << file_name;
    QString abs_file_path = THINGS_DIR + "/" + file_name;
    QFileInfo file_info(abs_file_path);
    EXP_CHK(file_info.exists() && file_info.suffix() == "makerbot", return)
    QFile file(abs_file_path);
    file.remove();
}

BotModel * makeBotModel() {
    return dynamic_cast<BotModel *>(new DummyBotModel());
}
