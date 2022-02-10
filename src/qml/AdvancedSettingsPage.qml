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
                    copyLogsFinishedPopup.errorcode = bot.process.errorCode;
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
        resetFactoryConfirmPopup.open()
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
}
