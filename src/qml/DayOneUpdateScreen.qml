import QtQuick 2.10
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import WifiStateEnum 1.0
import StorageFileTypeEnum 1.0
import MachineTypeEnum 1.0

DayOneUpdateScreenForm {
    button1 {
        button_mouseArea.onClicked: {
            if(state == "update_now") {
                if(bot.net.interface == "ethernet" && isfirmwareUpdateAvailable) {
                    bot.installFirmware()
                    state = "updating_firmware"
                }
                else {
                    dayOneUpdatePagePopup.open()
                }
            }
            else if(state == "download_to_usb_stick") {
                storage.setStorageFileType(StorageFileType.Firmware)
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
                state = "update_now"
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
                true
            }
            else if(state == "updating_firmware") {
                true
            }
            else if(state == "usb_fw_file_list") {
                true
            }
            else if(state == "update_now") {
                false
            }
            else {
                // base state
                false
            }
        }
    }

    button2 {
        // Wi-Fi Button
        button_mouseArea.onClicked: {
            if(bot.net.interface == "ethernet") {
                // If ethernet is connected prompt to unplug
                // through the popup.
                isEthernetConnected = true
                dayOneUpdatePagePopup.open()
            }
            else {
                state = "connect_to_wifi"
                if(!bot.net.wifiEnabled) {
                    bot.toggleWifi(true)
                }
                bot.net.setWifiState(WifiState.Searching)
                bot.scanWifi(true)
            }
        }

        disable_button: {
            if(state == "update_now") {
                false
            }
            else {
                true
            }
        }
    }

    button3 {
        button_mouseArea.onClicked: {
            state = "download_to_usb_stick"
            // The best way to set the machine PID would be through the
            // system info, but the pid exists in the storage class which
            // is separate from any of the models so exposing the storage
            // class to the model classes just for this purpose seems
            // unneccessary considering this is going to exist only in the
            // blocking fw for now.
            if(bot.nachineType == MachineType.Fire) {
                storage.setMachinePID(14)
            } else if(bot.machineType == MachineType.Lava) {
                storage.setMachinePID(15)
            }
        }

        disable_button: {
            if(state == "update_now") {
                false
            }
            else {
                true
            }
        }
    }

    mouseArea_backArrow.onClicked: {
        if(state == "usb_fw_file_list") {
            state = "download_to_usb_stick"
        }
        else if(state == "download_to_usb_stick") {
            state = "update_now"
        }
        else if(state == "updating_firmware") {
            if(bot.process.type == ProcessType.FirmwareUpdate &&
               bot.process.stateType <= ProcessStateType.TransferringFirmware) {
                isCancelUpdateProcess = true
                dayOneUpdatePagePopup.open()
            }
            else if(bot.process.type == ProcessType.None) {
                state = "update_now"
            }
        }
        else if(state == "connect_to_wifi") {
            state = "update_now"
        }
        if(wifiPageDayOneUpdate.wifiSwipeView.currentIndex != 0) {
            wifiPageDayOneUpdate.wifiSwipeView.swipeToItem(0)
        }
    }
}
