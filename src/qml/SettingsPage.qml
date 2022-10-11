import QtQuick 2.10
import QtQuick.Controls 2.2
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import WifiStateEnum 1.0

SettingsPageForm {
    buttonPrinterInfo.onClicked: {
        settingsSwipeView.swipeToItem(SettingsPage.PrinterInfoPage)
    }

    buttonChangePrinterName.onClicked: {
        settingsSwipeView.swipeToItem(SettingsPage.ChangePrinterNamePage)
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
        settingsSwipeView.swipeToItem(SettingsPage.WifiPage)
    }

    Timer {
        id: koreaDFSModeTimer
        interval: 10000
        onTriggered: {
            if(buttonWiFi.pressed) {
                dfs.loadDFSSetting()
                settingsSwipeView.swipeToItem(SettingsPage.KoreaDFSSecretPage)
                koreaDFSScreen.passwordField.forceActiveFocus()
            }
        }
    }

    buttonWiFi.onPressedChanged: {
        if(buttonWiFi.pressed) {
            koreaDFSModeTimer.start()
        } else {
            if(koreaDFSModeTimer.running) {
                koreaDFSModeTimer.stop()
            }
        }
    }

    buttonAuthorizeAccounts.onClicked: {
        settingsSwipeView.swipeToItem(SettingsPage.AuthorizeAccountsPage)
    }

    buttonFirmwareUpdate.onClicked: {
        bot.firmwareUpdateCheck(false)
        settingsSwipeView.swipeToItem(SettingsPage.FirmwareUpdatePage)
    }

    buttonCalibrateToolhead.onClicked: {
        settingsSwipeView.swipeToItem(SettingsPage.CalibrateExtrudersPage)
    }

    buttonTime.onClicked: {
        bot.getSystemTime()
        settingsSwipeView.swipeToItem(SettingsPage.TimePage)
    }

    buttonAdvancedSettings.onClicked: {
        settingsSwipeView.swipeToItem(SettingsPage.AdvancedSettingsPage)
    }

    buttonChangeLanguage.onClicked: {
        languageSelector.currentLocale = Qt.locale().name
        settingsSwipeView.swipeToItem(SettingsPage.ChangeLanguagePage)
    }

    buttonCleanAirSettings.onClicked: {
        settingsSwipeView.swipeToItem(SettingsPage.CleanAirSettingsPage)
    }

    buttonShutdown.onClicked: {
        shutdownPopup.open()
    }
}
