// Copyright 2017 Makerbot Industries

#include "logger.h"

Logger::Logger() {
}

void Logger::info(QString msg) {
    qInfo() << msg;
}

class DummyLogger : public Logger {
  public:
    DummyLogger() {
    }
};

Logger * makeLogger() {
    return dynamic_cast<Logger*>(new DummyLogger());
}
