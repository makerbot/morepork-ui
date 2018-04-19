import QtQuick 2.4
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

MaterialPageForm {

    function enableMaterialDrawer() {
        if(bot.process.type == ProcessType.None ||
           (printPage.isPrintProcess &&
            bot.process.stateType == ProcessStateType.Paused)) {
            activeDrawer = materialPage.materialPageDrawer
            setDrawerState(true)
        }
    }

    bay1 {
        loadButton.button_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 1
            isLoadFilament = true
            enableMaterialDrawer()
            // loadFilament(int tool_index, bool whilePrinitng)
            // if load/unload happens while in print process
            // i.e. while print paused, set whilePrinting to true
            if(printPage.isPrintProcess &&
             bot.process.stateType == ProcessStateType.Paused) {
                bot.loadFilament(0, true)
            }
            else {
                bot.loadFilament(0, false)
            }
            materialSwipeView.swipeToItem(1)
        }

        unloadButton.button_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 1
            isLoadFilament = false
            enableMaterialDrawer()
            // unloadFilament(int tool_index, bool whilePrinitng)
            if(printPage.isPrintProcess &&
             bot.process.stateType == ProcessStateType.Paused) {
                bot.unloadFilament(0, true)
            }
            else {
                bot.unloadFilament(0, false)
            }
            materialSwipeView.swipeToItem(1)
        }
    }

    bay2 {
        loadButton.button_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 2
            isLoadFilament = true
            enableMaterialDrawer()
            // loadFilament(int tool_index, bool whilePrinitng)
            if(printPage.isPrintProcess &&
             bot.process.stateType == ProcessStateType.Paused) {
                bot.loadFilament(1, true)
            }
            else {
                bot.loadFilament(1, false)
            }
            materialSwipeView.swipeToItem(1)
        }

        unloadButton.button_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 2
            isLoadFilament = false
            enableMaterialDrawer()
            // unloadFilament(int tool_index, bool whilePrinitng)
            if(printPage.isPrintProcess &&
             bot.process.stateType == ProcessStateType.Paused) {
                bot.unloadFilament(1, true)
            }
            else {
                bot.unloadFilament(1, false)
            }
            materialSwipeView.swipeToItem(1)
        }
    }

    cancel_mouseArea.onClicked: {
        // Call the appropriate cancel function depending on the
        // the current process. While loading/unloading in the
        // middle of a print, while the bot is still in 'PrintProcess'
        // don't call cancel() which will end the print process.
        if(printPage.isPrintProcess &&
           bot.process.stateType != ProcessStateType.Paused &&
           isLoadFilament) {
            bot.loadFilamentStop()
        }
        else {
            bot.cancel()
            loadUnloadFilamentProcess.state = "base state"
            materialSwipeView.swipeToItem(0)
        }
        cancelLoadUnloadPopup.close()
        setDrawerState(false)
        // If cancelled out of load/unload while in print process
        // enable print drawer to set UI back to printing state.
        if(printPage.isPrintProcess) {
            activeDrawer = printPage.printingDrawer
            setDrawerState(true)
        }
    }
    cancel_mouseArea.onPressed: {
        cancel_rectangle.color = "#0f0f0f"
    }

    cancel_mouseArea.onReleased: {
        cancel_rectangle.color = "#00000000"
    }

    continue_mouseArea.onClicked: cancelLoadUnloadPopup.close()

    continue_mouseArea.onPressed: {
        continue_rectangle.color = "#0f0f0f"
    }

    continue_mouseArea.onReleased: {
        continue_rectangle.color = "#00000000"
    }

    materialPageDrawer.buttonCancelMaterialChange.onClicked: {
        materialPageDrawer.close()
        cancelLoadUnloadPopup.open()
    }

    materialPageDrawer.buttonResume.onClicked: {
        materialPageDrawer.close()
    }
}
