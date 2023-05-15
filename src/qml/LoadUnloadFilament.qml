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
                state = "no_nfc_reader_feed_filament"
            } else if(state == "no_nfc_reader_feed_filament") {
                // Do nothing. The button is disabled with the button style
                // and only the help button is enabled in this screen.
            } else if(state == "extrusion") {
                bot.loadFilamentStop()
            } else if(state == "loaded_filament") {
                if(inFreStep) {
                    if(bot.process.type == ProcessType.Print) {
                        // If user completes load/purge while during
                        // a print in the FRE they are trying to clear
                        // jam etc., so the load process should finish
                        // considering that the printer is still in the
                        // FRE.
                        // The processDone() signal handler already
                        // moves to the print page if we are in a print
                        // process.
                        processDone()
                    } else if(bot.process.type == ProcessType.None) {
                        // During normal load/unload while in FRE
                        if(bayID == 1) {
                            processDone()
                            startLoadUnloadFromUI = true
                            isLoadFilament = true
                            bot.loadFilament(1, false, false)
                            setDrawerState(true)
                            materialSwipeView.swipeToItem(MaterialPage.LoadUnloadPage)
                        } else if(bayID == 2) {
                            state = "loaded_filament_1"
                        }
                    }
                } else {
                    state = "loaded_filament_1"
                }
            } else if(state == "loaded_filament_1") {
                processDone()
                if(inFreStep) {
                    fre.gotoNextStep(currentFreStep)
                    mainSwipeView.swipeToItem(MoreporkUI.BasePage)
                    inFreStep = false
                }
            } else if(state == "unloaded_filament") {
                if(bot.hasFilamentBay) {
                    processDone()
                } else {
                    state = "unloaded_filament_1"
                }
            } else if(state == "unloaded_filament_1") {
                processDone()
            } else if(state == "error" || "error_not_extruding") {
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
                    helpPopup.state = "methodxl_rewind_spool_help"
                    helpPopup.open()
                }
            }
        }
    }

    retryButton {
        onClicked: {
            if(state == "extrusion") {
                bot.loadFilamentStop()
                notExtruding = true
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
            bot.loadFilament(bayID - 1, false, while_printing,
                temperature_list, retryMaterial);
        } else {
            bot.unloadFilament(bayID - 1, false, while_printing,
                temperature_list, retryMaterial);
        }
    }
}
