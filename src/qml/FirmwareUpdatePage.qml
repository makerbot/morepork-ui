import QtQuick 2.10
import ProcessTypeEnum 1.0

FirmwareUpdatePageForm {
    button1.button_mouseArea.onClicked: {
        switch(state) {
        case "firmware_update_available": {
            if(!isProcessRunning()) {
                bot.installFirmware()
            }
        }
            break;
        case "no_firmware_update_available":
            if(!inFreStep) {
                goBack()
            } else {
                settingsSwipeView.swipeToItem(0)
                mainSwipeView.swipeToItem(0)
                fre.gotoNextStep(currentFreStep)
            }
            break;
        case "firmware_update_failed":
            bot.firmwareUpdateCheck(false)
            break;
        default:
            break;
        }
    }

    button2.button_mouseArea.onClicked: {
        switch(state) {
        case "firmware_update_failed":
            goBack()
            break;
        default:
            break;
        }
    }
}
