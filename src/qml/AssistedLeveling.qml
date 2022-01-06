import QtQuick 2.10

AssistedLevelingForm {
    startDoneButton {
        button_mouseArea.onClicked: {
            if(!startDoneButton.disable_button) {
                if(state == "buildplate_instructions") {
                    bot.continue_leveling()
                }
                else if(state == "leveling_complete") {
                    state = "leveling_successful"
                }
                else if(state == "leveling_successful" ||
                   state == "leveling_failed") {
                    processDone()
                    if(inFreStep) {
                        mainSwipeView.swipeToItem(MoreporkUI.BasePage)
                        fre.gotoNextStep(currentFreStep)
                    }
                    else {
                        mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                        settingsPage.settingsSwipeView.swipeToItem(SettingsPage.CalibrateExtrudersPage)
                        bot.calibrateToolheads(["z"])
                    }
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
                // Button is always enabled in other states
                // for the user to click and move to the next
                // screen.
                false
            }
        }
        button_mouseArea.onClicked: {
            // UI states to move into dependng on the current
            // state when acknowledge button is clicked.
            if(state == "leveling_instructions") {
                bot.continue_leveling()
                state = "checking_level"
            }
            else if(state == "leveling") {
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
