import QtQuick 2.10

ToolheadCalibrationForm {
    actionButton {
        button_mouseArea.onClicked: {
            if(state == "remove_build_plate") {
                bot.buildPlateState(false)
                state = "calibrating"
            }
            else if(state == "install_build_plate") {
                bot.buildPlateState(true)
                state = "calibrating"
            }
            else if(state == "calibration_finished") {
                processDone()
                if(inFreStep) {
                    mainSwipeView.swipeToItem(0)
                    fre.gotoNextStep(currentFreStep)
                }
            }
            else {
                // Button action in 'base state'
                bot.calibrateToolheads(["x","y"])
            }
        }
    }

    action2Button {
        button_mouseArea.onClicked: {
            bot.calibrateToolheads(["z"])
        }
    }

    stopButton {
        onClicked: {
            bot.cancel()
            cancelCalibrationPopup.close()
        }
    }

    continueButton {
        onClicked: {
            cancelCalibrationPopup.close()
        }
    }
}
