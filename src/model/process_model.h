// Copyright 2017 Makerbot Industries

#ifndef _SRC_PROCESS_MODEL_H
#define _SRC_PROCESS_MODEL_H

#include <QObject>
#include "base_model.h"

class ProcessModel : public BaseModel {
  public:
    //MOREPORK_QML_ENUM
    enum ProcessType {
        None,
        Print,
        Load,
        Unload,
        Other
    };
    //MOREPORK_QML_ENUM
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
    // 'nameStr' holds the value of params["info"]["current_process"]["name"]
    MODEL_PROP(QString, nameStr, "Unknown")
    // 'stepStr' holds the value of params["info"]["current_process"]["step"]
    MODEL_PROP(QString, stepStr, "Unknown")
    // 'type' is based on the value of params["info"]["current_process"]["name"]
    MODEL_PROP(ProcessType, type, None)
    // 'stateType' is based on the value of params["info"]["current_process"]["step"]
    MODEL_PROP(ProcessStateType, stateType, Loading)
    MODEL_PROP(int, printPercentage, 0)
    MODEL_PROP(QString, timeRemaining, "00:00:00")

  public:
    ProcessModel();
};

#endif  // _SRC_PROCESS_MODEL_H

