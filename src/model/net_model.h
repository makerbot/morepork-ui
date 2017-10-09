// Copyright 2017 Makerbot Industries

#ifndef _SRC_NET_MODEL_H
#define _SRC_NET_MODEL_H

#include <QObject>

#include "base_model.h"

class NetModel : public BaseModel {
    Q_OBJECT
    MODEL_PROP(QString, ipAddr, "Unknown")
    MODEL_PROP(QString, netmask, "Unknown")
    MODEL_PROP(QString, gateway, "Unknown")
    MODEL_PROP(QString, interface, "Unknown")
    MODEL_PROP(QString, ethMacAddr, "Unknown")
    MODEL_PROP(QString, wlanMacAddr, "Unknown")
    MODEL_PROP(QStringList, dns, {"Unknown"})
  public:
    NetModel();
};

#endif  // _SRC_NET_MODEL_H
