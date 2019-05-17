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
    buttonUsbStorage.filenameText.text: qsTr("USB")
    buttonInternalStorage.filenameText.text: qsTr("INTERNAL STORAGE")

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
        if(print_support_material == "" && print_model_material != "") {
            if(materialPage.bay1.filamentMaterialName.toLowerCase() !=
                    print_model_material) {
                startPrintMaterialMismatch = true
            }
             // Disable material quantity check before print for now
             // until the spool quantity reading becomes reliable
//            else if(materialPage.bay1.filamentQuantity < modelMaterialRequired) {
//                startPrintWithInsufficientModelMaterial = true
//            }
        }

        // Dual extruder prints
        if(print_support_material != "" && print_model_material != "") {
            if(print_model_material == "unknown" || materialPage.bay1.isUnknownMaterial) {
                if(print_model_material == "unknown" && materialPage.bay1.isMaterialValid) {
                    startPrintUnknownSliceGenuineMaterial = true
                    modelMaterialOK = true
                } else if(materialPage.bay1.checkSliceValid(print_model_material.toUpperCase()) &&
                          materialPage.bay1.isUnknownMaterial) {
                    startPrintGenuineSliceUnknownMaterial = true
                } else if(print_model_material == "unknown" && materialPage.bay1.isUnknownMaterial) {
                    modelMaterialOK = true
                }
            }
            // Since slices aren't
            if((!modelMaterialOK && (materialPage.bay1.filamentMaterialName.toLowerCase() != print_model_material)) ||
               (materialPage.bay2.filamentMaterialName.toLowerCase() != print_support_material)) {
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
           startPrintGenuineSliceUnknownMaterial ||
           startPrintMaterialMismatch ||
           startPrintWithInsufficientModelMaterial ||
           startPrintWithInsufficientSupportMaterial) {
            return false
        }
        else {
            return true
        }
    }

    function startPrintDoorLidCheck() {
        if(!bot.doorLidErrorDisabled && bot.chamberErrorCode == 45) {
            startPrintTopLidOpen = true
            return false
        }
        else if(!bot.doorLidErrorDisabled && bot.chamberErrorCode == 48) {
            startPrintBuildDoorOpen = true
            return false
        }
        else {
            return true
        }
    }

    function startPrintFilamentCheck() {
        if(!bot.extruderAFilamentPresent || !bot.extruderBFilamentPresent) {
            startPrintNoFilament = true
            if(bot.process.stateType == ProcessStateType.Failed) {
                bot.done("acknowledge_failure")
            }
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
        printSwipeView.swipeToItem(0)
    }

    function clearErrors() {
        if(printErrorScreen.lastReportedErrorType != ErrorType.NoError) {
            printErrorScreen.acknowledgeError()
        }
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
                if(printPage.printStatusView.printStatusSwipeView.currentIndex != 0) {
                    printPage.printStatusView.printStatusSwipeView.setCurrentIndex(0)
                }
                if(mainSwipeView.currentIndex != 5) {
                    mainSwipeView.swipeToItem(5)
                }
                if(settingsPage.settingsSwipeView.currentIndex != 0) {
                    settingsPage.settingsSwipeView.setCurrentIndex(0)
                }
                printingDrawer.close()
            }
            else if(bot.process.stateType == ProcessStateType.Printing) {
                bot.pauseResumePrint("suspend")
                if(printPage.printStatusView.printStatusSwipeView.currentIndex != 0) {
                    printPage.printStatusView.printStatusSwipeView.setCurrentIndex(0)
                }
                if(mainSwipeView.currentIndex != 5) {
                    mainSwipeView.swipeToItem(5)
                }
                if(settingsPage.settingsSwipeView.currentIndex != 0) {
                    settingsPage.settingsSwipeView.setCurrentIndex(0)
                }
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
        fre.gotoNextStep(currentFreStep)
        mainSwipeView.swipeToItem(0)
        printStatusView.testPrintComplete = false
    }

    reviewTestPrint.calibrateButton.button_mouseArea.onClicked: {
        fre.setFreStep(FreStep.CalibrateExtruders)
        mainSwipeView.swipeToItem(0)
        printStatusView.testPrintComplete = false
    }

}
