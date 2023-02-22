import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 800
    height: 440
    smooth: false

    property alias timeZoneSelectorPage: timeZoneSelectorPage
    property alias timeSelectorPage: timeSelectorPage
    property alias timeSwipeView: timeSwipeView

    enum SwipeIndex {
        SetDate,
        SetTimeZone,
        SetTime
    }

    LoggingSwipeView {
        id: timeSwipeView
        logName: "timeSwipeView"
        currentIndex: TimePage.SetDate

        function customSetCurrentItem(swipeToIndex) {
            if(swipeToIndex == TimePage.SetDate) {
                // When swiping to the 0th index of this swipeview set the
                // settings page item that holds this page as the current
                // item since we want the back button to use the settings
                // items' altBack()
                setCurrentItem(systemSettingsSwipeView.itemAt(SystemSettingsPage.TimePage))
                return true
            }
        }

        // TimePage.SetDate
        Item {
            id: itemSetDate
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            property string topBarTitle: qsTr("Set Date")
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
            property string topBarTitle: qsTr("Set Time Zone")
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
            property string topBarTitle: qsTr("Set Time")
            smooth: false
            visible: false

            TimeSelector {
                id: timeSelectorPage

            }
        }
    }
}
