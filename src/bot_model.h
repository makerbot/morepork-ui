// Copyright 2017 Makerbot Industries

#ifndef _SRC_BOT_MODEL_H
#define _SRC_BOT_MODEL_H

#include <QObject>

#include "base_model.h"

class BotModel : public BaseModel {
    Q_OBJECT
    MODEL_PROP(QString, ipAddr, "Unknown")
    MODEL_PROP(QString, name, "Unknown")
  public:
    BotModel();
};

#endif  // _SRC_BOT_MODEL_H
