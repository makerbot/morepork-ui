import QtQuick 2.4

ToolheadCalibrationForm {

    buttonOk {
        button_mouseArea.onClicked: {
            state = "base state"
        }
    }

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
            }
            else {
                bot.calibrateToolheads(["x","y"])
            }
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
