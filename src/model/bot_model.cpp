// Copyright 2017 Makerbot Industries

#include "bot_model.h"
#include "../error_utils.h"

BotModel::BotModel() {
    reset();
}

void BotModel::cancel() {
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
