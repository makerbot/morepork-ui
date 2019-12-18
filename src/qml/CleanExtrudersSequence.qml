import QtQuick 2.10

CleanExtrudersSequenceForm {

    actionButton {
        button_mouseArea.onClicked: {
            if(state == "check_nozzle_clean") {
                bot.doNozzleCleaning(true)
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
