import QtQuick 2.10

AssistedLevelingForm {
    contentRightSide {
        buttonPrimary {
            onClicked: {
                if(state == "remove_build_plate") {
                    bot.continue_leveling()
                }
                else if(state == "leveling_complete") {
                    state = "leveling_successful"
                }
                else if(state == "leveling_successful") {
                    processDone()
                    if(inFreStep) {
                        settingsPage.settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                        mainSwipeView.swipeToItem(MoreporkUI.BasePage)
                        fre.gotoNextStep(currentFreStep)
                    }
                    else if(zCalFlag){
                        settingsPage.settingsSwipeView.swipeToItem(SettingsPage.ExtruderSettingsPage)
                        settingsPage.extruderSettingsPage.extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.AutomaticCalibrationPage)
                        bot.calibrateToolheads(["z"])
                    }
                }
                else if(state == "leveling_failed") {
                    state = "base state"
                }
                else {
                    bot.assistedLevel()
                }
            }
        }
    }

    nextButton {
        onClicked: {
            if(state == "locate_screws") {
                bot.continue_leveling()
                state = "checking_level"
            } else if(state == "leveling") {
                bot.acknowledge_level()
            }
        }
    }
}
