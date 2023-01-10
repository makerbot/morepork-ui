import QtQuick 2.10
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import WifiStateEnum 1.0

SystemSettingsPageForm {

    buttonPrinterInfo.onClicked: {
        systemSettingsSwipeView.swipeToItem(SystemSettingsPage.PrinterInfoPage)
    }

    buttonAdvancedInfo.onClicked: {
        bot.query_status()
        systemSettingsSwipeView.swipeToItem(SystemSettingsPage.AdvancedInfoPage)
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
        systemSettingsSwipeView.swipeToItem(SystemSettingsPage.WifiPage)
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
                systemSettingsSwipeView.swipeToItem(SystemSettingsPage.KoreaDFSSecretPage)
                koreaDFSScreen.passwordField.forceActiveFocus()
            }
        }
    }

    buttonAuthorizeAccounts.onClicked: {
        systemSettingsSwipeView.swipeToItem(SystemSettingsPage.AuthorizeAccountsPage)
    }

    buttonFirmwareUpdate.onClicked: {
        bot.firmwareUpdateCheck(false)
        systemSettingsSwipeView.swipeToItem(SystemSettingsPage.FirmwareUpdatePage)
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

    buttonCopyTimelapseImages.onClicked: {
        if(storage.usbStorageConnected) {
            var now = new Date();
            copyingTimelapseImagesPopup.timelapseBundlePath =
                    storage.usbStoragePath + "/TimelapseImages_" +
                    now.toString().replace(/[\s,:]/g, "_") +
                    ".zip";
            bot.zipTimelapseImages(copyingTimelapseImagesPopup.timelapseBundlePath);
            copyingTimelapseImagesPopup.popupState = "copy_timelapse_images_state";
        }
        else {
            copyingTimelapseImagesPopup.popupState = "no_usb_detected";
        }

        if (!copyingTimelapseImagesPopup.initialized) {
            bot.process.onStateTypeChanged.connect(function() {
                if (bot.process.type === ProcessType.ZipLogsProcess) {

                    var zipTimelapseImagesInProgress =
                        bot.process.stateType !== ProcessStateType.Done;

                    var succeeded = !(bot.process.errorCode);
                    copyingTimelapseImagesPopup.errorcode = bot.process.errorCode;
                    if(bot.process.stateType === ProcessStateType.Done &&
                            !copyingTimelapseImagesPopup.cancelled) {
                        if (succeeded) {
                            bot.forceSyncFile(copyingTimelapseImagesPopup.timelapseBundlePath)
                            copyingTimelapseImagesPopup.popupState = "successfully_copied_timelapse_images";
                        }
                        else {
                            copyingTimelapseImagesPopup.popupState = "failed_copied_timelapse_images";
                        }
                    }
                    else if(bot.process.stateType === ProcessStateType.Done) {
                        copyingTimelapseImagesPopup.close();
                    }
                }
            });

            copyingTimelapseImagesPopup.initialized = true;
            copyingTimelapseImagesPopup.open();
        }
    }

    buttonAnalytics.onClicked: {
        bot.getCloudServicesInfo()
        systemSettingsSwipeView.swipeToItem(SystemSettingsPage.ShareAnalyticsPage)
    }

    buttonChangePrinterName.onClicked: {
        systemSettingsSwipeView.swipeToItem(SystemSettingsPage.ChangePrinterNamePage)
        namePrinter.nameField.forceActiveFocus()
    }

    buttonTime.onClicked: {
        bot.getSystemTime()
        systemSettingsSwipeView.swipeToItem(SystemSettingsPage.TimePage)
    }

    buttonChangeLanguage.onClicked: {
        languageSelector.currentLocale = Qt.locale().name
        systemSettingsSwipeView.swipeToItem(SystemSettingsPage.ChangeLanguagePage)
    }

    buttonSpoolInfo.onClicked: {
        systemSettingsSwipeView.swipeToItem(SystemSettingsPage.SpoolInfoPage)
        // TODO(shirley): is there a better place to call this?
        spoolInfoPage.init();
    }

    buttonColorSwatch.onClicked: {
        systemSettingsSwipeView.swipeToItem(SystemSettingsPage.ColorSwatchPage)
    }

    buttonTouchTest.onClicked: {
        systemSettingsSwipeView.swipeToItem(SystemSettingsPage.TouchTestPage)
    }

    buttonResetToFactory.onClicked: {
        resetToFactoryPopup.open()
    }
}
