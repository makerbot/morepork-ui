import QtQuick 2.4

FirmwareUpdatePageForm {
    button1.button_mouseArea.onClicked: {
        switch(state)
        {
        case "firmware_update_available":
            bot.installFirmware()
            break;
        case "no_firmware_update_available":
            goBack()
            break;
        case "firmware_update_failed":
            bot.firmwareUpdateCheck(false)
            break;
        default:
            break;
        }
    }

    button2.button_mouseArea.onClicked: {
        switch(state)
        {
        case "firmware_update_failed":
            goBack()
            break;
        default:
            break;
        }
    }
}
