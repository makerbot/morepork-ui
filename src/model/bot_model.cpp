// Copyright 2017 Makerbot Industries

#include "bot_model.h"
#include "error_utils.h"


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

void BotModel::loadFilament(const int kToolIndex) {
    qDebug() << FL_STRM << "called with tool_index: " << kToolIndex;
}

void BotModel::loadFilamentStop() {
    qDebug() << FL_STRM << "called";
}

void BotModel::unloadFilament(const int kToolIndex) {
    qDebug() << FL_STRM << "called with tool_index: " << kToolIndex;
}

void BotModel::assistedLevel() {
    qDebug() << FL_STRM << "called";
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
