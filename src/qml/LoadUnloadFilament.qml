import QtQuick 2.4

LoadUnloadFilamentForm {
    acknowledgeButton{
        button_mouseArea.onClicked: {
            if(state == "unloaded_filament" || state == "loaded_filament") {
                processDone()
            }
            else if(state == "extrusion") {
                bot.loadFilamentStop()
            }
        }
    }
}
