import QtQuick 2.10
import ExtruderTypeEnum 1.0

CleanExtrudersForm {
    actionButton.button_mouseArea.onClicked: {
        if(state == "clean_extruders_complete" ||
           state == "clean_extruders_failed") {
            processDone()
        } else {
            if(bot.extruderAType == ExtruderType.MK14_EXP) {
                state = "choose_material"
            } else {
                bot.cleanNozzles()
            }
        }
    }
}
