import QtQuick 2.10

TimeZoneSelectorForm {
    Timer {
        id: gotoSetTime
        interval: 1500
        onTriggered: {
            bot.getSystemTime()
            timeSwipeView.swipeToItem(2)
        }
    }

    function setTimeZone(name) {
        bot.setTimeZone(name)
        gotoSetTime.start()
    }
}
