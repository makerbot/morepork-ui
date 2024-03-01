import QtQuick 2.10
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import ExtruderTypeEnum 1.0
import MachineTypeEnum 1.0

MaterialPageForm {

    function enableMaterialDrawer() {
        setActiveDrawer(materialPage.materialPageDrawer)
    }

    function isExtruderPresent(extruderID) {
        if(extruderID == 1) {
            return bot.extruderAPresent
        } else if(extruderID == 2) {
            return bot.extruderBPresent
        } else {
            return false
        }
    }

    function isExtruderFilamentPresent(extruderID) {
        if(extruderID == 1) {
            return bot.extruderAFilamentPresent
        } else if(extruderID == 2) {
            return bot.extruderBFilamentPresent
        } else {
            return false
        }
    }

    function isUsingExpExtruder(extruderID) {
        if(extruderID == 1) {
            return bay1.usingExperimentalExtruder
        } else if(extruderID == 2) {
            return bay2.usingExperimentalExtruder
        } else {
            return false
        }
    }

    function canLoadUnloadStart(extruderID) {
        if(!isExtruderPresent(extruderID)) {
            // Can never load without an extruder
            return false
        } else if(bot.process.type == ProcessType.None) {
            // Kaiten loads the material config for the spool in the bay before starting
            // the load process. If the material is unsupported it wont start the loading
            // process. So the UI should not allow the user to start loading in this case
            // when it will certainly fail.
            // Mismatch blocking on the UI can still happen once the load pocess is running
            // and an incompatible material is then placed on the bay, but in that case the
            // situation is reversible and the user can choose to cancel or use a different
            // material to proceed with the loading.
            var bay = (extruderID == 1 ? bay1 : bay2)
            if(bay.materialError) {return false}
            return true
        } else if(!printPage.isPrintProcess || bot.process.stateType != ProcessStateType.Paused) {
            // During a paused print is the only non-idle state that allows filament change
            return false
        } else if(bot.process.stepStr == "preprint_suspended") {
            // If a print is paused during the initial start print sequence the printer is
            // paused in a state where we only allow the user to either resume or cancel the
            // print and not allow material loading/unloading.
            return false
        } else if(isExtruderFilamentPresent(extruderID)) {
            // Always allow purge and unload while paused
            return true
        } else if(isUsingExpExtruder(extruderID) || settings.getSkipFilamentNags() || !bot.hasFilamentBay) {
            // Allow loading mid-print for experimental extruders without any material checks
            return true
        } else {
            // Disallow loading in any case where we would not start a print
            var bay_material = ((extruderID == 1)? bay1 : bay2).filamentMaterial
            var print_material = (extruderID == 1)? printPage.print_model_material :
                                                    printPage.print_support_material
            if(print_material == "unknown") {
                return true
            } else {
                return bay_material == print_material
            }
        }
    }

    function maybeShowMoistureWarningPopup(bayID) {
        var current_mat = (bayID == 1 ? bay1.filamentMaterial :
                                bay2.filamentMaterial)
        var materials = ["pva", "nylon-cf", "nylon12-cf"]
        if(materials.indexOf(current_mat) >= 0) {
            moistureWarningPopup.open()
        }
    }

    function shouldUserAssistDrawerLoading(bayID) {
        var current_mat = (bayID == 1 ? bay1.filamentMaterial :
                                bay2.filamentMaterial)
        var materials = ["tpu", "nylon-cf", "nylon12-cf", "abs-cf10"]
        return (materials.indexOf(current_mat) >= 0) && bot.hasFilamentBay
    }

    function shouldUserAssistPurging(bayID) {
        var current_mat = (bayID == 1 ? bay1.filamentMaterial :
                                bay2.filamentMaterial)
        var materials = ["nylon-cf", "nylon12-cf", "abs-cf10"]
        return (materials.indexOf(current_mat) >= 0)
    }

    function shouldSelectMaterial(tool_idx) {
        return (isUsingExpExtruder(tool_idx+1) || (!bot.hasFilamentBay && bot.loadedMaterials[tool_idx] == "unknown"))
    }

    function checkForABSR(bayID) {
        var current_mat = (bayID == 1 ? bay1.filamentMaterialName :
                                bay2.filamentMaterialName)
        if(current_mat == "ABS-R" &&
           bot.extruderAType == ExtruderType.MK14_COMP &&
           bot.extruderASubtype < 2) {
            if(bot.process.type == ProcessType.Load) {
                bot.cancel()
                materialSwipeView.swipeToItem(MaterialPage.BasePage)
            }
            uncapped1CExtruderAlert.open()
        }
    }

    function restartPendingCheck(tool_idx) {
        if(restartPendingAfterExtruderReprogram && tool_idx == 0) {
            uncapped1CExtruderAlert.open()
            uncapped1CExtruderAlert.popupState = "restart_pending"
            return true
        }
    }

    function load(tool_idx, external, temperature=0, material="None") {
        toolIdx = tool_idx
        isLoadFilament = true
        startLoadUnloadFromUI = true
        enableMaterialDrawer()
        var while_printing = (printPage.isPrintProcess &&
                bot.process.stateType == ProcessStateType.Paused)
        if(while_printing && isUsingExpExtruder(tool_idx+1)) {
            // When using experimental extruder, loading
            // mid-print should use external loading.
            external = true
        }

        var temp_list = [0,0]
        if(temperature > 0) {
            temp_list[tool_idx] = temperature
            loadMaterialSettingsPage.selectMaterialSwipeView.swipeToItem(LoadMaterialSettings.SelectMaterialPage)
        }
        loadUnloadFilamentProcess.retryTemperature = temperature
        loadUnloadFilamentProcess.retryMaterial = material
        loadUnloadFilamentProcess.retryExternal = external
        bot.loadFilament(tool_idx, external, while_printing, temp_list, material)
        loadUnloadFilamentProcess.state = "preheating"
        materialChangeActive = true
        materialSwipeView.swipeToItem(MaterialPage.LoadUnloadPage)
    }

    function unload(tool_idx, external, temperature=0, material="None") {
        startLoadUnloadFromUI = true
        isLoadFilament = false
        enableMaterialDrawer()
        var while_printing = (printPage.isPrintProcess &&
                bot.process.stateType == ProcessStateType.Paused)
        var temp_list = [0,0]
        if(temperature > 0) {
            temp_list[tool_idx] = temperature
            loadMaterialSettingsPage.selectMaterialSwipeView.swipeToItem(LoadMaterialSettings.SelectMaterialPage)
        }
        loadUnloadFilamentProcess.retryTemperature = temperature
        loadUnloadFilamentProcess.retryMaterial = material
        bot.unloadFilament(tool_idx, external, while_printing, temp_list, material)
        loadUnloadFilamentProcess.state = "preheating"
        materialChangeActive = true
        materialSwipeView.swipeToItem(MaterialPage.LoadUnloadPage)
    }

    // Text dependent on type of extruder
    function extruderAttachText() {
        var output = defaultString
        if(itemAttachExtruder.extruder == 1) {
            output = qsTr("Load Model Extruder into Slot 1")
        } else if(itemAttachExtruder.extruder == 2) {
            output = qsTr("Load Support Extruder into Slot 2")
        } else {
            output = defaultString
        }
        return output
    }

    bay1 {
        attachExtruderButton {
            onClicked: {
                // Attach extruder A
                itemAttachExtruder.extruder = 1
                itemAttachExtruder.state = "base state"
                materialSwipeView.swipeToItem(MaterialPage.AttachExtruderPage)
            }
        }

        loadButton {
            onClicked: {
                // Load Material
                toolIdx = 0
                if(restartPendingCheck(toolIdx)) { return }
                var while_printing = (printPage.isPrintProcess &&
                        bot.process.stateType == ProcessStateType.Paused)
                if(shouldSelectMaterial(toolIdx) && !while_printing) {
                    isLoadFilament = true
                    materialSwipeView.swipeToItem(MaterialPage.LoadMaterialSettingsPage)
                    return
                }
                load(toolIdx, false)
            }
            enabled: canLoadUnloadStart(bay1.filamentBayID)
        }

        purgeButton {
            onClicked: {
                toolIdx = 0
                if(isUsingExpExtruder(toolIdx+1)) {
                    isLoadFilament = true
                    materialSwipeView.swipeToItem(MaterialPage.LoadMaterialSettingsPage)
                    return
                }
                load(toolIdx, false)
            }
            enabled: canLoadUnloadStart(bay1.filamentBayID)
        }

        unloadButton {
            onClicked: {
                toolIdx = 0
                if(isUsingExpExtruder(toolIdx+1)) {
                    isLoadFilament = false
                    materialSwipeView.swipeToItem(MaterialPage.LoadMaterialSettingsPage)
                    return
                }
                unload(toolIdx, true)
            }
            enabled: canLoadUnloadStart(bay1.filamentBayID) && bay1.extruderFilamentPresent
        }
    }

    bay2 {
        attachExtruderButton {
            onClicked: {
                // Attach Extruder B
                itemAttachExtruder.extruder = 2
                itemAttachExtruder.state = "base state"
                materialSwipeView.swipeToItem(MaterialPage.AttachExtruderPage)
            }
        }

        loadButton {
            onClicked: {
                // Load Material
                toolIdx = 1
                var while_printing = (printPage.isPrintProcess &&
                        bot.process.stateType == ProcessStateType.Paused)
                if(shouldSelectMaterial(toolIdx) && !while_printing) {
                    isLoadFilament = true
                    materialSwipeView.swipeToItem(MaterialPage.LoadMaterialSettingsPage)
                    return
                }
                load(toolIdx, false)
            }
            enabled: canLoadUnloadStart(bay2.filamentBayID)
        }

        purgeButton {
            onClicked: {
                toolIdx = 1
                load(toolIdx, false)
            }
            enabled: canLoadUnloadStart(bay2.filamentBayID)
        }

        unloadButton {
            onClicked: {
                toolIdx = 1
                unload(toolIdx, true)
            }
            enabled: canLoadUnloadStart(bay2.filamentBayID) && bay2.extruderFilamentPresent
        }
    }

    cancelLoadUnloadButton.onClicked: {
        cancelLoadUnloadPopup.close()
        if (!isLoadUnloadProcess) {
            // Nothing to cancel, just leave
            leaveMaterialChange();
        } else if (!bot.process.isProcessCancellable) {
            // We are in the uninterruptible section of unloading
            waitUntilUnloadedPopup.open();
            closeWaitUntilUnloadedPopup.start();
        } else if (printPage.isPrintProcess) {
            // When printing we have to use a special cancel method
            // to only cancel the material change, not the print
            bot.loadFilamentCancel();
            leaveMaterialChange();
        } else {
            bot.cancel()
            leaveMaterialChange();
        }
    }

    continueLoadUnloadButton.onClicked: {
        cancelLoadUnloadPopup.close()
    }

    oKButtonMaterialWarningPopup.onClicked: {
        bot.cancel()
        leaveMaterialChange();
        if(inFreStep) {
            mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            inFreStep = false
        }
        materialWarningPopup.close()
    }

    materialPageDrawer.buttonCancelMaterialChange.onClicked: {
        materialPageDrawer.close()
        if(!inFreStep) {
            exitMaterialChange()
        }
        else {
            if(bot.process.type == ProcessType.Load ||
               bot.process.type == ProcessType.Unload) {
                skipFreStepPopup.open()
            }
            else {
                if(bot.process.type == ProcessType.Print) {
                    cancelLoadUnloadPopup.open()
                }
            }
        }
    }

    attach_extruder.buttonPrimary.onClicked: {
        switch(itemAttachExtruder.state) {
        case "base state":
            itemAttachExtruder.state = "attach_extruder_step1"
            break
        case "attach_extruder_step1":
            if(attach_extruder.buttonPrimary.style ==
               ButtonRectanglePrimary.ButtonDisabledHelpEnabled) {
                return
            }
            itemAttachExtruder.state = "attach_extruder_step2"
            break
        case "attach_extruder_step2":
            if(inFreStep) {
                if(itemAttachExtruder.extruder == 1 && itemAttachExtruder.isAttached) {
                    itemAttachExtruder.extruder = 2
                    itemAttachExtruder.state = "attach_extruder_step1"
                } else if(itemAttachExtruder.extruder == 2 && itemAttachExtruder.isAttached) {
                    itemAttachExtruder.state = "remove_packaging_tapes"
                }
            } else {
                itemAttachExtruder.state = "attach_swivel_clips"
            }
            break
        case "remove_packaging_tapes":
            itemAttachExtruder.state = "attach_swivel_clips"
            break;
        case "attach_swivel_clips":
            itemAttachExtruder.state = "close_top_lid"
            break
        case "close_top_lid":
            // done or run calibration
            itemAttachExtruder.state = "base state"
            materialSwipeView.swipeToItem(MaterialPage.BasePage)

            if (!inFreStep) {
                if(bot.process.type == ProcessType.None) {
                    calibratePopupDeterminant()
                } else if(bot.process.type == ProcessType.Print) {
                    // go to print screen
                    bot.pauseResumePrint("resume")
                    mainSwipeView.swipeToItem(MoreporkUI.PrintPage)
                    printPage.printSwipeView.swipeToItem(PrintPage.BasePage)
               }
            } else {
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
                fre.gotoNextStep(currentFreStep)
            }
            break
        default:
            //default behavior
            break
        }
    }

    attach_extruder.buttonPrimary.help.onClicked: {
        helpPopup.open()
        helpPopup.state = "attach_extruders"
    }
}
