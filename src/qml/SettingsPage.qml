import QtQuick 2.4
import ProcessTypeEnum 1.0
import WifiStateEnum 1.0

SettingsPageForm {
    buttonChangeLanguage.onClicked: {
        settingsSwipeView.swipeToItem(1)
    }

    buttonAssistedLeveling.onClicked: {
        settingsSwipeView.swipeToItem(2)
    }

    buttonFirmwareUpdate.onClicked: {
        bot.firmwareUpdateCheck(false)
        settingsSwipeView.swipeToItem(3)
    }

    buttonCalibrateToolhead.onClicked: {
        settingsSwipeView.swipeToItem(4)
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
        settingsSwipeView.swipeToItem(5)
    }

    buttonAdvancedInfo.onClicked: {
        settingsSwipeView.swipeToItem(6)
    }

    buttonLCDTest.onClicked: {
        topBar.visible = false
        settingsSwipeView.swipeToItem(7)
    }

    buttonResetToFactory.onClicked: {
        if(bot.process.type == ProcessType.None) {
            resetFactoryConfirmPopup.open()
        }
    }

    buttonEnglish.onClicked: {
        cpUiTr.selectLanguage("en")
    }

    buttonSpanish.onClicked: {
        cpUiTr.selectLanguage("es")
    }

    buttonFrench.onClicked: {
        cpUiTr.selectLanguage("fr")
    }

    buttonItalian.onClicked: {
        cpUiTr.selectLanguage("it")
    }
}
