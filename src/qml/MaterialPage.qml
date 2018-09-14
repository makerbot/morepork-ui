import QtQuick 2.4
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

    function canLoadUnloadStart() {
        if(bot.process.type == ProcessType.None ||
          (printPage.isPrintProcess &&
           bot.process.stateType == ProcessStateType.Paused)) {
            return true
        }
        else {
            return false
        }
    }

    bay1 {
        loadButton {
            button_mouseArea.onClicked: {
                if(canLoadUnloadStart()) {
                    startLoadUnloadFromUI = true
                    isLoadFilament = true
                    enableMaterialDrawer()
                    // loadFilament(int tool_index, bool external, bool whilePrinitng)
                    // if load/unload happens while in print process
                    // i.e. while print paused, set whilePrinting to true
                    if(printPage.isPrintProcess &&
                     bot.process.stateType == ProcessStateType.Paused) {
                        bay1.switch1.checked ? bot.loadFilament(0, true, true) :
                                               bot.loadFilament(0, false, true)
                    }
                    else {
                        bay1.switch1.checked ? bot.loadFilament(0, true, false) :
                                               bot.loadFilament(0, false, false)
                    }
                    materialSwipeView.swipeToItem(1)
                }
            }
            disable_button: !canLoadUnloadStart()
        }

        unloadButton {
            button_mouseArea.onClicked: {
                if(canLoadUnloadStart()) {
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
                    materialSwipeView.swipeToItem(1)
                }
            }
            disable_button: !canLoadUnloadStart()
        }
    }

    bay2 {
        loadButton {
            button_mouseArea.onClicked: {
                if(canLoadUnloadStart()) {
                    startLoadUnloadFromUI = true
                    isLoadFilament = true
                    enableMaterialDrawer()
                    // loadFilament(int tool_index, bool external, bool whilePrinitng)
                    if(printPage.isPrintProcess &&
                     bot.process.stateType == ProcessStateType.Paused) {
                        bay2.switch1.checked ? bot.loadFilament(1, true, true) :
                                               bot.loadFilament(1, false, true)
                    }
                    else {
                        bay2.switch1.checked ? bot.loadFilament(1, true, false) :
                                               bot.loadFilament(1, false, false)
                    }
                    materialSwipeView.swipeToItem(1)
                }
            }
            disable_button: !canLoadUnloadStart()
        }

        unloadButton {
            button_mouseArea.onClicked: {
                if(canLoadUnloadStart()) {
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
                    materialSwipeView.swipeToItem(1)
                }
            }
            disable_button: !canLoadUnloadStart()
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
                loadUnloadFilamentProcess.state = "base state"
                materialSwipeView.swipeToItem(0)
                // If cancelled out of load/unload while in print process
                // enable print drawer to set UI back to printing state.
                setDrawerState(false)
                activeDrawer = printPage.printingDrawer
                setDrawerState(true)
            }
        }
        else if(bot.process.type == ProcessType.Load) {
            materialChangeCancelled = true
            bot.cancel()
            loadUnloadFilamentProcess.state = "base state"
            materialSwipeView.swipeToItem(0)
            setDrawerState(false)
        }
        else if(bot.process.type == ProcessType.None) {
            loadUnloadFilamentProcess.state = "base state"
            materialSwipeView.swipeToItem(0)
            setDrawerState(false)
        }
    }

    continue_mouseArea.onClicked: cancelLoadUnloadPopup.close()

    materialPageDrawer.buttonCancelMaterialChange.onClicked: {
        materialPageDrawer.close()
        exitMaterialChange()
    }

    materialPageDrawer.buttonResume.onClicked: {
        materialPageDrawer.close()
    }
}
