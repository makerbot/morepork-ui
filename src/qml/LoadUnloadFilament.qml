import QtQuick 2.10
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0

LoadUnloadFilamentForm {
    acknowledgeButton {
        onClicked: {
            if(state == "cut_filament_tip") {
                state = "place_material"
            } else if(state == "place_desiccant") {
                state = "cut_filament_tip"
            } else if(state == "place_material") {
                // For mid-print loading since kaiten starts with the preheating
                // step this flag is used to deliberately take the user through the
                // new spool setup (place desiccant, cut tip etc.) for XL and then
                // get to the preheating state screen. For printers with filament bay
                // the material setup screen (only cut filament tip) can be automatically
                // forwarded through with the condition of being in the print process and
                // preheating step and the presence of nfc tag to get to the
                // 'nfc_detected_feed_filament' screen.
                completedNewSpoolSetup = true
                state = "no_nfc_reader_feed_filament"
            } else if(state == "no_nfc_reader_feed_filament") {
                // Do nothing. The button is disabled with the button style
                // and only the help button is enabled in this screen.
            } else if(state == "awaiting_engagement") {
                // Normally the countdown timer gets reset to the initial value
                // when we change the button style from a regular button to a button
                // with a countdown.  But since we directly transition here between
                // two different states with countdowns, we need to manually reset.
                retryButton.delayedEnableCountdown = 30;
                state = "extrusion";
            } else if(state == "extrusion") {
                bot.loadFilamentStop()
            } else if(state == "loaded_filament") {
                if(inFreStep) {
                    if(bot.process.type == ProcessType.Print) {
                        // If user completes load/purge while during
                        // a print in the FRE they are trying to clear
                        // jam etc., so the load process should finish
                        // considering that the printer is still in the
                        // FRE printng step.
                        state = "loaded_filament_1"
                    } else if(bot.process.type == ProcessType.None) {
                        // During normal loading in FRE for printers
                        // without filamenet bay (Method XL) we shouldnt
                        // go to the next state that asks the user to close
                        // the material bay/caddy as there is only one
                        // lid/latch to close unlike Method/X, so we will
                        // go to that state only at the end of loading the
                        // support extruder. Here we just directly start the
                        // support extruder loading.
                        if(bayID == 1 && !bot.hasFilamentBay) {
                            processDone()
                            // Start support extruder loading right from this
                            // state
                            freScreen.startFreMaterialLoad(1)
                        } else {
                            state = "loaded_filament_1"
                        }
                    }
                } else {
                    state = "loaded_filament_1"
                }
            } else if(state == "loaded_filament_1") {
                if(inFreStep) {
                    if(bot.process.type == ProcessType.Print) {
                        // If user completes load/purge while during
                        // a print in the FRE they are trying to clear
                        // jam etc., so the load process should finish
                        // considering that the printer is still in the
                        // FRE printng step.
                        // The processDone() signal handler already
                        // moves to the print page if we are in a print
                        // process.
                        processDone()
                    } else if(bot.process.type == ProcessType.None) {
                        processDone()
                        // During normal loading in the FRE for printers
                        // with filament bay we get to this state, ask the
                        // user to close the bay and then allow them to start
                        // the support extruder loading.
                        if(bayID == 1 && bot.hasFilamentBay) {
                            // Start support extruder loading from the close latch
                            // state.
                            freScreen.startFreMaterialLoad(1)
                        } else if(bayID == 2) {
                            fre.gotoNextStep(currentFreStep)
                            mainSwipeView.swipeToItem(MoreporkUI.BasePage)
                            inFreStep = false
                        }
                    }
                } else {
                    processDone()
                }
            } else if(state == "unloaded_filament") {
                if(bot.hasFilamentBay) {
                    processDone()
                } else {
                    state = "unloaded_filament_1"
                }
            } else if(state == "unloaded_filament_1") {
                processDone()
            } else if(state == "error" || state == "error_not_extruding") {
                retryLoadUnload()
            } else if (state == "error_not_engaging") {
                state = "top_assist_load"
            } else if (state == "top_assist_load") {
                feedFromTop = true;
                retryLoadUnload()
            }
        }

        help {
            onClicked: {
                if(state == "cut_filament_tip") {
                    helpPopup.state = "cut_filament_tip_help"
                    helpPopup.open()
                } else if(state == "place_desiccant") {
                    helpPopup.state = "methodxl_place_desiccant_help"
                    helpPopup.open()
                } else if (state == "place_material") {
                    helpPopup.state = "methodxl_place_material_help"
                    helpPopup.open()
                } else if(state == "no_nfc_reader_feed_filament") {
                    helpPopup.state = "methodxl_feed_filament_help"
                    helpPopup.open()
                } else if(state == "unloaded_filament") {
                    // Change the QR Code to be safe
                    helpPopup.state = (inFreStep) ? "fre" : "general_help"
                    helpPopup.open()
                }
            }
        }
    }

    retryButton {
        onClicked: {
            if(state == "extrusion") {
                bot.loadFilamentCancel()
                notExtruding = true
            } else if(state == "awaiting_engagement") {
                bot.loadFilamentCancel()
                notEngaging = true
            } else if(state == "loaded_filament" || state == "unloaded_filament") {
                state = "base state"
                retryLoadUnload()
            } else if(state == "error" || "error_not_extruding") {
                processDone()
            }
        }
    }

    function retryLoadUnload() {
        var temperature_list = [0,0]
        if(retryTemperature > 0) {
            temperature_list[bayID - 1] = retryTemperature
        }
        var while_printing;
        if(bot.process.type == ProcessType.None) {
            while_printing = false;
        } else if(bot.process.type == ProcessType.Print) {
            while_printing = true;
        } else {
            return;
        }
        if(isLoadFilament) {
            bot.loadFilament(bayID - 1, retryExternal, while_printing,
                temperature_list, retryMaterial);
        } else {
            bot.unloadFilament(bayID - 1, false, while_printing,
                temperature_list, retryMaterial);
        }
    }

    function reset() {
        retryTemperature = 0
        retryMaterial = "None"
        retryExternal = false
    }
}
