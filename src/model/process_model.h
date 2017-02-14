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
    Q_ENUM(ProcessType)
  private:
    Q_OBJECT
    MODEL_PROP(bool, active, false)
    MODEL_PROP(ProcessType, type, None)
    MODEL_PROP(QString, typeStr, "Unknown")
    MODEL_PROP(QString, stepStr, "Unknown")
  public:
    ProcessModel();
};

#endif  // _SRC_PROCESS_MODEL_H
