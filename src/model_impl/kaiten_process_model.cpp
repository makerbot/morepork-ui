// Copyright 2017 Makerbot Industries

#include "kaiten_process_model.h"
#include "impl_util.h"
#include "gui_helpers.h"

void KaitenProcessModel::procUpdate(const Json::Value &proc) {
    if (!proc.isObject()) {
        reset();
        return;
    }

    const Json::Value &kJsonTimeRemain = proc["time_remaining"];
    if (kJsonTimeRemain.isInt()){
        const QString kTimeRemainStr = guihelpers::duration(kJsonTimeRemain.asInt());
        timeRemainingSet(kTimeRemainStr);
    }

    const Json::Value &kName = proc["name"];
    if (kName.isString()) {
        const QString kNameStr = kName.asString();
        nameStrSet(kNameStr);
        if (kNameStr == "PrintProcess")
            typeSet(Print);
        else if (kNameStr == "LoadFilamentProcess")
            typeSet(Load);
        else if (kNameStr == "UnloadFilamentProcess")
            typeSet(Unload);
        else
            typeSet(Other);
    }
    else {
        typeSet(Other);
    }

    const Json::Value &kStep = proc["step"];
    if (kStep.isString()) {
        const QString kStepStr = kStep.asString();
        stepStrSet(kStepStr);
        if (kStepStr == "initializing" ||
            kStepStr == "initial_heating" ||
            kStepStr == "final_heating" ||
            kStepStr == "cooling" ||
            kStepStr == "homing" ||
            kStepStr == "position_found" ||
            kStepStr == "preheating_resuming" ||
            kStepStr == "waiting_for_file" ||
            kStepStr == "transfer")
            stateTypeSet(Loading);
        else if (kStepStr == "suspended")
            stateTypeSet(Paused);
        else if (KStepStr == "printing")
            stateTypeSet(Printing);
    }

    activeSet(true);
}

