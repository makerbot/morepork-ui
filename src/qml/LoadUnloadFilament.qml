import QtQuick 2.4

LoadUnloadFilamentForm {

    button_mouseArea{
        onPressed: {
            button_rectangle.color = "#ffffff"
            button_rectangle.border.color = "#000000"
            button_text.color = "#000000"
        }

        onReleased: {
            button_rectangle.color = "#00000000"
            button_rectangle.border.color = "#ffffff"
            button_text.color = "#ffffff"
        }

        onClicked: {
            if(state == "unloaded_filament" || state == "loaded_filament") {
                processDone()
            }
            else if(state == "extrusion") {
                bot.loadFilamentStop()
            }
        }
    }
}
