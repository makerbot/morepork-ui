import QtQuick 2.4

AssistedLevelingForm {

    startDoneButton {
        button_mouseArea.onClicked: {
            if(!startDoneButton.disable_button) {
                if(state == "leveling_complete") {
                    processDone()
                }
                else {
                    bot.assistedLevel()
                }
            }
        }
    }

    acknowledgeLevelButton {
        opacity: acknowledgeLevelButton.disable_button ? 0.4 : 1
        disable_button: {
            if(state == "leveling") {
                (currentHES < targetHESUpper) &&
                (currentHES > targetHESLower) ?
                            false : true
            }
            else {
                false
            }
        }
        button_mouseArea.onClicked: {
            if(state == "unlock_knob") {
                state = "leveling"
            }
            else if(state == "leveling") {
                if(!acknowledgeLevelButton.disable_button) {
                    state = "lock_knob"
                }
            }
            else if(state == "lock_knob") {
                if(!acknowledgeLevelButton.disable_button) {
                    bot.acknowledge_level()
                }
            }
        }
    }
}
