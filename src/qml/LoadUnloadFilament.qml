import QtQuick 2.10

LoadUnloadFilamentForm {
    acknowledgeButton {
        button_mouseArea.onClicked: {
            if(state == "feed_filament") {
                state = "preheating"
            }
            else if(state == "unloaded_filament" ||
               state == "loaded_filament") {
                processDone()
                if(inFreStep && bayID == 1) {
                    startLoadUnloadFromUI = true
                    isLoadFilament = true
                    bot.loadFilament(1, false, false)
                    setDrawerState(true)
                    materialSwipeView.swipeToItem(1)
                } else if(inFreStep && bayID == 2) {
                    fre.gotoNextStep(currentFreStep)
                    mainSwipeView.swipeToItem(0)
                    inFreStep = false
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
}
