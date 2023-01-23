// Copyright 2017 Makerbot Industries

#include "kaiten_net_model.h"

#include "impl_util.h"

#include "get_mac_addr_qt.h"
#include "logging.h"

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
    const Json::Value &wifiList = result["result"];
    const Json::Value &error = result["error"];

    // wifi_scan() part
    if (wifiList.isArray() && wifiList.size() > 0) {
        QList<QObject*> wifi_list;
        wifi_list.clear();

        for (Json::Value ap : wifiList) {
            if (ap.isObject()) {
                // Remove hidden networks from the list by name
                QString name = ap["name"].asString().c_str();
                if(!name.isEmpty()) {
                    QString password = ap["password"].asString().c_str();
                    bool password_req = (password == "none" ? false : true);
                    bool password_saved = (password == "stored" ? true : false);
                    QString path = ap["path"].asString().c_str();
                    int sig_strength = ap["strength"].asInt();
                    wifi_list.append(new WiFiAP(name, password_req, password_saved,
                                                path, sig_strength));
                }
            }
        }

        if (wifi_list.empty()) {
            WiFiListReset();
        } else {
            WiFiListSet(wifi_list);
        }
        wifiSearchingSet(false);
    }

    // wifi_connect(...) part
    if (error.isObject()) {
        const Json::Value &kMessage = error["message"];
        if (kMessage.isString()) {
            const QString errStr = kMessage.asString().c_str();
            if (errStr == "invalid wifi password") {
                wifiErrorSet(WifiError::InvalidPassword);
            } else if (errStr == "wifi error") {
                wifiErrorSet(WifiError::ConnectFailed);
            } else if (errStr == "dbus method error") {
                wifiErrorSet(WifiError::ScanFailed);
            } else {
                wifiErrorSet(WifiError::UnknownError);
                LOG(error) << result.toStyledString();
            }
        }
    }
}

void KaitenNetModel::setWifiSearching() {
    wifiSearchingSet(true);
}

void KaitenNetModel::cloudServicesInfoUpdate(const Json::Value &result) {
    if(result.isObject()) {
        const Json::Value &enabled = result["analytics_enabled"];
        if (enabled.empty()) {
            // 'None' should be interpreted as 'true' as it means
            // analytics will be shared when a makerbot account is
            // connected with the printer, which is most likely to be
            // the case for majority of users.
            analyticsEnabledSet(true);
        } else {
            analyticsEnabledSet(enabled.asBool());
        }
    }
}

void KaitenNetModel::printQueueUpdate(const Json::Value &queue) {
    if (queue.isArray()) {
        QList<QObject*> print_queue_list;
        print_queue_list.clear();

        for (Json::Value print : queue) {
            if (print.isObject() && !print.empty()) {
                QString filename = print["filename"].asString().c_str();
                QString job_id = print["job_id"].asString().c_str();
                QString token = print["token"].asString().c_str();
                QString url_prefix = print["url_prefix"].asString().c_str();
                print_queue_list.append(new QueuedPrintInfo(filename, job_id,
                                                    token, url_prefix));
            }
        }

        if (print_queue_list.empty()) {
            printQueueEmptyReset();
        } else {
            printQueueEmptySet(false);
        }
        PrintQueueSet(print_queue_list);
    }
}
