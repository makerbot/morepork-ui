import QtQuick 2.4

ToolheadCalibrationForm {

    buttonOk {
        button_mouseArea.onClicked: {
            state = "base state"
        }
    }

    xyCalibrateButton {
        button_mouseArea.onClicked: {
            bot.calibrateToolheads(["x","y"])
        }
    }

    zCalibrateButton {
        button_mouseArea.onClicked: {
            bot.calibrateToolheads(["z"])
        }
    }

    buildPlateAttached {
        button_mouseArea.onClicked: {
            bot.buildPlateState(true)
        }
    }

    buildPlateRemoved {
        button_mouseArea.onClicked: {
            bot.buildPlateState(false)
        }
    }

    buttonCancel {
        button_mouseArea.onClicked: {
            bot.cancel()
        }
    }
}
