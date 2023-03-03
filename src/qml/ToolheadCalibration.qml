import QtQuick 2.10

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
}
