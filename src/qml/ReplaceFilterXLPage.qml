import QtQuick 2.12

ReplaceFilterXLPageForm {

    function doMove() {
        if(isBuildPlateRaised) {
            bot.moveBuildPlate(400, 20)
        }
        else {
            bot.moveBuildPlate(-400, 20)
        }
    }

    function goBack() {
        if (replaceFilterXLPage.state == "done") {
            if(isBuildPlateRaised) {
                replaceFilterXLPopup.popupState = "cancel"
                replaceFilterXLPopup.open()
            } else {
                cleanAirSettingsSwipeView.swipeToItem(CleanAirSettingsPage.BasePage)
                replaceFilterProcess = false
            }
        }
        else if (replaceFilterXLPage.state == "moving_build_plate") {
            if(!isBuildPlateRaised) isBuildPlateRaised = true
            replaceFilterXLPopup.popupState = "cancel"
            replaceFilterXLPopup.open()
        }
        else if (replaceFilterXLPage.state == "step_2") {
            replaceFilterXLPage.state = "done"
        }
        else if (replaceFilterXLPage.state == "step_3") {
            replaceFilterXLPage.state = "step_2"
        }
        else if (replaceFilterXLPage.state == "step_4") {
            replaceFilterXLPage.state = "step_3"
        }
        else {
            if(isBuildPlateRaised) {
                replaceFilterXLPopup.popupState = "cancel"
                replaceFilterXLPopup.open()
            } else {
                replaceFilterProcess = false
                cleanAirSettingsSwipeView.swipeToItem(CleanAirSettingsPage.BasePage)
            }
        }
    }
}
