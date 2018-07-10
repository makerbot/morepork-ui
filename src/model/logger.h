// Copyright 2017 Makerbot Industries

#ifndef _SRC_LOGGER_H
#define _SRC_LOGGER_H

#include <QObject>
#include <QDebug>

#include "base_model.h"

// The top level API for our bot model.  We don't allow direct instantiation
// because this doesn't initialize submodels.
class Logger : public QObject {
    Q_OBJECT
  public:
    Logger();

  protected:
    Q_INVOKABLE virtual void info(QString msg);
};

Logger * makeLogger();

#endif  // _SRC_LOGGER_H


