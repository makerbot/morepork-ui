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
                            materialSwipeView.swipeToItem(MaterialPage.LoadUnloadPage)
                        } else if(bayID == 2) {
                            fre.gotoNextStep(currentFreStep)
                            mainSwipeView.swipeToItem(MoreporkUI.BasePage)
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
        }
    }

    retryButton {
        button_mouseArea.onClicked: {
            state = "base state"
            var temperature_list = [0,0]
            if(retryTemperature > 0) {
                temperature_list[bayID - 1] = retryTemperature
            }
            var while_printing;
            if(bot.process.type == ProcessType.None) {
                while_printing = false;
            } else if(bot.process.type == ProcessType.Print) {
                while_printing = false;
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
}
