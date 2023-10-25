import QtQuick 2.12

ReplaceFilterXLPageForm {

    function doMove() {
        bot.moveBuildPlate(-400, 20)
    }


    function next() {
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

    function back() {

    }

}
