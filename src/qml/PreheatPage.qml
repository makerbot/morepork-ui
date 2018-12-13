import QtQuick 2.10
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

PreheatPageForm {

    buttonAutoChamberPreheat.onClicked: {
        switchAutoChamberPreheat.checked = !switchAutoChamberPreheat.checked
    }

    buttonStartStopPreheat.onClicked: {
        if(bot.process.type == ProcessType.None) {
            if(bot.chamberTargetTemp > 0) {
                bot.preheatChamber(0)
            }
            else {
                bot.preheatChamber(40)
            }
        }
    }
}
