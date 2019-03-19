import QtQuick 2.10
import ProcessTypeEnum 1.0

ExtruderPageForm {
    attach_extruder_next_button.button_mouseArea.onClicked: {
        if(itemAttachExtruder.state == "attach_extruder_step1") {
            itemAttachExtruder.state = "attach_extruder_step2"
        }
        else if(itemAttachExtruder.state == "attach_extruder_step2") {
            if(itemAttachExtruder.extruder == 1 &&
                    itemAttachExtruder.isAttached) {
                if (bot.extruderBPresent && !inFreStep) {
                    itemAttachExtruder.state = "attach_swivel_clips"
                } else {
                    itemAttachExtruder.extruder = 2
                    itemAttachExtruder.state = "attach_extruder_step1"
                }
            } else if(itemAttachExtruder.extruder == 2 &&
                    itemAttachExtruder.isAttached) {
                if (bot.extruderAPresent) {
                    itemAttachExtruder.state = "attach_swivel_clips"
                } else {
                    itemAttachExtruder.extruder = 1
                    itemAttachExtruder.state = "attach_extruder_step1"
                }
            }
        } else if(itemAttachExtruder.state == "attach_swivel_clips") {
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

            if (!inFreStep) {
                if (bot.process.type == ProcessType.None) {
                    // go to calibrate screen
                    if(mainSwipeView.currentIndex != 3) {
                        mainSwipeView.swipeToItem(3)
                    }
                    if(settingsPage.settingsSwipeView.currentIndex != 6) {
                        settingsPage.settingsSwipeView.swipeToItem(6)
                    }
                } else if (bot.process.type == ProcessType.Print) {
                    // go to print screen
                    bot.pauseResumePrint("resume");
                    if (mainSwipeView.currentIndex != 1) {
                        mainSwipeView.swipeToItem(1)
                    }
                    if (printPage.printSwipeView.currentIndex != 0) {
                        printPage.printSwipeView.swipeToItem(0);
                    }
                }
            } else {
                mainSwipeView.swipeToItem(0)
                fre.gotoNextStep(currentFreStep)
            }
        } else if(itemAttachExtruder.state == "base state") {
            itemAttachExtruder.state = "attach_extruder_step1"
        }
    }
}
