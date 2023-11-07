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
                replaceFilterXLPopup.popupState = "end_process"
                replaceFilterXLPopup.open()
            } else {
                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.CleanAirSettingsPage)
                replaceFilterProcess = false
            }
        }
        else if (itemReplaceFilterXL.state == "moving_build_plate") {
            // Cancel
            bot.cancel()
            if(!isBuildPlateRaised) isBuildPlateRaised = true
            replaceFilterXLPopup.popupState = "end_process"
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
                replaceFilterXLPopup.popupState = "end_process"
                replaceFilterXLPopup.open()
            } else {
                replaceFilterProcess = false
                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.CleanAirSettingsPage)
            }
        }
    }
}
