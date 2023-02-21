import QtQuick 2.10

TimeZoneSelectorForm {
    Timer {
        id: goToNextStep
        interval: 1000
        onTriggered: {
            bot.getSystemTime()
            if(inFreStep) {
                timeSwipeView.swipeToItem(TimePage.SetDate)
            } else {
                timeSwipeView.swipeToItem(TimePage.BasePage)
            }
        }
    }

    function setTimeZone(name) {
        bot.setTimeZone(name)
        goToNextStep.start()
    }
}
