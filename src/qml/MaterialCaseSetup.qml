import QtQuick 2.10

MaterialCaseSetupForm {
    state: "intro_1"

    continueButton.enabled: state != "raising_paused" || bot.chamberErrorCode != 48

    continueButton {
        onClicked: {
            if (state == "intro_1") {
                state = "intro_2"
            } else if (state == "intro_2") {
                state = "tube_1_case"
            } else if (state == "tube_1_case") {
                state = "tube_1_printer"
            } else if (state == "tube_1_printer") {
                state = "tube_2"
            } else if (state == "tube_2") {
                state = "intro_1"
                setupProceduresSwipeView.swipeToItem(SetupProceduresPage.BasePage)
                if(inFreStep){
                    systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
                    settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                    mainSwipeView.swipeToItem(MoreporkUI.BasePage)
                    fre.gotoNextStep(currentFreStep)
                }
            }
        }
    }
}
