import QtQuick 2.10
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

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

    function noExtruderPopupCheck(extruderID) {
        if(extruderID == 1 && !bot.extruderAPresent) {
            extruderIDnoExtruderPopup = extruderID
            noExtruderPopup.open()
        }
        else if(extruderID == 2 && !bot.extruderBPresent) {
            extruderIDnoExtruderPopup = extruderID
            noExtruderPopup.open()
        }
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
            // Always allow loading while idle (material mismatch blocking occurs
            // after starting the process)
            return true
        } else if(!printPage.isPrintProcess || bot.process.stateType != ProcessStateType.Paused) {
            // During a paused print is the only non-idle state that allows filament change
            return false
        } else if(isExtruderFilamentPresent(extruderID)) {
            // Always allow purge and unload while paused
            return true
        } else if(isUsingExpExtruder(extruderID) || settings.getSkipFilamentNags) {
            // Allow loading mid-print for experimental extruders without any material checks
            return true
        } else {
            // Disallow loading in any case where we would not start a print
            var bay_material = ((extruderID == 1)? bay1 : bay2).filamentMaterialName.toLowerCase()
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
        loadUnloadFilamentProcess.isExternalLoadUnload = false
        materialSwipeView.swipeToItem(0)
        // If cancelled out of load/unload while in print process
        // enable print drawer to set UI back to printing state.
        setDrawerState(false)
        activeDrawer = printPage.printingDrawer
        setDrawerState(true)
    }

    bay1 {
        loadButton {
            button_mouseArea.onClicked: {
                if(experimentalExtruderInstalled) {
                    isLoadFilament = true
                    materialSwipeView.swipeToItem(1)
                    return;
                }
                noExtruderPopupCheck(bay1.filamentBayID)
                startLoadUnloadFromUI = true
                isLoadFilament = true
                enableMaterialDrawer()
                // loadFilament(int tool_index, bool external, bool whilePrinitng)
                // if load/unload happens while in print process
                // i.e. while print paused, set whilePrinting to true
                if(printPage.isPrintProcess &&
                   bot.process.stateType == ProcessStateType.Paused) {
                    bot.loadFilament(0, false, true)
                }
                else {
                    bot.loadFilament(0, false, false)
                }
                materialSwipeView.swipeToItem(2)
            }
            disable_button: !canLoadUnloadStart(bay1.filamentBayID)
        }

        unloadButton {
            button_mouseArea.onClicked: {
                if(experimentalExtruderInstalled) {
                    isLoadFilament = false
                    materialSwipeView.swipeToItem(1)
                    return;
                }
                noExtruderPopupCheck(bay1.filamentBayID)
                startLoadUnloadFromUI = true
                isLoadFilament = false
                enableMaterialDrawer()
                // unloadFilament(int tool_index, bool external, bool whilePrinitng)
                if(printPage.isPrintProcess &&
                   bot.process.stateType == ProcessStateType.Paused) {
                    bot.unloadFilament(0, true, true)
                }
                else {
                    bot.unloadFilament(0, true, false)
                }
                // We move explicitly to the 'preheating' state to
                // avoid letting the UI show the 'base state' for
                // sometime until kaiten reports the current step
                // as 'preheating'. This isn't required for loading
                // as the 'base state' is one of the loading screens.
                loadUnloadFilamentProcess.state = "preheating"
                materialSwipeView.swipeToItem(2)
            }
            disable_button: !canLoadUnloadStart(bay1.filamentBayID) || !bay1.extruderFilamentPresent
        }
    }

    bay2 {
        loadButton {
            button_mouseArea.onClicked: {
                noExtruderPopupCheck(bay2.filamentBayID)
                startLoadUnloadFromUI = true
                isLoadFilament = true
                enableMaterialDrawer()
                // loadFilament(int tool_index, bool external, bool whilePrinitng)
                if(printPage.isPrintProcess &&
                   bot.process.stateType == ProcessStateType.Paused) {
                    bot.loadFilament(1, false, true)
                }
                else {
                    bot.loadFilament(1, false, false)
                }
                materialSwipeView.swipeToItem(2)
            }
            disable_button: !canLoadUnloadStart(bay2.filamentBayID)
        }

        unloadButton {
            button_mouseArea.onClicked: {
                noExtruderPopupCheck(bay2.filamentBayID)
                startLoadUnloadFromUI = true
                isLoadFilament = false
                enableMaterialDrawer()
                // unloadFilament(int tool_index, bool external, bool whilePrinitng)
                if(printPage.isPrintProcess &&
                   bot.process.stateType == ProcessStateType.Paused) {
                    bot.unloadFilament(1, true, true)
                }
                else {
                    bot.unloadFilament(1, true, false)
                }
                // We move explicitly to the 'preheating' state to
                // avoid letting the UI show the 'base state' for
                // sometime until kaiten reports the current step
                // as 'preheating'. This isn't required for loading
                // as the 'base state' is one of the loading screens.
                loadUnloadFilamentProcess.state = "preheating"
                materialSwipeView.swipeToItem(2)
            }
            disable_button: !canLoadUnloadStart(bay2.filamentBayID) || !bay2.extruderFilamentPresent
        }
    }

    cancel_mouseArea.onClicked: {
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
                mainSwipeView.swipeToItem(1)
            }
        }
        else if(bot.process.type == ProcessType.Load) {
            bot.acknowledgeMaterial(false)
            materialChangeCancelled = true
            bot.cancel()
            loadUnloadFilamentProcess.state = "base state"
            materialSwipeView.swipeToItem(0)
            setDrawerState(false)
        }
        else if(bot.process.type == ProcessType.Unload) {
            if(bot.process.isProcessCancellable) {
                materialChangeCancelled = true
                bot.cancel()
                loadUnloadFilamentProcess.state = "base state"
                materialSwipeView.swipeToItem(0)
                setDrawerState(false)
            }
            else {
                waitUntilUnloadedPopup.open()
                closeWaitUntilUnloadedPopup.start()
            }
        }
        else if(bot.process.type == ProcessType.None) {
            loadUnloadFilamentProcess.state = "base state"
            materialSwipeView.swipeToItem(0)
            setDrawerState(false)
        }
    }

    continue_mouseArea.onClicked: {
        cancelLoadUnloadPopup.close()
    }

    ok_unk_mat_loading_mouseArea.onClicked: {
        bot.acknowledgeMaterial(false)
        materialChangeCancelled = true
        bot.cancel()
        loadUnloadFilamentProcess.state = "base state"
        materialSwipeView.swipeToItem(0)
        setDrawerState(false)
        if(inFreStep) {
            mainSwipeView.swipeToItem(0)
            inFreStep = false
        }
        materialWarningPopup.close()
    }

    attach_extruder_mouseArea_no_extruder_popup.onClicked: {
        noExtruderPopup.close()
        mainSwipeView.swipeToItem(2)
        extruderPage.itemAttachExtruder.extruder = extruderIDnoExtruderPopup
        extruderPage.extruderSwipeView.swipeToItem(1)
    }

    cancel_mouseArea_no_extruder_popup.onClicked: {
        noExtruderPopup.close()
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
}
