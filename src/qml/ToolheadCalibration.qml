import QtQuick 2.4

ToolheadCalibrationForm {

    buttonOk {
        button_mouseArea.onClicked: {
            state = "base state"
        }
    }

    xyCalibrateButton {
        button_mouseArea.onClicked: {
            if(toolheadA.checked && toolheadB.checked) {
                bot.calibrateToolheads(["a","b"], ["x","y"])
            }
            else if(toolheadA.checked) {
                bot.calibrateToolheads(["a"], ["x","y"])
            }
            else if(toolheadB.checked) {
                bot.calibrateToolheads(["b"], ["x","y"])
            }
        }
    }

    zCalibrateButton {
        button_mouseArea.onClicked: {
            if(toolheadA.checked && toolheadB.checked) {
                bot.calibrateToolheads(["a","b"], ["z"])
            }
            else if(toolheadA.checked) {
                bot.calibrateToolheads(["a"], ["z"])
            }
            else if(toolheadB.checked) {
                bot.calibrateToolheads(["b"], ["z"])
            }
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
}
