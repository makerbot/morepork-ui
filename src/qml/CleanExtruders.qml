import QtQuick 2.10
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import ExtruderTypeEnum 1.0

CleanExtrudersForm {
    contentRightSide {
        buttonPrimary {
            onClicked: {
                if(state == "clean_extruders_complete" ||
                   state == "clean_extruders_failed") {
                    processDone()
                } else {
                    if(bot.extruderAType == ExtruderType.MK14_EXP) {
                        state = "choose_material"
                    } else {
                        bot.cleanNozzles()
                    }
                }
            }
        }
    }

    cleanExtrudersSequence {
        contentRightSide {
            buttonPrimary {
                onClicked: {
                    if(cleanExtrudersSequence.state == "finish_cleaning") {
                        bot.acknowledgeNozzleCleaned()
                    }
                }
            }
        }
    }
}
