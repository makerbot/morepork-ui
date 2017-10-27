// Copyright 2017 Makerbot Industries

#ifndef _SRC_PROCESS_MODEL_H
#define _SRC_PROCESS_MODEL_H

#include <QObject>

#include "base_model.h"

class ProcessModel : public BaseModel {
  public:
    enum ProcessType {
        None,
        Print,
        Load,
        Unload,
        Other
    };
    enum ProcessStateType {
        Default,
        Loading,
        Printing,
        Paused,
        PrintComplete
    };
    Q_ENUM(ProcessType)
    Q_ENUM(ProcessStateType)
  private:
    Q_OBJECT
    MODEL_PROP(bool, active, false)
    MODEL_PROP(ProcessType, type, None)
    MODEL_PROP(ProcessStateType, stateType, Loading)
    MODEL_PROP(int, printPercentage, 0)
    MODEL_PROP(QString, typeStr, "Unknown")
    MODEL_PROP(QString, stepStr, "Unknown")
    MODEL_PROP(QString, timeRemaining, "00:00:00")
  public:
    ProcessModel();
};

#endif  // _SRC_PROCESS_MODEL_H
