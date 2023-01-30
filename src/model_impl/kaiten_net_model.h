// Copyright 2017 Makerbot Industries

#ifndef _SRC_KAITEN_NET_MODEL_H
#define _SRC_KAITEN_NET_MODEL_H

#include <jsoncpp/json/value.h>
#include "model/net_model.h"

class KaitenNetModel : public NetModel {
  public:
    void sysInfoUpdate(const Json::Value & info);
    void netUpdate(const Json::Value & state);
    void wifiUpdate(const Json::Value &result);
    void cloudServicesInfoUpdate(const Json::Value &result);
    void printQueueUpdate(const Json::Value &queue);
    void setWifiSearching();
};

#endif  // _SRC_KAITEN_NET_MODEL_H
