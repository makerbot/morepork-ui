import QtQuick 2.10
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import WifiStateEnum 1.0

SettingsPageForm {

    buttonPrinterInfo.onClicked: {
        settingsSwipeView.swipeToItem(1)
    }

    buttonChangePrinterName.onClicked: {
        settingsSwipeView.swipeToItem(2)
        namePrinter.nameField.forceActiveFocus()
    }

    buttonWiFi.onClicked: {
        if((bot.net.wifiState == WifiState.Connected) ||
            wifiPage.isWifiConnected) {
            bot.scanWifi(false)
        }
        else if(bot.net.wifiState == WifiState.NotConnected ||
                bot.net.wifiState == WifiState.NoWifiFound) {
            bot.net.setWifiState(WifiState.Searching)
            bot.scanWifi(true)
        }
        settingsSwipeView.swipeToItem(3)
    }

    buttonAuthorizeAccounts.onClicked: {
        settingsSwipeView.swipeToItem(4)
    }

    buttonFirmwareUpdate.onClicked: {
        bot.firmwareUpdateCheck(false)
        settingsSwipeView.swipeToItem(5)
    }

    buttonCalibrateToolhead.onClicked: {
        settingsSwipeView.swipeToItem(6)
    }

    buttonTimeAndDate.onClicked: {
        bot.getSystemTime()
        setTimePage.timeReadyTimer.start()
        settingsSwipeView.swipeToItem(7)
    }

    buttonAdvancedSettings.onClicked: {
        settingsSwipeView.swipeToItem(8)
    }
}
