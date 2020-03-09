import QtQuick 2.10
import ExtruderTypeEnum 1.0

CleanExtrudersSequenceForm {
    actionButton {
        button_mouseArea.onClicked: {
            if(state == "check_nozzle_clean") {
                if(bot.extruderAType == ExtruderType.MK14_EXP) {
                    chooseMaterial = true
                } else {
                    bot.doNozzleCleaning(true)
                }
            }
            else if(state == "clean_nozzle") {
                bot.acknowledgeNozzleCleaned()
            }
        }
    }

    actionButton2 {
        button_mouseArea.onClicked: {
            if(state == "check_nozzle_clean") {
                bot.doNozzleCleaning(false)
            }
        }
    }
}
