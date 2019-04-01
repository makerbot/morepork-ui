import QtQuick 2.10
import StorageSortTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0
import ErrorTypeEnum 1.0

PrintPageForm {
    property bool startPrintWithInsufficientModelMaterial: false
    property bool startPrintWithInsufficientSupportMaterial: false
    property bool startPrintWithUnknownMaterials: false
    property bool startPrintTopLidOpen: false
    property bool startPrintBuildDoorOpen: false
    property bool startPrintNoFilament: false
    buttonUsbStorage.filenameText.text: qsTr("USB") + cpUiTr.emptyStr
    buttonInternalStorage.filenameText.text: qsTr("INTERNAL STORAGE") + cpUiTr.emptyStr

    function startPrintMaterialCheck() {
        // Single extruder prints
        if(print_support_material == "" && print_model_material != "") {
            if(materialPage.bay1.filamentMaterialName.toLowerCase() == "") {
                startPrintWithUnknownMaterials = true
                return false
            }
            else if(materialPage.bay1.filamentMaterialName.toLowerCase() !=
                    print_model_material) {
                return false
            }
            // Disable material quantity check before print for now
            // until the spool quantity reading becomes reliable
//            else if(materialPage.bay1.filamentQuantity < modelMaterialRequired) {
//                startPrintWithInsufficientModelMaterial = true
//                return false
//            }
            else {
                return true
            }
        }

        // Dual extruder prints
        if(print_support_material != "" && print_model_material != "") {
            if(materialPage.bay1.filamentMaterialName == "" ||
               materialPage.bay2.filamentMaterialName == "") {
                if(materialPage.bay1.filamentMaterialName != "" &&
                    materialPage.bay1.filamentMaterialName.toLowerCase() != print_model_material) {
                    return false
                }
                if(materialPage.bay2.filamentMaterialName != "" &&
                    materialPage.bay2.filamentMaterialName.toLowerCase() != print_support_material) {
                    return false
                }
                startPrintWithUnknownMaterials = true
                return false
            }
            else if(materialPage.bay1.filamentMaterialName.toLowerCase() != print_model_material ||
                    materialPage.bay2.filamentMaterialName.toLowerCase() != print_support_material) {
                return false
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
//                return false
//            }
            else {
                return true
            }
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
        startPrintNoFilament = false
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
