// Copyright 2017 Makerbot Industries

#include <QDirIterator>
#include <QList>
#include "bot_model.h"
#include "../error_utils.h"

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
#ifdef MOREPORK_UI_QT_CREATOR_BUILD
  // desktop linux path
  QDirIterator it(QString("/home/") + qgetenv("USER") + "/things", QDirIterator::Subdirectories);
#else
  // embedded linux path
  QDirIterator it("/home/things", QDirIterator::Subdirectories);
#endif
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

BotModel * makeBotModel() {
    return dynamic_cast<BotModel *>(new DummyBotModel());
}
