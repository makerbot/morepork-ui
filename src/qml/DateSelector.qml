import QtQuick 2.10

DateSelectorForm {
    Timer {
        id: goToNextStep
        interval: 250
        onTriggered: {
            if(inFreStep) {
                timeSwipeView.swipeToItem(TimePage.SetTime)
            } else {
                timeSwipeView.swipeToItem(TimePage.BasePage)
            }
        }
    }
}
