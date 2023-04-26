import QtQuick 2.10
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import ExtruderTypeEnum 1.0
import MachineTypeEnum 1.0

MaterialPageForm {

    // Flag to get the filament load/unload UI to end
    // with the correct state. When filament load/unload
    // is cancelled kaiten reports the final step as
    // 'done' before killing the Load/Unload Process.
    // But we have mapped the 'done' step to trigger
    // the successful Load/Unload completion screen
    // depending on the process. However since cancelling
    // also ends with 'done' step,the UI closes with the
    // wrong state i.e. load/unload successful. So the next
    // time Load/Unload buttons are hit the UI shows the
    // load/unload successful screen for sometime before
    // moving into preheating/extrusion/unloading states
    // depending on the process invoked(load or unload).
    // This flag is used to prevent this UI behavior.
    property bool materialChangeCancelled: false

    function enableMaterialDrawer() {
        setDrawerState(false)
        activeDrawer = materialPage.materialPageDrawer
        setDrawerState(true)
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

    function resetStatesAfterLoadWhilePaused() {
        loadUnloadFilamentProcess.state = "base state"
        materialSwipeView.swipeToItem(MaterialPage.BasePage)
        // If cancelled out of load/unload while in print process
        // enable print drawer to set UI back to printing state.
        setDrawerState(false)
        activeDrawer = printPage.printingDrawer
        setDrawerState(true)
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
        bot.loadFilament(tool_idx, external, while_printing, temp_list, material)
        loadUnloadFilamentProcess.state = "preheating"
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
        materialSwipeView.swipeToItem(MaterialPage.LoadUnloadPage)
    }

    // Text dependent on type of extruder
    function extruderAttachText() {
        var output = defaultString
        if(itemAttachExtruder.extruder == 1) {
            output = "Load Model Extruder into Slot 1"
            if(bot.machineType == MachineType.Fire) {
                output = qsTr("Load Model 1A or 1C Extruder into\nSlot 1")
            }
            else {
                output = qsTr("Load Model 1A, 1X or 1C Extruder into\nSlot 1")
            }
        } else if(itemAttachExtruder.extruder == 2) {
            output = "Load Support Extruder into Slot 2"
            if(bot.extruderAType == ExtruderType.MK14) {
                output = qsTr("Load Support 2A Extruder into\nSlot 2")
            } else if(bot.extruderAType == ExtruderType.MK14_HOT) {
                output = qsTr("Load Support 2X Extruder into\nSlot 2")
            }
            else if(bot.extruderAType == ExtruderType.MK14_EXP ||
                      bot.extruderAType == ExtruderType.MK14_COMP) {
                if(bot.machineType == MachineType.Fire) {
                    output = qsTr("Load Support 2A Extruder into\nSlot 2")
                } else {
                    output = qsTr("Load Support 2A or 2X Extruder into\nSlot 2")
                }
            } else {
                output = defaultString
            }
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
        // Call the appropriate cancel function depending on the
        // the current process. While loading/unloading in the
        // middle of a print, while the bot is still in 'PrintProcess'
        // don't call cancel() which will end the print process.
        if(printPage.isPrintProcess) {
            // Preheating steps in both load and unload while print paused
            // can be stopped. But once the unloading starts it can't be
            // stopped.
            if(bot.process.stateType == ProcessStateType.Extrusion) {
                bot.loadFilamentStop()
                // Bot goes into stopping step and then to paused step
            }
            else if(bot.process.stateType == ProcessStateType.Preheating) {
                bot.loadFilamentStop()
                // This results in the bot going into 'Stopping' step and
                // then to 'Paused' step as part of the print process, which
                // is the same as above, so to differentiate successful
                // completion and cancellation we use a flag which will be
                // monitered elsewhere.
                materialChangeCancelled = true
            }
            else if(bot.process.stateType == ProcessStateType.UnloadingFilament) {
                waitUntilUnloadedPopup.open()
                closeWaitUntilUnloadedPopup.start()
            }
            // This is a special case when the user opens the cancel poup while
            // the process was cancellable and left it open and then the process
            // ended normally, so now the cancel button isn't even relevant to
            // current state and it shouldn't actually try cancelling anything
            // and just reset the page state and go back.
            else if(bot.process.stateType == ProcessStateType.Paused) {
                resetStatesAfterLoadWhilePaused()
                // Goto the print page
                mainSwipeView.swipeToItem(MoreporkUI.PrintPage)
            }
        }
        else if(bot.process.type == ProcessType.Load) {
            bot.acknowledgeMaterial(false)
            materialChangeCancelled = true
            bot.cancel()
            loadUnloadFilamentProcess.state = "base state"
            materialSwipeView.swipeToItem(MaterialPage.BasePage)
            setDrawerState(false)
        }
        else if(bot.process.type == ProcessType.Unload) {
            if(bot.process.isProcessCancellable) {
                materialChangeCancelled = true
                bot.cancel()
                loadUnloadFilamentProcess.state = "base state"
                materialSwipeView.swipeToItem(MaterialPage.BasePage)
                setDrawerState(false)
            }
            else {
                waitUntilUnloadedPopup.open()
                closeWaitUntilUnloadedPopup.start()
            }
        }
        else if(bot.process.type == ProcessType.None) {
            loadUnloadFilamentProcess.state = "base state"
            materialSwipeView.swipeToItem(MaterialPage.BasePage)
            setDrawerState(false)
        }
    }

    continueLoadUnloadButton.onClicked: {
        cancelLoadUnloadPopup.close()
    }

    oKButtonMaterialWarningPopup.onClicked: {
        bot.acknowledgeMaterial(false)
        materialChangeCancelled = true
        bot.cancel()
        loadUnloadFilamentProcess.state = "base state"
        materialSwipeView.swipeToItem(MaterialPage.BasePage)
        setDrawerState(false)
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

    materialPageDrawer.buttonResume.onClicked: {
        materialPageDrawer.close()
    }

    attach_extruder.buttonPrimary.onClicked: {
        switch(itemAttachExtruder.state) {
        case "base state":
            itemAttachExtruder.state = "attach_extruder_step1"
            break
        case "attach_extruder_step1":
            itemAttachExtruder.state = "attach_extruder_step2"
            break
        case "attach_extruder_step2":
            if(inFreStep) {
                if(itemAttachExtruder.extruder == 1 &&
                        itemAttachExtruder.isAttached) {
                        itemAttachExtruder.extruder = 2
                        itemAttachExtruder.state = "attach_extruder_step1"

                } else if(itemAttachExtruder.extruder == 2 &&
                        itemAttachExtruder.isAttached) {
                    itemAttachExtruder.state = "attach_swivel_clips"
                }
            } else {
                itemAttachExtruder.state = "close_top_lid"
            }
            break
         case "attach_swivel_clips":
               itemAttachExtruder.state = "close_top_lid"
               break
         case "close_top_lid":
            // done or run calibration
            itemAttachExtruder.state = "base state"
            materialSwipeView.swipeToItem(MaterialPage.BasePage)

            if (!inFreStep) {
                if(bot.process.type == ProcessType.None) {
                    if(bot.extruderAPresent && bot.extruderBPresent) {
                        calibrateExtrudersPopup.open()
                    }
                }
                else if(bot.process.type == ProcessType.Print) {
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
}
