import QtQuick 2.10
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import WifiStateEnum 1.0

AdvancedSettingsPageForm {

    buttonPrinterInfo.onClicked: {
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.PrinterInfoPage)
    }

    buttonAdvancedInfo.onClicked: {
        bot.query_status()
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.AdvancedInfoPage)
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
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.WifiPage)
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

    Timer {
        id: koreaDFSModeTimer
        interval: 10000
        onTriggered: {
            if(buttonWiFi.pressed) {
                dfs.loadDFSSetting()
                advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.KoreaDFSSecretPage)
                koreaDFSScreen.passwordField.forceActiveFocus()
            }
        }
    }

    buttonAuthorizeAccounts.onClicked: {
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.AuthorizeAccountsPage)
    }

    buttonFirmwareUpdate.onClicked: {
        bot.firmwareUpdateCheck(false)
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.FirmwareUpdatePage)
    }



    buttonCopyLogs.onClicked: {
        if(storage.usbStorageConnected) {
            var now = new Date();
            copyingLogsPopup.logBundlePath =
                    storage.usbStoragePath + "/Logs_" +
                    now.toString().replace(/[\s,:]/g, "_") +
                    ".zip";
            bot.zipLogs(copyingLogsPopup.logBundlePath);
            copyingLogsPopup.popupState = "copy_logs_state";
        }
        else {
            copyingLogsPopup.popupState = "no_usb_detected";
        }

        if (!copyingLogsPopup.initialized) {
            bot.process.onStateTypeChanged.connect(function() {

                if (bot.process.type === ProcessType.ZipLogsProcess) {

                    var zipLogsInProgress =
                             bot.process.stateType !== ProcessStateType.Done;

                    var succeeded = !(bot.process.errorCode);
                    copyingLogsPopup.errorcode = bot.process.errorCode;
                    if(bot.process.stateType === ProcessStateType.Done &&
                            !copyingLogsPopup.cancelled) {
                        if (succeeded) {
                            bot.forceSyncFile(copyingLogsPopup.logBundlePath)
                            copyingLogsPopup.popupState = "successfully_copied_logs";
                        }
                        else {
                            copyingLogsPopup.popupState = "failed_copied_logs";
                        }
                    }
                    else if(bot.process.stateType === ProcessStateType.Done) {
                        copyingLogsPopup.close();
                    }
                }
            });

            copyingLogsPopup.initialized = true;
            copyingLogsPopup.open();
        }
    }

    buttonAnalytics.onClicked: {
        bot.getCloudServicesInfo()
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.ShareAnalyticsPage)
    }

    buttonChangePrinterName.onClicked: {
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.ChangePrinterNamePage)
        namePrinter.nameField.forceActiveFocus()
    }

    buttonTime.onClicked: {
        bot.getSystemTime()
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.TimePage)
    }

    buttonChangeLanguage.onClicked: {
        languageSelector.currentLocale = Qt.locale().name
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.ChangeLanguagePage)
    }

    buttonSpoolInfo.onClicked: {
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.SpoolInfoPage)
        // TODO(shirley): is there a better place to call this?
        spoolInfoPage.init();
    }

    buttonColorSwatch.onClicked: {
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.ColorSwatchPage)
    }

    buttonTouchTest.onClicked: {
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.TouchTestPage)
    }

    buttonResetToFactory.onClicked: {
        resetToFactoryPopup.open()
    }
}
