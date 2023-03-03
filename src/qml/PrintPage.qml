import QtQuick 2.10
import StorageSortTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0
import ErrorTypeEnum 1.0

PrintPageForm {
    property bool startPrintMaterialMismatch: false
    property bool startPrintWithInsufficientModelMaterial: false
    property bool startPrintWithInsufficientSupportMaterial: false
    property bool startPrintWithUnknownMaterials: false
    property bool startPrintTopLidOpen: false
    property bool startPrintBuildDoorOpen: false
    property bool startPrintNoFilament: false
    property bool startPrintGenuineSliceUnknownMaterial: false
    property bool startPrintUnknownSliceGenuineMaterial: false

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
             // Disable material quantity check before print for now
             // until the spool quantity reading becomes reliable
//            else if(materialPage.bay1.filamentQuantity < modelMaterialRequired) {
//                startPrintWithInsufficientModelMaterial = true
//            }
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
            // Disable material quantity check before print for now
            // until the spool quantity reading becomes reliable
//            else if(materialPage.bay1.filamentQuantity < modelMaterialRequired ||
//                    materialPage.bay2.filamentQuantity < supportMaterialRequired) {
//                if(materialPage.bay1.filamentQuantity < modelMaterialRequired) {
//                    startPrintWithInsufficientModelMaterial = true
//                }
//                if(materialPage.bay2.filamentQuantity < supportMaterialRequired) {
//                    startPrintWithInsufficientSupportMaterial = true
//                }
//            }
        }

        if(startPrintUnknownSliceGenuineMaterial ||
           startPrintWithInsufficientModelMaterial ||
           startPrintWithInsufficientSupportMaterial ||
           startPrintGenuineSliceUnknownMaterial ||
           startPrintMaterialMismatch
        ) {
            return false
        }
        else {
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
        }
        else if (model_extruder_used && support_extruder_used &&
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

    function startPrintCheck() {
        if(startPrintDoorLidCheck() &&
           startPrintFilamentCheck() &&
           startPrintMaterialCheck()) {
            return true
        }
        return false
    }

    function startPrint() {
        clearErrors()
        storage.backStackClear()
        activeDrawer = printPage.printingDrawer
        bot.print(fileName)
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
        if(storage.updateCurrentThing()) {
            getPrintFileDetails(storage.currentThing)
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
            printStatusView.testPrintComplete = true
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

    printingDrawer.buttonClose.onClicked: {
        printingDrawer.close()
    }

    sortingDrawer.buttonSortAZ.onClicked: {
        sortingDrawer.buttonSortAZ.buttonImage.source = "qrc:/img/check_circle_small.png"
        sortingDrawer.buttonSortDateAdded.buttonImage.source = ""
        sortingDrawer.buttonSortPrintTime.buttonImage.source = ""
        storage.sortType = StorageSortType.Alphabetic
        sortingDrawer.close()
    }

    sortingDrawer.buttonSortDateAdded.onClicked: {
        sortingDrawer.buttonSortAZ.buttonImage.source = ""
        sortingDrawer.buttonSortDateAdded.buttonImage.source = "qrc:/img/check_circle_small.png"
        sortingDrawer.buttonSortPrintTime.buttonImage.source = ""
        storage.sortType = StorageSortType.DateAdded
        sortingDrawer.close()
    }

    sortingDrawer.buttonSortPrintTime.onClicked: {
        sortingDrawer.buttonSortAZ.buttonImage.source = ""
        sortingDrawer.buttonSortDateAdded.buttonImage.source = ""
        sortingDrawer.buttonSortPrintTime.buttonImage.source = "qrc:/img/check_circle_small.png"
        storage.sortType = StorageSortType.PrintTime
        sortingDrawer.close()
    }

    sortingDrawer.buttonClose.onClicked: {
        sortingDrawer.close()
    }

    reviewTestPrint.continueButton.button_mouseArea.onClicked: {
        if(isNetworkConnectionAvailable) {
            // Go to login to makerbot account step
            // only if network connection is available
            fre.gotoNextStep(currentFreStep)
        }
        else {
            fre.setFreStep(FreStep.SetupComplete)
        }
        mainSwipeView.swipeToItem(MoreporkUI.BasePage)
        printStatusView.testPrintComplete = false
    }

    reviewTestPrint.calibrateButton.button_mouseArea.onClicked: {
        fre.setFreStep(FreStep.CalibrateExtruders)
        mainSwipeView.swipeToItem(MoreporkUI.BasePage)
        printStatusView.testPrintComplete = false
    }
}
