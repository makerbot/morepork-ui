import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 800
    height: 440
    smooth: false

    property alias defaultItem: itemSetTimeZone
    property alias timeZoneSelectorPage: timeZoneSelectorPage
    property alias timeSelectorPage: timeSelectorPage
    property alias timeSwipeView: timeSwipeView

    SwipeView {
        id: timeSwipeView
        currentIndex: 0
        smooth: false
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = timeSwipeView.currentIndex
            timeSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            setCurrentItem(timeSwipeView.itemAt(itemToDisplayDefaultIndex))
            timeSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            timeSwipeView.itemAt(prevIndex).visible = false
        }

        //timeSwipeView.index = 0
        Item {
            id: itemSetTimeZone
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: true

            TimeZoneSelector {
                id: timeZoneSelectorPage

            }
        }

        //timeSwipeView.index = 1
        Item {
            id: itemSetTime
            property var backSwiper: timeSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            TimeSelector {
                id: timeSelectorPage

            }
        }
    }

}
