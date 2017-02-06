// Copyright 2017 Makerbot Industries

#ifndef _SRC_BOT_MODEL_H
#define _SRC_BOT_MODEL_H

#include <QObject>

#include "base_model.h"
#include "net_model.h"

// The top level API for our bot model.  We don't allow direct instantiation
// because this doesn't initialize submodels.
class BotModel : public BaseModel {
    Q_OBJECT
    SUBMODEL(NetModel, net);
    MODEL_PROP(QString, name, "Unknown")
  protected:
    BotModel();
};

// Make a dummy implementation of the API with all submodels filled in.
BotModel * makeBotModel();

#endif  // _SRC_BOT_MODEL_H
