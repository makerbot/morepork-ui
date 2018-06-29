// Copyright 2017 Makerbot Industries

#include "kaiten_net_model.h"

#include "impl_util.h"

#include "get_mac_addr_qt.h"

void KaitenNetModel::sysInfoUpdate(const Json::Value &info) {
    UPDATE_STRING_PROP(ipAddr, info["ip"]);
}

void KaitenNetModel::netUpdate(const Json::Value &state) {
    if (!state.isObject()) {
        reset();
        return;
    }
    UPDATE_STRING_PROP(ipAddr, state["ip"]);
    UPDATE_STRING_PROP(netmask, state["netmask"]);
    UPDATE_STRING_PROP(gateway, state["gateway"]);
    UPDATE_STRING_PROP(interface, state["state"]);
    UPDATE_STRING_PROP(name, state["name"]);

    const Json::Value &kIface = state["state"];
    if (kIface.isString()) {
        const QString kIfaceStr = kIface.asString().c_str();
        if (kIfaceStr == "wifi")
            wifiStateSet(WifiState::Connected);
        else if(kIfaceStr == "ethernet" ||
                kIfaceStr == "offline")
            wifiStateSet(WifiState::NotConnected);
    }

    QString eth_mac_addr, wlan_mac_addr;
    getMacAddress(eth_mac_addr, wlan_mac_addr);
    ethMacAddrSet(eth_mac_addr.toUtf8().constData());
    wlanMacAddrSet(wlan_mac_addr.toUtf8().constData());
    UPDATE_STRING_ARRAY_PROP(dns, state["dns"])
    const Json::Value &kWifi = state["wifi"];
    if (kWifi.isString()) {
        const QString kWifiState = kWifi.asString().c_str();
        if (kWifiState == "enabled")
            wifiEnabledSet(true);
        else if(kWifiState == "disabled")
            wifiEnabledSet(false);
    }
}

void KaitenNetModel::wifiUpdate(const Json::Value &result) {
    wifiErrorSet(WifiError::NoError);
    const Json::Value &kWifiList = result["result"];
    const Json::Value &kError = result["error"];

    // wifi_scan() part
    if(kWifiList.isArray() && kWifiList.size() > 0) {

        QList<QObject*> wifi_list;
        wifi_list.clear();

        for(Json::Value ap : kWifiList) {
            if(ap.isObject()) {
                QString name = ap["name"].asString().c_str();
                QString password = ap["password"].asString().c_str();
                bool password_req = (password == "none" ? false : true);
                bool password_saved = (password == "stored" ? true : false);
                QString path = ap["path"].asString().c_str();
                int sig_strength = ap["strength"].asInt();
                wifi_list.append(new WiFiAP(name, password_req, password_saved,
                                            path, sig_strength));
            }
        }

        if(wifi_list.empty()) {
            wifiStateSet(WifiState::NoWifiFound);
            WiFiListReset();
        } else {
            wifiStateSet(WifiState::NotConnected);
            WiFiListSet(wifi_list);
        }
    }

    // wifi_connect(...) part
    if(kError.isObject()) {
        const Json::Value &kMessage = kError["message"];
        if(kMessage.isString()) {
            const QString kErrStr = kMessage.asString().c_str();
            if(kErrStr == "invalid wifi password") {
                wifiErrorSet(WifiError::InvalidPassword);
            }
            else if(kErrStr == "wifi error") {
                wifiErrorSet(WifiError::ConnectFailed);
            }
        }
    }
}
