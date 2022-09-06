import QtQuick 2.10
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

AdvancedSettingsPageForm {

    buttonAdvancedInfo.onClicked: {
        bot.query_status()
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.AdvancedInfoPage)
    }

    buttonPreheat.onClicked: {
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.PreheatPage)
    }

    buttonAssistedLeveling.onClicked: {
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.AssistedLevelingPage)
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

    buttonResetToFactory.onClicked: {
        resetToFactoryPopup.open()
    }

    buttonSpoolInfo.onClicked: {
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.SpoolInfoPage)
        // TODO(shirley): is there a better place to call this?
        spoolInfoPage.init();
    }

    buttonColorSwatch.onClicked: {
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.ColorSwatchPage)
    }

    buttonRaiseLowerBuildPlate.onClicked: {
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.RaiseLowerBuildPlatePage)
    }

    buttonAnalytics.onClicked: {
        bot.getCloudServicesInfo()
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.ShareAnalyticsPage)
    }

    buttonDryMaterial.onClicked: {
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.DryMaterialPage)
    }

    buttonCleanExtruders.onClicked: {
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.CleanExtrudersPage)
    }

    buttonAnnealPrint.onClicked: {
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.AnnealPrintPage)
    }

    buttonTouchTest.onClicked: {
        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.TouchTestPage)
    }
}
