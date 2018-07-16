// Copyright 2017 Makerbot Industries

#include "bot_logger.h"
#include "logging.h"

class BotLogger : public Logger {
  public:
    void info(QString msg) {
        LOG(info) << msg.toStdString();
    }
};

Logger * makeBotLogger() {
    Logging::ChangeGeneralLevel("info");
    Logging::Initialize("printer", "ui", "ui_telem");

    return dynamic_cast<Logger*>(new BotLogger());
}
