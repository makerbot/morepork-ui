import QtQuick 2.10
import WifiStateEnum 1.0

DayOneUpdateScreenForm {
    button1 {
        button_mouseArea.onClicked: {
            if(state == "update_now") {
                bot.firmwareUpdateCheck(false)
                bot.installFirmware()
            }
            else if(state == "download_to_usb_stick") {
                // open file picker
            }
            else {
                // base state
                state = "connect_to_wifi"
                if(!bot.net.wifiEnabled) {
                    bot.toggleWifi(true)
                }
                bot.net.setWifiState(WifiState.Searching)
                bot.scanWifi(true)
            }
        }
        disable_button: {
            if(state == "download_to_usb_stick" &&
               !storage.usbStorageConnected) {
                true
            }
            else {
                false
            }
        }
    }

    button2.button_mouseArea.onClicked: {
        if(state == "update_now") {
            bot.disconnectWifi("")
            state = "connect_to_wifi"
            bot.scanWifi(true)
        }
        else {
            // base state
            state = "download_to_usb_stick"
        }

    }

    mouseArea_backArrow.onClicked: {
        state = "base state"
        if(wifiPageDayOneUpdate.wifiSwipeView.currentIndex != 0) {
            wifiPageDayOneUpdate.wifiSwipeView.swipeToItem(0)
        }
    }
}
