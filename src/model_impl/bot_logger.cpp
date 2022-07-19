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
    Logging::Initialize("printer", 10, "ui", 10, "ui_telem");
    Logging::ChangeGeneralLevel("info");

    return dynamic_cast<Logger*>(new BotLogger());
}
