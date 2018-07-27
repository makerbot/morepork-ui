import QtQuick 2.4

AssistedLevelingForm {

    startDoneButton {
        button_mouseArea.onClicked: {
            if(!startDoneButton.disable_button) {
                if(state == "leveling_complete" ||
                   state == "leveling_failed") {
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
                // Disable the acknowledge button, so the user can't
                // move to the next screen if the build plate is not
                // in leveled, based on reported HES values.
                (currentHES < targetHESUpper) &&
                (currentHES > targetHESLower) ? false : true
            }
            else {
                // Button is always enabled in other states(unlock_knob &
                // lock_knob) for the user to click and move to the next
                // screen, since there is no way we can verify that the
                // knobs are loosened or tightened.
                false
            }
        }
        button_mouseArea.onClicked: {
            // UI states to move into dependng on the current
            // state when acknowledge button is clicked.
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

    cancelLeveling.onClicked: {
        bot.cancel()
        state = "cancelling"
        cancelAssistedLevelingPopup.close()
    }

    continueLeveling.onClicked: {
        cancelAssistedLevelingPopup.close()
    }
}
