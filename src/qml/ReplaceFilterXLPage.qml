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
        if (itemReplaceFilterXL.state == "done") {
            if(isBuildPlateRaised) {
                replaceFilterXLPopup.popupState = "cancel"
                replaceFilterXLPopup.open()
            } else {
                cleanAirSettingsSwipeView.swipeToItem(CleanAirSettingsPage.BasePage)
                replaceFilterProcess = false
            }
        }
        else if (itemReplaceFilterXL.state == "moving_build_plate") {
            if(!isBuildPlateRaised) isBuildPlateRaised = true
            replaceFilterXLPopup.popupState = "cancel"
            replaceFilterXLPopup.open()
        }
        else if (itemReplaceFilterXL.state == "step_2") {
            itemReplaceFilterXL.state = "done"
        }
        else if (itemReplaceFilterXL.state == "step_3") {
            itemReplaceFilterXL.state = "step_2"
        }
        else if (itemReplaceFilterXL.state == "step_4") {
            itemReplaceFilterXL.state = "step_3"
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
