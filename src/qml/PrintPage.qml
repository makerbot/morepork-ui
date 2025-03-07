import QtQuick 2.10
import StorageSortTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0
import ErrorTypeEnum 1.0

PrintPageForm {
    property bool startPrintMaterialMismatch: false
    property bool startPrintTopLidOpen: false
    property bool startPrintBuildDoorOpen: false
    property bool startPrintNoFilament: false
    property bool startPrintGenuineSliceUnknownMaterial: false
    property bool startPrintUnknownSliceGenuineMaterial: false
    property bool startPrintWithLabsExtruder: false
    property bool startPrintWithUnclearedJam: false

    function startPrintMaterialCheck() {
        // This function checks for and saves all possible failures
        // of material checks as there can be multiple, and just
        // returns true/false.
        // The priority of the failures i.e. which should be reported
        // to the user is determined in the startPrintErrorsPopup popup.
        // e.g. In a case where there is both unknown material error
        // for model material and material mismatch error for support
        // material for the selected print file, they are both recorded
        // here, but only one of them can be shown to the user based
        // on the error priority, which is handled by the popup.

        var modelMaterialOK = false
        // Single extruder prints
        if(model_extruder_used && !support_extruder_used) {
            if (materialPage.bay1.usingExperimentalExtruder ||
                settings.getSkipFilamentNags()) {
                // Empty case, flag no errors!
            } else if(materialPage.bay1.filamentMaterial != print_model_material) {
                startPrintMaterialMismatch = true
            }
        }

        // Dual extruder prints
        if(support_extruder_used && model_extruder_used) {
            if(print_model_material == "unknown" || materialPage.bay1.isUnknownMaterial) {
                if(materialPage.bay1.usingExperimentalExtruder) {
                    modelMaterialOK = true
                } else if(print_model_material == "unknown" && materialPage.bay1.isMaterialValid) {
                    startPrintUnknownSliceGenuineMaterial = true
                    modelMaterialOK = true
                } else if(materialPage.bay1.checkSliceValid(print_model_material) &&
                          materialPage.bay1.isUnknownMaterial) {
                    startPrintGenuineSliceUnknownMaterial = true
                } else if(print_model_material == "unknown" && materialPage.bay1.isUnknownMaterial) {
                    modelMaterialOK = true
                }
            }
            if(!settings.getSkipFilamentNags() && // Skip all mismatch checking for internal use
               ((!modelMaterialOK && // Skip model checking if approved earlier
                 !materialPage.bay1.usingExperimentalExtruder && // Skip model checking if exp. extruder used
                  materialPage.bay1.filamentMaterial != print_model_material) ||
                 (materialPage.bay2.filamentMaterial != print_support_material))) {
                startPrintMaterialMismatch = true
            }
        }

        if(startPrintUnknownSliceGenuineMaterial ||
           startPrintGenuineSliceUnknownMaterial ||
           startPrintMaterialMismatch) {
            return false
        } else {
            return true
        }
    }

    function startPrintDoorLidCheck() {
        if(!bot.doorErrorDisabled && bot.chamberErrorCode == 48) {
            startPrintBuildDoorOpen = true
            return false
        }
        // This isn't a reliable check for the lid error as the door error
        // preempts the lid error so this check can pass and the printer
        // can still error out with a lid error if the user has disabled the
        // door error but not the lid error and left them both open.
        // This only affects internal users.
        else if(!bot.lidErrorDisabled && bot.chamberErrorCode == 45) {
            startPrintTopLidOpen = true
            return false
        } else {
            return true
        }
    }

    function startPrintFilamentCheck() {
        if(bot.noFilamentErrorDisabled) {
            return true
        } else if (model_extruder_used && support_extruder_used &&
            (!bot.extruderAFilamentPresent || !bot.extruderBFilamentPresent)) {
            startPrintNoFilament = true
        } else if (model_extruder_used && !support_extruder_used &&
                   !bot.extruderAFilamentPresent) {
            startPrintNoFilament = true
        }
        if(bot.process.stateType == ProcessStateType.Failed) {
            bot.done("acknowledge_failure")
        }
        if (startPrintNoFilament) {
            return false
        }
        return true
    }

    function startPrintExtruderCheck() {
        if((bot.extruderATypeStr == "mk14_e" ||
            bot.extruderATypeStr == "mk14_hot_e") &&
            isInManualCalibration) {
            startPrintWithLabsExtruder = true
            return false
        }
        return true
    }

    function startPrintUnclearedJamCheck() {
        startPrintWithUnclearedJam =
                (model_extruder_used && extruderAUnclearedJam) ||
                (support_extruder_used && extruderBUnclearedJam)
        return !startPrintWithUnclearedJam
    }

    function startPrintCheck() {
        if(startPrintUnclearedJamCheck() &&
           startPrintDoorLidCheck() &&
           startPrintFilamentCheck() &&
           startPrintMaterialCheck() &&
           startPrintExtruderCheck()) {
            return true
        }
        return false
    }

    function startPrint(printAgain=false) {
        clearErrors()
        storage.backStackClear()
        activeDrawer = printPage.printingDrawer
        if (!printAgain) {
            bot.print(fileName)
        } else {
            bot.printAgain()
        }
        printFromUI = true
        printSwipeView.swipeToItem(PrintPage.BasePage)
    }

    function clearErrors() {
        if(printErrorScreen.lastReportedErrorType != ErrorType.NoError) {
            printErrorScreen.acknowledgeError()
        }
    }

    function showPrintTip() {
        if(settings.getShowNylonCFAnnealPrintTip() &&
           print_model_material == "nylon-cf" ||
           print_model_material == "nylon12-cf" &&
           support_extruder_used) {
            nylonCFPrintTipPopup.open()
        }
    }

    function updateCurrentThing() {
        if(storage.getCurrentThing()) {
            getPrintFileDetails(storage.thing)
        }
    }

    function updateLastThing() {
        if(storage.getLastThing()) {
            getPrintFileDetails(storage.thing)
        }
    }

    function acknowledgePrint() {
        if(bot.process.stateType == ProcessStateType.Failed) {
            bot.done("acknowledge_failure")
        }
        else if(bot.process.stateType == ProcessStateType.Completed) {
            bot.done("acknowledge_completed")
        }
        else if(bot.process.stateType == ProcessStateType.Cancelled) {
            bot.done("acknowledge_failure")
        }
        if(inFreStep) {
            // Go to login to makerbot account step
            // only if network connection is available
            if (isNetworkConnectionAvailable) {
                fre.gotoNextStep(currentFreStep)
            } else {
                fre.setFreStep(FreStep.SetupComplete)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }
        }
        resetPrintFileDetails()
        if (isNPSSurveyDue()) { npsSurveyPopup.open() }
    }

    function isNPSSurveyDue() {
        // Printer isnt keeping correct time, so skip survey.
        if (new Date() < new Date("Wed Jul 20 16:11:15 2022 GMT-0400")) {
            return false
        }

        // Survey has never been submitted, so ask for it.
        if (bot.getNPSSurveyDueDate() == "null") { return true }

        return (new Date() > new Date(bot.getNPSSurveyDueDate()))
    }

    printingDrawer.buttonCancelPrint.onClicked: {
        printingDrawer.close()
        if(inFreStep) {
            skipFreStepPopup.open()
            return;
        }
        cancelPrintPopup.open()
    }

    printingDrawer.buttonPausePrint.onClicked: {
        if(!printingDrawer.buttonPausePrint.disableButton) {
            clearErrors()
            if(bot.process.stateType == ProcessStateType.Printing) {
                bot.pauseResumePrint("suspend")
            }
            else if(bot.process.stateType == ProcessStateType.Paused) {
                bot.pauseResumePrint("resume")
            }
            printingDrawer.close()
        }
    }

    printingDrawer.buttonChangeFilament.onClicked: {
        if(!printingDrawer.buttonChangeFilament.disableButton) {
            if(bot.process.stateType == ProcessStateType.Paused) {
                printPage.printStatusView.printStatusSwipeView.setCurrentIndex(PrintStatusView.Page0)
                resetSettingsSwipeViewPages()
                mainSwipeView.swipeToItem(MoreporkUI.MaterialPage)
                printingDrawer.close()
            }
            else if(bot.process.stateType == ProcessStateType.Printing) {
                bot.pauseResumePrint("suspend")
                printPage.printStatusView.printStatusSwipeView.setCurrentIndex(PrintStatusView.Page0)
                resetSettingsSwipeViewPages()
                mainSwipeView.swipeToItem(MoreporkUI.MaterialPage)
                printingDrawer.close()
            }
        }
    }

    sortingDrawer.buttonSortAZ.onClicked: {
        sortingDrawer.buttonSortAZ.buttonImage = "qrc:/img/drawer_current_selection.png"
        sortingDrawer.buttonSortDateAdded.buttonImage = ""
        sortingDrawer.buttonSortPrintTime.buttonImage = ""
        storage.sortType = StorageSortType.Alphabetic
        sortingDrawer.close()
    }

    sortingDrawer.buttonSortDateAdded.onClicked: {
        sortingDrawer.buttonSortAZ.buttonImage = ""
        sortingDrawer.buttonSortDateAdded.buttonImage = "qrc:/img/drawer_current_selection.png"
        sortingDrawer.buttonSortPrintTime.buttonImage = ""
        storage.sortType = StorageSortType.DateAdded
        sortingDrawer.close()
    }

    sortingDrawer.buttonSortPrintTime.onClicked: {
        sortingDrawer.buttonSortAZ.buttonImage = ""
        sortingDrawer.buttonSortDateAdded.buttonImage = ""
        sortingDrawer.buttonSortPrintTime.buttonImage = "qrc:/img/drawer_current_selection.png"
        storage.sortType = StorageSortType.PrintTime
        sortingDrawer.close()
    }

    reviewTestPrint.continueButton.onClicked: {
        printStatusView.testPrintComplete = false
    }

    reviewTestPrint.calibrateButton.onClicked: {
        fre.setFreStep(FreStep.CalibrateExtruders)
        mainSwipeView.swipeToItem(MoreporkUI.BasePage)
        printStatusView.testPrintComplete = false
    }
}
