import QtQuick 2.0

MoveBuildPlatePageForm {

    buttonRaiseToTop.onClicked: {
        if(raiseLowerBuildPlate.chamberDoorOpen) {
            doorOpenRaiseLowerBuildPlatePopup.open()
            return
        }

        bot.moveBuildPlate(-300, 20)
    }
    buttonLowerToBottom.onClicked: {
        if(raiseLowerBuildPlate.chamberDoorOpen) {
            doorOpenRaiseLowerBuildPlatePopup.open()
            return
        }

        bot.moveBuildPlate(300, 20)

    }

    buttonRaiseLowerBuildPlate.onClicked: {
        if(raiseLowerBuildPlate.chamberDoorOpen) {
            doorOpenRaiseLowerBuildPlatePopup.open()
            return
        }

        moveBuildPlatePageSwipeView.swipeToItem(MoveBuildPlatePage.RaiseLowerBuildPlatePage)
    }
}
