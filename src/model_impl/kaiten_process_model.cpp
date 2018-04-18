// Copyright 2017 Makerbot Industries

#include "kaiten_process_model.h"
#include "impl_util.h"
#include "gui_helpers.h"

void KaitenProcessModel::procUpdate(const Json::Value &proc) {
    if (!proc.isObject()) {
        reset();
        return;
    }

    const Json::Value &kName = proc["name"];
    if (kName.isString()) {
        const QString kNameStr = kName.asString().c_str();
        nameStrSet(kNameStr);
        if (kNameStr == "PrintProcess")
            typeSet(ProcessType::Print);
        else if (kNameStr == "LoadFilamentProcess")
            typeSet(ProcessType::Load);
        else if (kNameStr == "UnloadFilamentProcess")
            typeSet(ProcessType::Unload);
        else if (kNameStr == "SombreroAssistedLevelingProcess")
            typeSet(ProcessType::AssistedLeveling);
        else if (kNameStr == "FirmwareBurningProcess")
            typeSet(ProcessType::FirmwareUpdate);
        else
            typeSet(ProcessType::Other);
    }
    else {
        typeSet(ProcessType::Other);
    }

    const Json::Value &kStep = proc["step"];
    if (kStep.isString()) {
        const QString kStepStr = kStep.asString().c_str();
        stepStrSet(kStepStr);
        // 'Print' states (steps)
        // see morepork-kaiten/kaiten/src/kaiten/processes/printprocess.py
        if (kStepStr == "initializing" ||
            kStepStr == "initial_heating" ||
            kStepStr == "final_heating" ||
            kStepStr == "cooling" ||
            kStepStr == "homing" ||
            kStepStr == "position_found" ||
            kStepStr == "preheating_resuming" ||
            kStepStr == "waiting_for_file" ||
            kStepStr == "transfer")
            stateTypeSet(ProcessStateType::Loading);
        else if (kStepStr == "suspended")
            stateTypeSet(ProcessStateType::Paused);
        else if (kStepStr == "printing")
            stateTypeSet(ProcessStateType::Printing);
        else if (kStepStr == "failed")
            stateTypeSet(ProcessStateType::Failed);
        else if (kStepStr == "completed")
            stateTypeSet(ProcessStateType::Completed);
        // 'Load' and 'Unload' states (steps)
        // see morepork-kaiten/kaiten/src/kaiten/processes/loadfilamentprocess.py
        else if (kStepStr == "preheating")
            stateTypeSet(ProcessStateType::Preheating);
        else if (kStepStr == "extrusion")
            stateTypeSet(ProcessStateType::Extrusion);
        else if (kStepStr == "stopping")
            stateTypeSet(ProcessStateType::Stopping);
        else if (kStepStr == "unloading_filament")
            stateTypeSet(ProcessStateType::UnloadingFilament);
        // Base class 'Process' states (steps)
        // see morepork-kaiten/kaiten/src/kaiten/processes/process.py
        else if (kStepStr == "done")
            stateTypeSet(ProcessStateType::Done);
        // Firmware Updating States
        // see morepork-kaiten/kaiten/src/kaiten/processes/firmwareburningprocess.py
        else if (kStepStr == "downloading")
        //Another possible step for firmwareUpdate is 'transfer' which is mapped to 'Loading' 
            stateTypeSet(ProcessStateType::TransferringFirmware);
        else if (kStepStr == "verify_firmware")
            stateTypeSet(ProcessStateType::VerifyingFirmware);
        else if (kStepStr == "writing")
            stateTypeSet(ProcessStateType::InstallingFirmware);
        // Assisted Leveling States
        // see morepork-kaiten/kaiten/src/kaiten/processes/sombreroassistedlevelingprocess.py
        else if (kStepStr == "checking_first_point")
            stateTypeSet(ProcessStateType::CheckFirstPoint);
        else if (kStepStr == "checking_left_level")
            stateTypeSet(ProcessStateType::CheckLeftLevel);
        else if (kStepStr == "checking_right_level")
            stateTypeSet(ProcessStateType::CheckRightLevel);
        else if (kStepStr == "finishing_level")
            stateTypeSet(ProcessStateType::LevelingComplete)
        else
            stateTypeReset();
    }

    const Json::Value &error = proc["error"];
    if (error.isObject()) {
        UPDATE_INT_PROP(errorCode, error["code"]);
    } else {
        errorCodeReset();
    }

    UPDATE_INT_PROP(printPercentage, proc["progress"]);
    UPDATE_INT_PROP(timeRemaining, proc["time_remaining"]);
    activeSet(true);
}

void KaitenProcessModel::printFileUpdate(const Json::Value &printFileDetails) {
    printFileValidSet(true);
}

void KaitenProcessModel::asstLevelUpdate(const Json::Value & update) {
    if(!update.empty()) {
        UPDATE_FLOAT_PROP(levelState, update["level_state"]);
        UPDATE_FLOAT_PROP(currentHes, update["current_hes"]);
        UPDATE_FLOAT_PROP(targetHesUpper, update["target_hes_upper"]);
        UPDATE_FLOAT_PROP(targetHesLower, update["target_hes_lower"]);
    }
}
