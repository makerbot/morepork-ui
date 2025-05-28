import QtQuick 2.10
import ProcessStateTypeEnum 1.0
import ExtruderTypeEnum 1.0

ToolheadCalibrationForm {
    contentRightSide {
        buttonPrimary {
            onClicked: {
                if(state == "remove_build_plate") {
                    bot.buildPlateState(false)
                    state = "calibrating"
                } else if(state == "install_build_plate") {
                    state = "secure_build_plate"
                } else if (state == "secure_build_plate") {
                    bot.buildPlateState(true)
                    state = "calibrating"
                } else if(state == "calibration_finished") {
                    calibrationDone();
                    if (promptForMeshCal) {
                        calibrationProceduresSwipeView.swipeToItem(CalibrationProceduresPage.BasePage)
                        extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.BasePage)
                        settingsSwipeView.swipeToItem(SettingsPage.BuildPlateSettingsPage)
                        buildPlateSettingsPage.buildPlateSettingsSwipeView.swipeToItem(BuildPlateSettingsPage.MeshCalibrationPage);
                        promptForMeshCal = false;
                    }
                } else {
                    // Button action in 'base state'
                    bot.calibrateToolheads(["x","y"])
                }
            }
        }
        buttonSecondary1 {
            onClicked: {
                calibrationDone();
                promptForMeshCal = false;
            }
        }
    }

    cleanExtrudersSequence {
        contentRightSide {
            buttonPrimary {
                onClicked: {
                    if(toolheadCalibration.state == "clean_nozzles" &&
                       bot.process.stateType == ProcessStateType.CheckNozzleClean) {
                        if(bot.extruderAType == ExtruderType.MK14_EXP) {
                            toolheadCalibration.chooseMaterial = true
                        } else {
                            bot.doNozzleCleaning(true)
                        }
                    } else if(toolheadCalibration.state == "clean_nozzles" &&
                              bot.process.stateType == ProcessStateType.FinishCleaning) {
                        bot.acknowledgeNozzleCleaned(true)
                    }
                }
            }

            buttonSecondary1 {
                onClicked: {
                    if(toolheadCalibration.state == "clean_nozzles" &&
                            bot.process.stateType == ProcessStateType.CheckNozzleClean) {
                        bot.doNozzleCleaning(false)
                    } else if(toolheadCalibration.state == "clean_nozzles" &&
                              bot.process.stateType == ProcessStateType.FinishCleaning) {
                        bot.acknowledgeNozzleCleaned(false)
                    }
                }
            }
        }
    }
}
