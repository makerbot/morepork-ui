import QtQuick 2.4
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
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

    buttonAccounts.onClicked: {
        settingsSwipeView.swipeToItem(7)
    }

    buttonSpoolInfo.onClicked: {
        settingsSwipeView.swipeToItem(8)
        // TODO(shirley): is there a better place to call this?
        spoolInfoPage.init();
    }

    buttonColorSwatch.onClicked: {
        settingsSwipeView.swipeToItem(9)
    }

    buttonPrinterName.onClicked: {
        settingsSwipeView.swipeToItem(10)
    }

    buttonCopyLogs.onClicked: {
        if (buttonCopyLogs.enabled) {
            var now = new Date();
            copyingLogsPopup.logBundlePath =
                    storage.usbStoragePath + "/Logs_" +
                    now.toString().replace(/[\s,:]/g, "_") +
                    ".zip";
            bot.zipLogs(copyingLogsPopup.logBundlePath);
        }

        if (!copyingLogsPopup.initialized) {
            bot.process.onStateTypeChanged.connect(function() {
                if (bot.process.type === ProcessType.ZipLogsProcess) {
                    copyingLogsPopup.zipLogsInProgress =
                             bot.process.stateType !== ProcessStateType.Done;

                    var succeeded = !(bot.process.errorCode);
                    if (bot.process.stateType === ProcessStateType.Done &&
                            succeeded) {
                        bot.forceSyncFile(copyingLogsPopup.logBundlePath)
                    }
                    copyLogsFinishedPopup.succeeded = succeeded;
                } else {
                    copyingLogsPopup.zipLogsInProgress = false;
                }
            });

            copyingLogsPopup.onAboutToHide.connect(function() {
                copyLogsFinishedPopup.open();
            });
            copyingLogsPopup.initialized = true;
        }
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
