import QtQuick 2.10
import ProcessTypeEnum 1.0
import WifiStateEnum 1.0

DayOneUpdateScreenForm {
    button1 {
        button_mouseArea.onClicked: {
            if(state == "download_to_usb_stick") {
                storage.updateFirmwareFileList("?root_usb?")
                state = "usb_fw_file_list"
            }
            else if(state == "connect_to_wifi") {

            }
            else if(state == "updating_firmware") {

            }
            else if(state == "usb_fw_file_list") {

            }
            else {
                // base state
                if(bot.net.interface == "ethernet" || bot.net.interface == "wifi") {
                    if(bot.process.type == ProcessType.None) {
                        bot.installFirmware()
                        state = "updating_firmware"
                    }
                    else if(bot.process.type == ProcessType.FirmwareUpdate) {
                        state = "updating_firmware"
                    }
                }
            }
        }
        disable_button: {
            if(state == "download_to_usb_stick") {
               if(storage.usbStorageConnected) {
                   false
               }
               else {
                   true
               }
            }
            else if(state == "connect_to_wifi") {

            }
            else if(state == "updating_firmware") {

            }
            else if(state == "usb_fw_file_list") {

            }
            else {
                // base state
                if(isfirmwareUpdateAvailable &&
                   (bot.net.interface == "ethernet" || bot.net.interface == "wifi")) {
                    false
                }
                else if(isFirmwareUpdateProcess) {
                    false
                }
                else {
                    true
                }
            }
        }
    }

    button2.button_mouseArea.onClicked: {
        state = "download_to_usb_stick"
    }

    button3.button_mouseArea.onClicked: {
        state = "connect_to_wifi"
        if(!bot.net.wifiEnabled) {
            bot.toggleWifi(true)
        }
        bot.net.setWifiState(WifiState.Searching)
        bot.scanWifi(true)
    }

    mouseArea_backArrow.onClicked: {
        state = "base state"
        if(wifiPageDayOneUpdate.wifiSwipeView.currentIndex != 0) {
            wifiPageDayOneUpdate.wifiSwipeView.swipeToItem(0)
        }
    }
}
