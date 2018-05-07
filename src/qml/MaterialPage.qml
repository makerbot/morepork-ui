import QtQuick 2.4
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

MaterialPageForm {

    function enableMaterialDrawer() {
        if(currentProcess == ProcessType.None ||
          (printPage.isPrintProcess && currentStep == ProcessStateType.Paused)) {
            setDrawerState(false)
            activeDrawer = materialPage.materialPageDrawer
            setDrawerState(true)
        }
    }

    bay1 {
        loadButton.button_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 1
            isLoadFilament = true
            enableMaterialDrawer()
            // loadFilament(int tool_index, bool external, bool whilePrinitng)
            // if load/unload happens while in print process
            // i.e. while print paused, set whilePrinting to true
            if(printPage.isPrintProcess &&
             currentStep == ProcessStateType.Paused) {
                bot.loadFilament(0, true, true)
            }
            else {
                bay1.switch1.checked ? bot.loadFilament(0, true, false) :
                                       bot.loadFilament(0, false, false)
            }
            materialSwipeView.swipeToItem(1)
        }

        unloadButton.button_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 1
            isLoadFilament = false
            enableMaterialDrawer()
            // unloadFilament(int tool_index, bool external, bool whilePrinitng)
            if(printPage.isPrintProcess &&
             currentStep == ProcessStateType.Paused) {
                bot.unloadFilament(0, true, true)
            }
            else {
                bay1.switch1.checked ? bot.unloadFilament(0, true, false) :
                                       bot.unloadFilament(0, false, false)
            }
            materialSwipeView.swipeToItem(1)
        }
    }

    bay2 {
        loadButton.button_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 2
            isLoadFilament = true
            enableMaterialDrawer()
            // loadFilament(int tool_index, bool external, bool whilePrinitng)
            if(printPage.isPrintProcess &&
             currentStep == ProcessStateType.Paused) {
                bot.loadFilament(1, true, true)
            }
            else {
                bay2.switch1.checked ? bot.loadFilament(1, true, false) :
                                       bot.loadFilament(1, false, false)
            }
            materialSwipeView.swipeToItem(1)
        }

        unloadButton.button_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 2
            isLoadFilament = false
            enableMaterialDrawer()
            // unloadFilament(int tool_index, bool external, bool whilePrinitng)
            if(printPage.isPrintProcess &&
             currentStep == ProcessStateType.Paused) {
                bot.unloadFilament(1, true, true)
            }
            else {
                bay2.switch1.checked ? bot.unloadFilament(1, true, false) :
                                       bot.unloadFilament(1, false, false)
            }
            materialSwipeView.swipeToItem(1)
        }
    }

    cancel_mouseArea.onClicked: {
        cancelLoadUnloadPopup.close()
        // Call the appropriate cancel function depending on the
        // the current process. While loading/unloading in the
        // middle of a print, while the bot is still in 'PrintProcess'
        // don't call cancel() which will end the print process.
        if(printPage.isPrintProcess) {
            if(currentStep == ProcessStateType.Extrusion &&
               isLoadFilament) {
                bot.loadFilamentStop()
            }
            else if(currentStep == ProcessStateType.Paused) {
                loadUnloadFilamentProcess.state = "base state"
                materialSwipeView.swipeToItem(0)
                // If cancelled out of load/unload while in print process
                // enable print drawer to set UI back to printing state.
                setDrawerState(false)
                activeDrawer = printPage.printingDrawer
                setDrawerState(true)
            }
        }
        else if(currentProcess == ProcessType.Load ||
                currentProcess == ProcessType.Unload) {
            bot.cancel()
            loadUnloadFilamentProcess.state = "base state"
            materialSwipeView.swipeToItem(0)
            setDrawerState(false)
        }
        else if(currentProcess == ProcessType.None) {
            loadUnloadFilamentProcess.state = "base state"
            materialSwipeView.swipeToItem(0)
            setDrawerState(false)
        }
    }

    continue_mouseArea.onClicked: cancelLoadUnloadPopup.close()

    materialPageDrawer.buttonCancelMaterialChange.onClicked: {
        materialPageDrawer.close()
        cancelLoadUnloadPopup.open()
    }

    materialPageDrawer.buttonResume.onClicked: {
        materialPageDrawer.close()
    }
}
