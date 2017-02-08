// Copyright 2017 Makerbot Industries

#include "bot_model.h"

BotModel::BotModel() {
    reset();
}

class DummyBotModel : public BotModel {
  public:
    DummyBotModel() {
        m_net.reset(new NetModel());
    }
};

BotModel * makeBotModel() {
    return dynamic_cast<BotModel *>(new DummyBotModel());
}
