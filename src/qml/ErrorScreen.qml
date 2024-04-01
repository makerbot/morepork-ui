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
            // The material selector page uses the toolIdx to show which extruder
            // and what are the supported materials so set to the model extruder
            // idx as that is the only labs extruder option currently.
            materialPage.toolIdx = 0
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
        materialPage.materialChangeActive = true
        materialPage.loadUnloadFilamentProcess.state = "preheating"
        materialPage.materialSwipeView.swipeToItem(MaterialPage.LoadUnloadPage)
    }

    function unloadFromErrorScreen() {
        if(isExtruderAError() && materialPage.bay1.usingExperimentalExtruder) {
            // The material selector page uses the toolIdx to show which extruder
            // and what are the supported materials so set to the model extruder
            // idx as that is the only labs extruder option currently.
            materialPage.toolIdx = 0
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
        materialPage.materialChangeActive = true
        materialPage.loadUnloadFilamentProcess.state = "preheating"
        materialPage.materialSwipeView.swipeToItem(MaterialPage.LoadUnloadPage)
    }

    button1 {
        enabled: {
            if (state == "print_lid_open_error" ||
               state == "print_door_open_error" ||
               state == "filament_jam_error" ||
               state == "extruder_oof_error") {
                bot.process.stateType == ProcessStateType.Paused ||
                bot.process.stateType == ProcessStateType.Failed
            }
            else if (state == "filament_bay_oof_error") {
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
                    false
                } else if(bot.process.stateType == ProcessStateType.Paused) {
                    if(materialPage.isUsingExpExtruder(bot.process.errorSource + 1)) {
                        // Allow loading if the offending extruder is an experimental
                        // extruder
                        true
                    } else {
                        // For normal extruders only allow loading if the bay material
                        // matches the print material which is the same logic used in the
                        // material page.
                        isExtruderAError() ?
                            (printPage.print_model_material == materialPage.bay1.filamentMaterial) :
                            (printPage.print_support_material == materialPage.bay2.filamentMaterial)
                    }
                }
            }
            else if (state == "calibration_failed") {
                bot.process.type == ProcessType.None
            }
            else {
                true
            }
        }

        onClicked: {
            acknowledgeError()
            if(state == "print_lid_open_error" ||
               state == "print_door_open_error") {
                if(bot.process.stateType == ProcessStateType.Paused) {
                    bot.pauseResumePrint("resume")
                } else if(bot.process.stateType == ProcessStateType.Failed) {
                    if(!inFreStep && !isInManualCalibration) {
                        bot.done("acknowledge_failure")
                    }
                }
            }
            else if(state == "filament_jam_error") {
                if(bot.process.stateType == ProcessStateType.Paused) {
                    // Move to Material Page
                    resetSwipeViews()
                    mainSwipeView.swipeToItem(MoreporkUI.MaterialPage)
                    // Check for Use of Assisted Motors
                    if(!bot.hasFilamentBay
                            || (!materialPage.loadUnloadFilamentProcess.bayFilamentSwitch)
                            || (materialPage.shouldUserAssistPurging(materialPage.loadUnloadFilamentProcess.bayID)))
                    {
                        // Unload
                        unloadFromErrorScreen()
                    } else {
                        // Purge
                        loadPurgeFromErrorScreen()
                    }
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
            else if(state == "extruder_oof_error") {
                // For OOF errors from the extruder just take the user
                // to the material page and they will figure out what to
                // do. This is unlike OOF at the filament bay where we
                // provide the user an option to load a new spool from
                // the error screen directly. See the above else if block.

                // This is primary flow for OOF on Method XL.
                if(bot.process.stateType == ProcessStateType.Paused) {
                    resetSwipeViews()
                    mainSwipeView.swipeToItem(MoreporkUI.MaterialPage)
                }
            }
            else if (state == "no_tool_connected") {
                resetSwipeViews()
                mainSwipeView.swipeToItem(MoreporkUI.MaterialPage)
                // sigh
                materialPage.itemAttachExtruder.extruder = bot.process.errorSource + 1
                materialPage.itemAttachExtruder.state = "base state"
                materialPage.materialSwipeView.swipeToItem(MaterialPage.AttachExtruderPage)
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
