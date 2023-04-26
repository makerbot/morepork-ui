import QtQuick 2.10

SunflowerUnpackingForm {
    state: "remove_box_1"

    continueButton.enabled: state != "raising_paused" || bot.chamberErrorCode != 48

    continueButton {
        onClicked: {
            if (state == "remove_box_1") {
                state = "confirm"
            } else if (state == "raising_paused") {
                state = "raising"
                bot.moveBuildPlate(-400, 20)
            } else if (state == "remove_box_2") {
                fre.gotoNextStep(currentFreStep)
            }
        }
    }

    unpackingPopup.full_button.enabled: bot.chamberErrorCode != 48

    unpackingPopup.full_button.onClicked: {
        state = "raising"
        bot.moveBuildPlate(-400, 20)
    }

    unpackingPopup.left_button.onClicked: {
        unpackingPopup.close()
        state = "remove_box_1"
    }

    unpackingPopup.right_button.onClicked: {
        if (bot.chamberErrorCode != 48 || bot.doorErrorDisabled) {
            state = "raising"
            bot.moveBuildPlate(-400, 20)
        } else {
            state = "close_door"
        }
    }
}
