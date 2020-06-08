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

    enum SwipeIndex {
        SetDate,
        SetTimeZone,
        SetTime
    }

    SwipeView {
        id: timeSwipeView
        currentIndex: TimePage.SetDate
        smooth: false
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = timeSwipeView.currentIndex
            timeSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            if(itemToDisplayDefaultIndex == TimePage.SetDate) {
                // When we swipe to the 0th index of this page set
                // the current item as the settings page item that
                // holds this page since we want the back button to
                // use the settings item's altBack()
                setCurrentItem(settingsSwipeView.itemAt(SettingsPage.TimePage))
            } else {
                setCurrentItem(timeSwipeView.itemAt(itemToDisplayDefaultIndex))
            }
            timeSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            timeSwipeView.itemAt(prevIndex).visible = false
        }

        // TimePage.SetDate
        Item {
            id: itemSetDate
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            smooth: false
            visible: true

            DateSelector {
                id: dateSelectorPage

            }
        }

        // TimePage.SetTimeZone
        Item {
            id: itemSetTimeZone
            property var backSwiper: timeSwipeView
            property int backSwipeIndex: TimePage.SetDate
            smooth: false
            visible: true

            TimeZoneSelector {
                id: timeZoneSelectorPage

            }
        }

        // TimePage.SetTime
        Item {
            id: itemSetTime
            property var backSwiper: timeSwipeView
            property int backSwipeIndex: TimePage.SetTimeZone
            smooth: false
            visible: false

            TimeSelector {
                id: timeSelectorPage

            }
        }
    }
}
