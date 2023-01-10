import QtQuick 2.10
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import WifiStateEnum 1.0
import StorageFileTypeEnum 1.0
import MachineTypeEnum 1.0

DayOneUpdateScreenForm {
    button1.onClicked: {
        if (state == "update_now") {
            if (bot.net.interface == "ethernet" && isfirmwareUpdateAvailable) {
                bot.installFirmware()
                state = "updating_firmware"
            } else if (bot.net.interface != "ethernet") {
                state = "connect_to_wifi"
                if(!bot.net.wifiEnabled) {
                    bot.toggleWifi(true)
                }
                bot.net.setWifiState(WifiState.Searching)
                bot.scanWifi(true)
            } else {
                // Need a popup for poor network connectivity
            }
        } else if (state == "download_to_usb_stick") {
            if (storage.usbStorageConnected) {
                storage.setStorageFileType(StorageFileType.Firmware)
                storage.updateFirmwareFileList("?root_usb?")
                firmwareUpdatePage.state = "select_firmware_file"
                state = "usb_fw_file_list"
            } else {
                dayOneUpdatePagePopup.open()
            }
        } else {
            state = "update_now"
        }
    }

    button2.onClicked: {
        if (state == "update_now") {
            state = "download_to_usb_stick"
        } else {
            state = "update_now"
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
