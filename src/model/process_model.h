// Copyright 2017 Makerbot Industries

#ifndef _SRC_PROCESS_MODEL_H
#define _SRC_PROCESS_MODEL_H

#include <QObject>
#include "base_model.h"

class ProcessModel : public BaseModel {
  public:
    //MOREPORK_QML_ENUM
    enum ProcessType {
        None,
        Print,
        Load,
        Unload,
        AssistedLeveling,
        FirmwareUpdate,
        CalibrationProcess,
        FactoryResetProcess,
        ZipLogsProcess,
        Other
    };
    //MOREPORK_QML_ENUM
    enum ProcessStateType {
        Default, // Print states
        Loading,
        Printing,
        Pausing,
        Resuming,
        Paused,
        Completed,
        Failed,
        Idle, // Load and Unload states
        Preheating,
        Extrusion,
        Stopping,
        UnloadingFilament,
        Running, // Base Process states
        Done,
        Cancelling,
        CleaningUp,
        TransferringFirmware, // Firmware update states
        VerifyingFirmware,
        InstallingFirmware,
        CheckFirstPoint, // Assisted leveling states
        BuildPlateInstructions,
        CheckLeftLevel,
        CheckRightLevel,
        LevelingLeft,
        LevelingRight,
        LevelingComplete,
        CheckNozzleClean, // Toolhead calibration states
        HeatingNozzle,
        CleanNozzle,
        CoolingNozzle,
        CalibratingToolheads,
        InstallBuildPlate,
        RemoveBuildPlate
    };

    Q_ENUM(ProcessType)
    Q_ENUM(ProcessStateType)

  private:
    Q_OBJECT

    MODEL_PROP(bool, active, false)
    // 'nameStr' holds the value of params["info"]["current_process"]["name"]
    MODEL_PROP(QString, nameStr, "Unknown")
    // 'stepStr' holds the value of params["info"]["current_process"]["step"]
    MODEL_PROP(QString, stepStr, "Unknown")
    // 'type' is based on the value of params["info"]["current_process"]["name"]
    MODEL_PROP(ProcessType, type, None)
    // 'stateType' is based on the value of params["info"]["current_process"]["step"]
    MODEL_PROP(ProcessStateType, stateType, Loading)
    MODEL_PROP(bool, isLoadUnloadWhilePaused, false)
    MODEL_PROP(bool, isLoad, false)
    MODEL_PROP(bool, isBuildPlateClear, false)
    MODEL_PROP(bool, isProcessCancellable, true)
    MODEL_PROP(bool, printFileValid, false)
    MODEL_PROP(int, currentToolIndex, -1)
    MODEL_PROP(int, printPercentage, 0)
    MODEL_PROP(int, timeRemaining, 0)
    MODEL_PROP(int, elapsedTime, 0)
    MODEL_PROP(int, errorCode, 0)
    MODEL_PROP(int, targetHesUpper, 3800)
    MODEL_PROP(int, targetHesLower, 3400)
    MODEL_PROP(int, currentHes, 3600)
    MODEL_PROP(int, levelState, 0)

  public:
    ProcessModel();
};

#endif  // _SRC_PROCESS_MODEL_H

