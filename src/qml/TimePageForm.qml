import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

LoggingItem {
    smooth: false

    property alias timeZoneSelectorPage: timeZoneSelectorPage
    property alias timeSelectorPage: timeSelectorPage
    property alias timeSwipeView: timeSwipeView

    enum SwipeIndex {
        BasePage,
        SetTimeZone,
        SetDate,
        SetTime
    }

    LoggingSwipeView {
        id: timeSwipeView
        logName: "timeSwipeView"
        currentIndex: TimePage.BasePage

        function customSetCurrentItem(swipeToIndex) {
            if(swipeToIndex == TimePage.BasePage) {
                // When swiping to the 0th index of this swipeview set the
                // settings page item that holds this page as the current
                // item since we want the back button to use the settings
                // items' altBack()
                setCurrentItem(systemSettingsSwipeView.itemAt(SystemSettingsPage.TimePage))
                return true
            }
        }

        // TimePage.BasePage
        Item {
            id: itemBasePage
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            property string topBarTitle: qsTr("Set Date")
            smooth: false
            visible: true

            TimeSettings {
                id: timeSettingsPage
            }
        }

        // TimePage.SetTimeZone
        Item {
            id: itemSetTimeZone
            property var backSwiper: timeSwipeView
            property int backSwipeIndex: TimePage.SetDate
            property string topBarTitle: qsTr("Set Time Zone")
            smooth: false
            visible: false

            TimeZoneSelector {
                id: timeZoneSelectorPage
            }
        }

        // TimePage.SetDate
        Item {
            id: itemSetDate
            property var backSwiper: timeSwipeView
            property int backSwipeIndex: TimePage.BasePage
            smooth: false
            visible: false

            DateSelector {
                id: dateSelectorPage
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
