// Copyright 2017 Makerbot Industries

#include "kaiten_process_model.h"
#include "impl_util.h"
#include "gui_helpers.h"

void KaitenProcessModel::procUpdate(const Json::Value &proc) {
    if (!proc.isObject()) {
        reset();
        return;
    }
    const Json::Value kJsonTimeRemain = proc["time_remaining"];
    if(kJsonTimeRemain.isInt()){
        const QString kTimeRemainStr = guihelpers::duration(kJsonTimeRemain.asInt());
        timeRemainingSet(kTimeRemainStr);
    }
    auto name(proc["name"]);
    if (name.isString()) {
        auto nameStr(name.asString());
        if (nameStr == "PrintProcess")
            typeSet(Print);
        else if (nameStr == "LoadFilamentProcess")
            typeSet(Load);
        else if (nameStr == "UnloadFilamentProcess")
            typeSet(Unload);
        else
            typeSet(Other);
    }
    else {
        typeSet(Other);
    }
    UPDATE_STRING_PROP(typeStr, name);
    UPDATE_STRING_PROP(stepStr, proc["step"]);
    activeSet(true);
}
