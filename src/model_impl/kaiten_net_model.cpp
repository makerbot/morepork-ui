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
    QString eth_mac_addr, wlan_mac_addr;
    getMacAddress(eth_mac_addr, wlan_mac_addr);
    ethMacAddrSet(eth_mac_addr.toUtf8().constData());
    wlanMacAddrSet(wlan_mac_addr.toUtf8().constData());
    UPDATE_STRING_ARRAY_PROP(dns, state["dns"])
}
