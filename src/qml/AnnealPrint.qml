import QtQuick 2.10

AnnealPrintForm {
    actionButton.button_mouseArea.onClicked: {
        if(state == "waiting_for_part") {
            state = "choose_material"
        } else if(state == "annealing_complete" || state == "annealing_failed") {
            processDone()
        } else {
            bot.annealPrint()
        }
    }
}
