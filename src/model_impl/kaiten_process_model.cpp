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
        else if (kNameStr == "NozzleCalibrationProcess")
            typeSet(ProcessType::CalibrationProcess);
        else if (kNameStr == "ResetToFactoryProcess")
            typeSet(ProcessType::FactoryResetProcess);
        else if (kNameStr == "ZipLogsProcess")
            typeSet(ProcessType::ZipLogsProcess);
        else
            typeSet(ProcessType::None);
    }
    else {
        typeSet(ProcessType::None);
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
        else if (kStepStr == "suspending")
            stateTypeSet(ProcessStateType::Pausing);
        else if (kStepStr == "unsuspending")
            stateTypeSet(ProcessStateType::Resuming);
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
        else if (kStepStr == "preheating" ||
                 kStepStr == "preheating_loading" ||
                 kStepStr == "preheating_unloading") //preheating while load/unload durng Print Process
            stateTypeSet(ProcessStateType::Preheating);
        else if (kStepStr == "extrusion" ||
                 kStepStr == "loading_filament") //extrusion while load/unload during Print Process
            stateTypeSet(ProcessStateType::Extrusion);
        else if (kStepStr == "stopping" ||
                 kStepStr == "stopping_filament") //stopping while load/unload during Print Process
            stateTypeSet(ProcessStateType::Stopping);
        else if (kStepStr == "unloading_filament") //regular unloading & also during Print Process
            stateTypeSet(ProcessStateType::UnloadingFilament);
        // Base class 'Process' states (steps)
        // see morepork-kaiten/kaiten/src/kaiten/processes/process.py
        else if (kStepStr == "running")
            stateTypeSet(ProcessStateType::Running);
        else if (kStepStr == "done")
            stateTypeSet(ProcessStateType::Done);
        else if (kStepStr == "cancelling")
            stateTypeSet(ProcessStateType::Cancelling);
        else if(kStepStr == "cleaning_up")
            stateTypeSet(ProcessStateType::CleaningUp);
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
        else if (kStepStr == "buildplate_instructions")
            stateTypeSet(ProcessStateType::BuildPlateInstructions);
        else if (kStepStr == "leveling_instructions")
            stateTypeSet(ProcessStateType::LevelingInstructions);
        else if (kStepStr == "checking_left_level")
            stateTypeSet(ProcessStateType::CheckLeftLevel);
        else if (kStepStr == "checking_right_level")
            stateTypeSet(ProcessStateType::CheckRightLevel);
        else if (kStepStr == "checking_levelness")
            stateTypeSet(ProcessStateType::CheckingLevelness);
        else if (kStepStr == "leveling_left_standard_low" ||
                 kStepStr == "leveling_left_standard_ok"  ||
                 kStepStr == "leveling_left_standard_high")
            stateTypeSet(ProcessStateType::LevelingLeft);
        else if (kStepStr == "leveling_right_standard_low" ||
                 kStepStr == "leveling_right_standard_ok"  ||
                 kStepStr == "leveling_right_standard_high")
            stateTypeSet(ProcessStateType::LevelingRight);
        else if (kStepStr == "finishing_level")
            stateTypeSet(ProcessStateType::LevelingComplete);
        // Toolhead Calibration States
        // see morepork-kaiten/kaiten/src/kaiten/processes/nozzlecalibrationprocess.py
        else if (kStepStr == "check_if_nozzle_clean")
            stateTypeSet(ProcessStateType::CheckNozzleClean);
        else if (kStepStr == "heating_nozzle")
            stateTypeSet(ProcessStateType::HeatingNozzle);
        else if (kStepStr == "clean_nozzle")
            stateTypeSet(ProcessStateType::CleanNozzle);
        else if (kStepStr == "cooling_nozzle")
            stateTypeSet(ProcessStateType::CoolingNozzle);
        else if (kStepStr == "homing_xy" ||
                 kStepStr == "homing_z"  ||
                 kStepStr == "nozzle_offset_cal" ||
                 kStepStr == "calibrating_xy" ||
                 kStepStr == "build_plate_zero_cal")
            stateTypeSet(ProcessStateType::CalibratingToolheads);
        else if (kStepStr == "remove_build_plate")
            stateTypeSet(ProcessStateType::RemoveBuildPlate);
        else if (kStepStr == "install_build_plate")
            stateTypeSet(ProcessStateType::InstallBuildPlate);
        else
            stateTypeReset();
    }

    const QString kStepStr = kStep.asString().c_str();
    if(kStepStr == "clear_build_plate") {
        isBuildPlateClearSet(true);
    } else {
        isBuildPlateClearReset();
    }

    if(kStepStr == "preheating_loading" ||
       kStepStr == "preheating_unloading") {
        isLoadUnloadWhilePausedSet(true);

        kStepStr == "preheating_loading" ?
                isLoadSet(true) :
                isLoadSet(false);
    }
    else {
        isLoadUnloadWhilePausedReset();
    }

    const Json::Value &error = proc["error"];
    if (error.isObject()) {
        const int err = error["code"].asInt();
        errorCodeSet(err);
        switch(err) {
            case 0:
            errorTypeSet(ErrorType::NoError);
            break;
            case 13:
            errorTypeSet(ErrorType::NotConnected);
            break;
            case 45:
            errorTypeSet(ErrorType::LidNotPlaced);
            break;
            case 48:
            errorTypeSet(ErrorType::DoorNotClosed);
            break;
            case 74:
            errorTypeSet(ErrorType::HeaterOverTemp);
            break;
            case 80:
            errorTypeSet(ErrorType::NoFilamentAtExtruder);
            break;
            case 81:
            errorTypeSet(ErrorType::FilamentJam);
            break;
            case 83:
            errorTypeSet(ErrorType::DrawerOutOfFilament);
            break;
            case 1001:
            errorTypeSet(ErrorType::HeaterNotReachingTemp);
            break;
            case 1032:
            errorTypeSet(ErrorType::BadHESCalibrationFail);
            break;
            case 1041:
            errorTypeSet(ErrorType::ExtruderOutOfFilament);
            break;
            default:
            errorTypeSet(ErrorType::OtherError);
            break;
        }
        // UPDATE_INT_PROP(errorCode, error["code"]);
    } else {
        errorCodeReset();
    }

    UPDATE_INT_PROP(printPercentage, proc["progress"]);

    const Json::Value &kCurrentToolIndex = proc["tool_index"];
    if(!kCurrentToolIndex.empty()) {
        UPDATE_INT_PROP(currentToolIndex, proc["tool_index"]);
    } else {
        currentToolIndexReset();
    }

    const Json::Value &cancellable = proc["cancellable"];
    if(!cancellable.empty()) {
        isProcessCancellableSet(proc["cancellable"].asBool());
    }
    else {
        isProcessCancellableReset();
    }

    UPDATE_INT_PROP(timeRemaining, proc["time_remaining"]);
    UPDATE_INT_PROP(elapsedTime, proc["elapsed_time"]);
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
