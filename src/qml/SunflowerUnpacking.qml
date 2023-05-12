import QtQuick 2.10

SunflowerUnpackingForm {
    state: "remove_box_1"

    function doMove() {
        bot.moveBuildPlate(lowering? 100 : -400, 20)
    }

    continueButton.enabled: state != "raising_paused" || bot.chamberErrorCode != 48

    continueButton {
        onClicked: {
            if (state == "remove_box_1") {
                lowering = false
                state = "confirm"
            } else if (state == "move_paused") {
                state = "moving"
                doMove()
            } else if (state == "remove_box_2") {
                lowering = true
                state = "confirm"
            }
        }
    }

    unpackingPopup.full_button.enabled: bot.chamberErrorCode != 48

    unpackingPopup.full_button.onClicked: {
        state = "moving"
        doMove()
    }

    unpackingPopup.left_button.onClicked: {
        unpackingPopup.close()
        if (lowering) {
            state = "remove_box_2"
        } else {
            state = "remove_box_1"
        }
    }

    unpackingPopup.right_button.onClicked: {
        if (bot.chamberErrorCode != 48 || bot.doorErrorDisabled) {
            state = "moving"
            doMove()
        } else {
            state = "close_door"
        }
    }
}
