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
                    bot.buildPlateState(true)
                    state = "calibrating"
                } else if(state == "calibration_finished") {
                    toolheadCalibration.processDone()
                    if(returnToManualCal) {
                        returnToManualCal=false
                        resumeManualCalibrationPopup.open()
                    }
                    if(inFreStep) {
                        settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                        mainSwipeView.swipeToItem(MoreporkUI.BasePage)
                        fre.gotoNextStep(currentFreStep)
                    }
                } else {
                    // Button action in 'base state'
                    bot.calibrateToolheads(["x","y"])
                }
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
                        bot.acknowledgeNozzleCleaned()
                    }
                }
            }

            buttonSecondary1 {
                onClicked: {
                    if(toolheadCalibration.state == "clean_nozzles") {
                        bot.doNozzleCleaning(false)
                    }
                }
            }
        }
    }
}
