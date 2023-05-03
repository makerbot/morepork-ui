import QtQuick 2.10
import ProcessTypeEnum 1.0
import StorageFileTypeEnum 1.0

FirmwareUpdatePageForm {
    button1.onClicked: {
        switch(state) {
        case "firmware_update_available": {
            bot.installFirmware()
        }
            break;
        case "no_firmware_update_available":
            if(!inFreStep) {
                goBack()
            } else {
                systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
                settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
                fre.gotoNextStep(currentFreStep)
            }
            break;
        case "firmware_update_failed":
            bot.firmwareUpdateCheck(false)
            goBack()
            break;
        case "install_from_usb":
            storage.setStorageFileType(StorageFileType.Firmware)
            storage.backStackClear()
            storage.updateFirmwareFileList("?root_usb?")
            state = "select_firmware_file"
            break;
        default:
            break;
        }
    }

    button2.onClicked: {
        switch(state) {
        case "firmware_update_failed":
            goBack()
            break;
        case "no_firmware_update_available":
        case "firmware_update_available":
            state = "install_from_usb"
            break;
        default:
            break;
        }
    }
}
