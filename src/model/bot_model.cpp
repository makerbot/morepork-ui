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

void BotModel::done(QString acknowledge_result) {
    qDebug() << FL_STRM << "called with acknowledge_result: " << acknowledge_result;
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

void BotModel::firmwareUpdateCheck(QString dont_force_check) {
    qDebug() << FL_STRM << "called with parameter: " << dont_force_check;
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
