import QtQuick 2.0

MoveBuildPlatePageForm {

    buttonRaiseToTop.onClicked: {
        if(customMoveBuildPlate.chamberDoorOpen) {
            doorOpenMoveBuildPlatePopup.open()
            return
        }
        bot.moveBuildPlate(-300, 20)
    }

    buttonLowerToBottom.onClicked: {
        if(customMoveBuildPlate.chamberDoorOpen) {
            doorOpenMoveBuildPlatePopup.open()
            return
        }
        bot.moveBuildPlate(300, 20)

    }

    buttonCustomMoveBuildPlate.onClicked: {
        if(customMoveBuildPlate.chamberDoorOpen) {
            doorOpenMoveBuildPlatePopup.open()
            return
        }
        moveBuildPlatePageSwipeView.swipeToItem(MoveBuildPlatePage.CustomMoveBuildPlatePage)
    }
}
