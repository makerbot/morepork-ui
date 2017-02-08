// Copyright 2017 Makerbot Industries

#include "kaiten_net_model.h"

#include "impl_util.h"

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
}
