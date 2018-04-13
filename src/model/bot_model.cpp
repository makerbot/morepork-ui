// Copyright 2017 Makerbot Industries

#include "bot_model.h"
#include "error_utils.h"


BotModel::BotModel() {
    reset();
}

void BotModel::cancel() {
    qDebug() << FL_STRM << "called";
}

void BotModel::pauseResumePrint(QString action) {
    qDebug() << FL_STRM << "called with action: " << action;
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

void BotModel::respondAuthRequest(QString response) {
    qDebug() << FL_STRM << "called with response: " << response;
}

void BotModel::firmwareUpdateCheck(bool dont_force_check) {
    qDebug() << FL_STRM << "called with parameter: " << dont_force_check;
}

void BotModel::installFirmware() {
    qDebug() << FL_STRM << "called";
}

void BotModel::calibrateToolheads(QList<QString> toolheads, QList<QString> axes) {
    qDebug() << FL_STRM << "called";
    qDebug() << "Toolheads Requested:";
    for(int i = 0; i < toolheads.size(); i++) {
        qDebug() << toolheads.value(i);
    }
    qDebug() << "Axes Requested:";
    for(int i = 0; i < axes.size(); i++) {
        qDebug() << axes.value(i);
    }
}

void BotModel::buildPlateState(bool state) {
    qDebug() << FL_STRM << "called with parameter: " << state;
}

void BotModel::acknowledge_level() {
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
