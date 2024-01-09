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
        DryingCycleProcess,
        NozzleCleaningProcess,
        AnnealPrintProcess,
        MoveBuildPlateProcess,
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
        Cancelled,
        Idle, // Load and Unload states
        WaitingForFilament,
        Preheating,
        AwaitingEngagement,
        Extrusion,
        Stopping,
        UnloadingFilament,
        Running, // Base Process states
        Done,
        Cancelling,
        CleaningUp,
        DownloadingFirmware, // Firmware update states
        TransferringFirmware,
        VerifyingFirmware,
        InstallingFirmware,
        BuildPlateInstructions, // Assisted leveling states
        LevelingInstructions,
        CheckingLevelness,
        CheckLeftLevel,
        CheckRightLevel,
        LevelingLeft,
        LevelingRight,
        LevelingComplete,
        LevelingFailed,
        CheckNozzleClean, // Toolhead calibration states
        HeatingNozzle,
        CleanNozzle,
        FinishCleaning,
        CoolingNozzle,
        CalibratingToolheads,
        InstallBuildPlate,
        RemoveBuildPlate,
        PositioningBuildPlate, // Drying Cycle Process states
        WaitingForSpool,
        DryingSpool,
        WaitingForPart, // Anneal print process states
        AnnealingPrint
    };
    //MOREPORK_QML_ENUM
    enum ErrorType {
        NoError,
        NotConnected,
        NoToolConnected,
        LidNotPlaced,
        DoorNotClosed,
        HeaterOverTemp,
        NoFilamentAtExtruder,
        FilamentJam,
        DrawerOutOfFilament,
        ChamberFanFailure,
        HeaterNotReachingTemp,
        BadHESCalibrationFail,
        ExtruderOutOfFilament,
        ToolMismatch,
        IncompatibleSlice,
        HomingError,
        OtherError
    };

    Q_ENUM(ProcessType)
    Q_ENUM(ProcessStateType)
    Q_ENUM(ErrorType)

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
    MODEL_PROP(int, errorSource, 0)
    MODEL_PROP(int, errorCode, 0)
    // Properties for holding tool names for tool mismatch
    // error in print process.
    MODEL_PROP(QString, currentTools, "Unknown")
    MODEL_PROP(QString, fileTools, "Unknown")
    MODEL_PROP(ErrorType, errorType, NoError)
    MODEL_PROP(int, targetHesUpper, 3800)
    MODEL_PROP(int, targetHesLower, 3400)
    MODEL_PROP(int, currentHes, 3600)
    MODEL_PROP(int, levelState, 0)
    // Only valid in a print process context
    MODEL_PROP(bool, extruderAOOF, false)
    MODEL_PROP(bool, extruderBOOF, false)
    MODEL_PROP(bool, extruderAJammed, false)
    MODEL_PROP(bool, extruderBJammed, false)
    MODEL_PROP(bool, filamentBayAOOF, false)
    MODEL_PROP(bool, filamentBayBOOF, false)
    MODEL_PROP(bool, cancelled, false)
    MODEL_PROP(bool, complete, false)
    MODEL_PROP(bool, printFeedbackReported, false)

  public:
    ProcessModel();
};

#endif  // _SRC_PROCESS_MODEL_H

