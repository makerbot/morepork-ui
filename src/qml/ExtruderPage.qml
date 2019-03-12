import QtQuick 2.10

ExtruderPageForm {
    attach_extruder_next_button.button_mouseArea.onClicked: {
        if(itemAttachExtruder.state == "attach_extruder_step1") {
            itemAttachExtruder.state = "attach_extruder_step2"
        }
        else if(itemAttachExtruder.state == "attach_extruder_step2") {
            if(itemAttachExtruder.extruder == 1 &&
               itemAttachExtruder.isAttached) {
                itemAttachExtruder.extruder = 2
                itemAttachExtruder.state = "attach_extruder_step1"
            }
            else if(itemAttachExtruder.extruder == 2 &&
                    itemAttachExtruder.isAttached) {
                itemAttachExtruder.state = "attach_swivel_clips"
            }
        }
        else if(itemAttachExtruder.state == "attach_swivel_clips") {
            itemAttachExtruder.state = "close_top_lid"
        }

   }

    handle_top_lid_next_button.button_mouseArea.onClicked: {
        if(itemAttachExtruder.state == "close_top_lid") {
            // done or run calibration
            itemAttachExtruder.state = "base state"
            if(extruderSwipeView.currentIndex != 0) {
                extruderSwipeView.swipeToItem(0)
            }
            if(!inFreStep) {
                if(mainSwipeView.currentIndex != 3) {
                    mainSwipeView.swipeToItem(3)
                }
                if(settingsPage.settingsSwipeView.currentIndex != 6) {
                    settingsPage.settingsSwipeView.swipeToItem(6)
                }
            }
            else {
                mainSwipeView.swipeToItem(0)
                fre.gotoNextStep(currentFreStep)
            }
        }
        else if(itemAttachExtruder.state == "base state") {
            itemAttachExtruder.state = "attach_extruder_step1"
        }
    }
}
