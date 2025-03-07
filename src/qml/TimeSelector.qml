import QtQuick 2.10

TimeSelectorForm {
    Timer {
        id: goToNextStep
        interval: 250
        onTriggered: {
            timeSwipeView.swipeToItem(TimePage.BasePage)
            if(inFreStep) {
                systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
                settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
                fre.gotoNextStep(currentFreStep)
            }
        }
    }
}
