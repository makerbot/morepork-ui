import QtQuick 2.10
import ErrorTypeEnum 1.0
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import ExtruderTypeEnum 1.0

ErrorScreenForm {
    function formatExtruderNames(ext) {
        // This is terrible
        // Goes from 'Model 1A Performance Extruder' to
        // 'Model 1A'
        var tools = ext.split('/ ')
        function getShortName(t) {
            return t.split(" ").slice(0, 2).join(" ")
        }
        return (getShortName(tools[0]) +
                '/ ' +
                getShortName(tools[1]))
    }

    function acknowledgeError() {
        lastReportedErrorCode = 0
        lastReportedErrorType = ErrorType.NoError
    }

    function resetSwipeViews() {
        if(printPage.printStatusView.printStatusSwipeView.currentIndex != PrintStatusView.Page0) {
            printPage.printStatusView.printStatusSwipeView.setCurrentIndex(PrintStatusView.Page0)
        }
        mainSwipeView.swipeToItem(MoreporkUI.BasePage)
    }

    function isExtruderAError() {
        return (bot.process.extruderAJammed ||
                bot.process.filamentBayAOOF ||
                bot.process.extruderAOOF)
    }

    function loadPurgeFromErrorScreen() {
        if(isExtruderAError() && (materialPage.bay1.usingExperimentalExtruder || settings.getSkipFilamentNags())) {
            materialPage.isLoadFilament = true
            materialPage.materialSwipeView.swipeToItem(MaterialPage.LoadMaterialSettingsPage)
            return;
        }
        materialPage.startLoadUnloadFromUI = true
        materialPage.isLoadFilament = true
        materialPage.enableMaterialDrawer()
        // loadFilament(int tool_index, bool external, bool whilePrinitng)
        // if load/unload happens while in print process
        // i.e. while print paused, set whilePrinting to true
        if(isExtruderAError()) {
            bot.loadFilament(0, false, true)
        } else {
            bot.loadFilament(1, false, true)
        }
        materialPage.materialSwipeView.swipeToItem(MaterialPage.LoadUnloadPage)
    }

    function unloadFromErrorScreen() {
        if(isExtruderAError() && materialPage.bay1.usingExperimentalExtruder) {
            materialPage.isLoadFilament = false
            materialPage.materialSwipeView.swipeToItem(MaterialPage.LoadMaterialSettingsPage)
            return;
        }
        materialPage.startLoadUnloadFromUI = true
        materialPage.isLoadFilament = false
        materialPage.enableMaterialDrawer()
        // unloadFilament(int tool_index, bool external, bool whilePrinitng)
        if(isExtruderAError()) {
            bot.unloadFilament(0, true, true)
        } else {
            bot.unloadFilament(1, true, true)
        }
        materialPage.loadUnloadFilamentProcess.state = "preheating"
        materialPage.materialSwipeView.swipeToItem(MaterialPage.LoadUnloadPage)
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
                // material spool on the bay for the paused print. Skip
                // the material check when using experimental extruder.
                if(bot.process.stateType != ProcessStateType.Paused) {
                   true
                } else if(bot.process.stateType == ProcessStateType.Paused) {
                    if(materialPage.isUsingExpExtruder(bot.process.errorSource + 1)) {
                        // Allow loading if the offending extruder is an experimental
                        // extruder
                        false
                    } else {
                        // For normal extruders only allow loading if the bay material
                        // matches the print material which is the same logic used in the
                        // material page.
                        isExtruderAError() ?
                            printPage.print_model_material != materialPage.bay1.filamentMaterial :
                            printPage.print_support_material != materialPage.bay2.filamentMaterial
                    }
                }
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
                        resetSwipeViews()
                        mainSwipeView.swipeToItem(MoreporkUI.MaterialPage)
                        loadPurgeFromErrorScreen()
                    }
                }
                else if(state == "filament_bay_oof_error") {
                    if(bot.process.stateType == ProcessStateType.Paused) {
                        // Load material
                        resetSwipeViews()
                        mainSwipeView.swipeToItem(MoreporkUI.MaterialPage)
                        loadPurgeFromErrorScreen()
                    }
                }
                else if(state == "extruder_oof_error_state1") {
                    if(bot.process.stateType == ProcessStateType.Paused) {
                        if(bot.extruderAType == ExtruderType.MK14_EXP || !bot.hasFilamentBay) {
                            acknowledgeError()
                            resetSwipeViews()
                            mainSwipeView.swipeToItem(MoreporkUI.MaterialPage)
                        } else {
                            state = "extruder_oof_error_state2"
                        }
                    }
                }
                else if(state == "extruder_oof_error_state2") {
                    if(bot.process.stateType == ProcessStateType.Paused) {
                        // Load material
                        resetSwipeViews()
                        mainSwipeView.swipeToItem(MoreporkUI.MaterialPage)
                        loadPurgeFromErrorScreen()
                    }
                } else if (state == "no_tool_connected") {
                    resetSwipeViews()
                    mainSwipeView.swipeToItem(MoreporkUI.ExtruderPage)
                    // sigh
                    extruderPage.itemAttachExtruder.extruder = bot.process.errorSource + 1
                    extruderPage.itemAttachExtruder.state = "base state"
                    extruderPage.extruderSwipeView.swipeToItem(ExtruderPage.AttachExtruderPage)
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
                        resetSwipeViews()
                        mainSwipeView.swipeToItem(MoreporkUI.MaterialPage)
                        unloadFromErrorScreen()
                    }
                }
                acknowledgeError()
            }
        }
    }
}
