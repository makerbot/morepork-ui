import QtQuick 2.10
import ProcessStateTypeEnum 1.0

ErrorScreenForm {
    button1 {
        disable_button: {
            if(state == "lid_open_error" || state == "door_open_error") {
                bot.process.stateType != ProcessStateType.Paused
            }
        }

        button_mouseArea {
            onClicked: {
                if(state == "lid_open_error" || state == "door_open_error") {
                    if(bot.process.stateType == ProcessStateType.Paused) {
                        bot.pauseResumePrint("resume")
                    }
                }
                else {

                }
            }
        }
    }
}
