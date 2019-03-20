import QtQuick 2.10
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0

LoadUnloadFilamentForm {

    snipMaterial.continueButton.button_mouseArea.onClicked: {
        snipMaterialAlertAcknowledged = true
    }

    acknowledgeButton {
        button_mouseArea.onClicked: {
            if(state == "feed_filament") {
                state = "preheating"
            }
            else if(state == "unloaded_filament" ||
               state == "loaded_filament") {
                processDone()
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
                    }
                    else if(bot.process.type == ProcessType.None) {
                        // During normal load/unload while in FRE
                        if(bayID == 1) {
                            startLoadUnloadFromUI = true
                            isLoadFilament = true
                            bot.loadFilament(1, false, false)
                            setDrawerState(true)
                            materialSwipeView.swipeToItem(1)
                        } else if(bayID == 2) {
                            fre.gotoNextStep(currentFreStep)
                            mainSwipeView.swipeToItem(0)
                            inFreStep = false
                        }
                    }
                }
            }
            else if(state == "error") {
                processDone()
            }
            else if(state == "extrusion") {
                bot.loadFilamentStop()
            }
            else {
                // This condition is when the page is in
                // "base state". For some reason QML doesn't
                // allow us to check for the base state like
                // the other if blocks above.
                // i.e. if(state == "base state") doesn't work.
                overrideInvalidMaterial = true
            }
        }
    }

    retryButton {
        button_mouseArea.onClicked: {
            // loadFilament(tool_index, external, whilePrinitng)
            // unloadFilament(tool_index, external, whilePrinitng)
            if(state == "loaded_filament") {
                if(bot.process.type == ProcessType.None) {
                    bot.loadFilament(bayID - 1, false, false)
                }
                else if(bot.process.type == ProcessType.Print) {
                    bot.loadFilament(bayID - 1, false, true)
                }
            } else if(state == "unloaded_filament") {
                if(bot.process.type == ProcessType.None) {
                    bot.unloadFilament(bayID - 1, true, false)
                }
                else if(bot.process.type == ProcessType.Print) {
                    bot.unloadFilament(bayID - 1, true, true)
                }
            } else if(state == "error") {
                if(bot.process.type == ProcessType.None) {
                    isLoadFilament ?
                        bot.loadFilament(bayID - 1, false, false) :
                        bot.unloadFilament(bayID - 1, true, false)
                }
                else if(bot.process.type == ProcessType.Print) {
                    isLoadFilament ?
                        bot.loadFilament(bayID - 1, false, true) :
                        bot.unloadFilament(bayID - 1, true, true)
                }
            }
        }
    }
}
