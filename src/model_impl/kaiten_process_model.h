// Copyright 2017 Makerbot Industries

#ifndef _SRC_KAITEN_PROCESS_MODEL_H
#define _SRC_KAITEN_PROCESS_MODEL_H

#include <jsoncpp/json/value.h>
#include "model/process_model.h"

class KaitenProcessModel : public ProcessModel {
  public:
    void procUpdate(const Json::Value & proc);
    void asstLevelUpdate(const Json::Value & update);
};

#endif  // _SRC_KAITEN_PROCESS_MODEL_H
