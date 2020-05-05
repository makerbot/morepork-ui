import QtQuick 2.10
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

AdvancedSettingsPageForm {
    buttonAdvancedInfo.onClicked: {
        bot.query_status()
        advancedSettingsSwipeView.swipeToItem(1)
    }

    buttonPreheat.onClicked: {
        advancedSettingsSwipeView.swipeToItem(2)
    }

    buttonAssistedLeveling.onClicked: {
        advancedSettingsSwipeView.swipeToItem(3)
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
        resetFactoryConfirmPopup.open()
    }

    buttonSpoolInfo.onClicked: {
        advancedSettingsSwipeView.swipeToItem(4)
        // TODO(shirley): is there a better place to call this?
        spoolInfoPage.init();
    }

    buttonColorSwatch.onClicked: {
        advancedSettingsSwipeView.swipeToItem(5)
    }

    buttonRaiseLowerBuildPlate.onClicked: {
        advancedSettingsSwipeView.swipeToItem(6)

    }

    buttonAnalytics.onClicked: {
        bot.getCloudServicesInfo()
        advancedSettingsSwipeView.swipeToItem(7)
    }

    buttonDryMaterial.onClicked: {
        advancedSettingsSwipeView.swipeToItem(8)
    }

    buttonCleanExtruders.onClicked: {
        advancedSettingsSwipeView.swipeToItem(9)
    }

    buttonAnnealPrint.onClicked: {
        advancedSettingsSwipeView.swipeToItem(10)
    }
}
