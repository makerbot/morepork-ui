import QtQuick 2.10
import ErrorTypeEnum 1.0
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

ErrorScreenForm {
    function acknowledgeError() {
        lastReportedErrorCode = 0
        lastReportedErrorType = ErrorType.NoError
    }

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
            if (state == "print_lid_open_error" ||
               state == "print_door_open_error" ||
               state == "filament_jam_error" ||
               state == "extruder_oof_error_state1") {
                bot.process.stateType != ProcessStateType.Paused &&
                bot.process.stateType != ProcessStateType.Failed
            }
            else if (state == "filament_bay_oof_error" ||
                     state == "extruder_oof_error_state2") {
                // Loading can directly be started from these error
                // screens so use the same material matching check
                // as in the material page when trying to load mid-
                // print. Purging which is an option in the
                // filament jam error screen is just loading and can
                // be started without any material matching check.

                // Disable load button until the printer isn't completely
                // paused (auto-unloading) or when there is no correct
                // material spool on the bay for the paused print.
                (bot.process.stateType != ProcessStateType.Paused ||
                (bot.process.stateType == ProcessStateType.Paused &&
                  (bot.process.filamentBayAOOF || bot.extruderAOOF ?
                      printPage.print_model_material != materialPage.bay1.filamentMaterialName.toLowerCase() :
                      printPage.print_support_material != materialPage.bay2.filamentMaterialName.toLowerCase())))
            }
            else if (state == "calibration_failed") {
                bot.process.type != ProcessType.None
            }
            else {
                false
            }
        }

        button_mouseArea {
            onClicked: {
                // Some errors have multiple instructional screens
                // so the button in the first of such screens shouldn't
                // clear the error but just move to the following screens.
                // Add all such intermediate screens to this if condition.
                if(state != "extruder_oof_error_state1") {
                    acknowledgeError()
                }

                if(state == "print_lid_open_error" ||
                        state == "print_door_open_error") {
                    if(bot.process.stateType == ProcessStateType.Paused) {
                        bot.pauseResumePrint("resume")
                    } else if(bot.process.stateType == ProcessStateType.Failed) {
                        if(!inFreStep) {
                            bot.done("acknowledge_failure")
                        }
                    }
                }
                else if(state == "filament_jam_error") {
                    if(bot.process.stateType == ProcessStateType.Paused) {
                        // Purge
                        loadPurgeFromErrorScreen()
                        resetSwipeViews()
                        mainSwipeView.swipeToItem(5)
                        materialPage.loadUnloadFilamentProcess.state = "preheating"
                        materialPage.materialSwipeView.swipeToItem(2)
                    }
                }
                else if(state == "filament_bay_oof_error") {
                    if(bot.process.stateType == ProcessStateType.Paused) {
                        // Load material
                        loadPurgeFromErrorScreen()
                        resetSwipeViews()
                        mainSwipeView.swipeToItem(5)
                        materialPage.loadUnloadFilamentProcess.state = "preheating"
                        materialPage.materialSwipeView.swipeToItem(2)
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
                        materialPage.materialSwipeView.swipeToItem(2)
                    }
                } else if (state == "no_tool_connected") {
                    resetSwipeViews()
                    mainSwipeView.swipeToItem(2)
                    // sigh
                    extruderPage.itemAttachExtruder.extruder = bot.process.errorSource + 1
                    extruderPage.itemAttachExtruder.state = "base state"
                    extruderPage.extruderSwipeView.swipeToItem(1)
                }
                else if(state == "generic_error") {
                    // just clear the error
                }
                else if(state == "calibration_failed") {
                    // just clear the error
                }
                else if(state == "heater_not_reaching_temp") {
                    // just clear the error
                }
                else if(state == "heater_over_temp") {
                    // just clear the error
                }
                else if(state == "toolhead_disconnect") {
                    // just clear the error
                }
            }
        }
    }

    button2 {
        disable_button: {
            if (state == "filament_jam_error") {
                bot.process.stateType != ProcessStateType.Paused
            } else {
                false
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
                        materialPage.materialSwipeView.swipeToItem(2)
                    }
                }
                acknowledgeError()
            }
        }
    }
}
