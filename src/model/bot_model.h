// Copyright 2017 Makerbot Industries

#ifndef _SRC_BOT_MODEL_H
#define _SRC_BOT_MODEL_H

#include <QObject>
#include <QDebug>

#include "base_model.h"
#include "net_model.h"
#include "process_model.h"

// The top level API for our bot model.  We don't allow direct instantiation
// because this doesn't initialize submodels.
class BotModel : public BaseModel {
  public:
    enum ConnectionState {
        Connecting,
        Connected,
        Disconnected,
        TimedOut
    };
    Q_ENUM(ConnectionState)
    Q_INVOKABLE virtual void cancelPrint();
  private:
    Q_OBJECT
    SUBMODEL(NetModel, net)
    SUBMODEL(ProcessModel, process)
    MODEL_PROP(QString, name, "Unknown")
    MODEL_PROP(QString, version, "Unknown")
    MODEL_PROP(ConnectionState, state, Connecting)
  protected:
    BotModel();
};

// Make a dummy implementation of the API with all submodels filled in.
BotModel * makeBotModel();

#endif  // _SRC_BOT_MODEL_H
