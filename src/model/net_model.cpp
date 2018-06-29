// Copyright 2017 Makerbot Industries

#include "net_model.h"

NetModel::NetModel() {
    reset();
}

void NetModel::setWifiState(WifiState state) {
    wifiStateSet(state);
}

QString WiFiAP::name() const {
    return name_;
}

bool WiFiAP::secured() const {
    return secured_;
}

bool WiFiAP::saved() const {
    return saved_;
}

QString WiFiAP::path() const {
    return path_;
}

int WiFiAP::sig_strength() const {
    return sig_strength_;
}

QList<QObject*> NetModel::WiFiList() const {
    return wifi_list_;
}

void NetModel::WiFiListSet(QList<QObject*> &wifi_list) {
    auto temp = wifi_list_;
    wifi_list_ = wifi_list;
    emit WiFiListChanged();
    qDeleteAll(temp);
    temp.clear();
}

void NetModel::WiFiListReset() {
    wifi_list_.clear();
}
