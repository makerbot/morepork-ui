import QtQuick 2.10

DryMaterialForm {
    actionButton.button_mouseArea.onClicked: {
        dryConfirmBuildPlateClearPopup.open()
    }

    left_button.onClicked: {
        buildPlateClearPopup.close()
        if(state == "waiting_for_spool") {
            state = "choose_material"
        } else if(state == "drying_complete" || state == "drying_failed") {
            processDone()
        } else {
            bot.drySpool()
        }
    }
}
