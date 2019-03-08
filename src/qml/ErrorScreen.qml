import QtQuick 2.10
import ProcessStateTypeEnum 1.0

ErrorScreenForm {
    function resetSwipeViews() {
        if(printPage.printStatusView.printStatusSwipeView.currentIndex != 0) {
            printPage.printStatusView.printStatusSwipeView.setCurrentIndex(0)
        }
        if(mainSwipeView.currentIndex != 0) {
            mainSwipeView.setCurrentIndex(0)
        }
    }

    function loadPurgeFromErrorScreen() {
        materialPage.startLoadUnloadFromUI = true
        materialPage.isLoadFilament = true
        materialPage.enableMaterialDrawer()
        // loadFilament(int tool_index, bool external, bool whilePrinitng)
        // if load/unload happens while in print process
        // i.e. while print paused, set whilePrinting to true
        if(bot.extruderAJammed ||
           bot.process.filamentBayAOOF ||
           bot.extruderAOOF) {
            bot.loadFilament(0, false, true)
        } else {
            bot.loadFilament(1, false, true)
        }
    }

    function unloadFromErrorScreen() {
        materialPage.startLoadUnloadFromUI = true
        materialPage.isLoadFilament = false
        materialPage.enableMaterialDrawer()
        // unloadFilament(int tool_index, bool external, bool whilePrinitng)
        if(bot.extruderAJammed) {
            bot.unloadFilament(0, true, true)
        } else {
            bot.unloadFilament(1, true, true)
        }
    }

    button1 {
        disable_button: {
            if(state == "lid_open_error" ||
               state == "door_open_error" ||
               state == "filament_jam_error" ||
               state == "filament_bay_oof_error" ||
               state == "extruder_oof_error_state1") {
                bot.process.stateType != ProcessStateType.Paused
            }
        }

        button_mouseArea {
            onClicked: {
                if(state == "lid_open_error" || state == "door_open_error") {
                    if(bot.process.stateType == ProcessStateType.Paused) {
                        bot.pauseResumePrint("resume")
                    }
                }
                else if(state == "filament_jam_error") {
                    if(bot.process.stateType == ProcessStateType.Paused) {
                        // Purge
                        loadPurgeFromErrorScreen()
                        resetSwipeViews()
                        mainSwipeView.swipeToItem(5)
                        materialPage.loadUnloadFilamentProcess.state = "preheating"
                        materialPage.materialSwipeView.swipeToItem(1)
                    }
                }
                else if(state == "filament_bay_oof_error") {
                    if(bot.process.stateType == ProcessStateType.Paused) {
                        // Load material
                        loadPurgeFromErrorScreen()
                        resetSwipeViews()
                        mainSwipeView.swipeToItem(5)
                        materialPage.loadUnloadFilamentProcess.state = "preheating"
                        materialPage.materialSwipeView.swipeToItem(1)
                    }
                }
                else if(state == "extruder_oof_error_state1") {
                    if(bot.process.stateType == ProcessStateType.Paused) {
                        state = "extruder_oof_error_state2"
                    }
                }
                else if(state == "extruder_oof_error_state2") {
                    if(bot.process.stateType == ProcessStateType.Paused) {
                        // Load material
                        loadPurgeFromErrorScreen()
                        resetSwipeViews()
                        mainSwipeView.swipeToItem(5)
                        materialPage.loadUnloadFilamentProcess.state = "preheating"
                        materialPage.materialSwipeView.swipeToItem(1)
                    }
                } else if (state == "no_tool_connected") {
                    resetSwipeViews()
                    mainSwipeView.swipeToItem(2)
                    // sigh
                    extruderPage.itemAttachExtruder.extruder = bot.process.errorSource + 1
                    extruderPage.itemAttachExtruder.state = "base state"
                    extruderPage.extruderSwipeView.swipeToItem(1)
                }
            }
        }
    }

    button2 {
        disable_button: {
            if(state == "filament_jam_error") {
                bot.process.stateType != ProcessStateType.Paused
            }
        }

        button_mouseArea {
            onClicked: {
                if(state == "filament_jam_error") {
                    if(bot.process.stateType == ProcessStateType.Paused) {
                        // Unload
                        unloadFromErrorScreen()
                        resetSwipeViews()
                        mainSwipeView.swipeToItem(5)
                        materialPage.loadUnloadFilamentProcess.state = "preheating"
                        materialPage.materialSwipeView.swipeToItem(1)
                    }
                }
            }
        }
    }
}
