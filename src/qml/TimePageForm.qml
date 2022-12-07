import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
//    width: dimensions["content"]["width"]
//    height: dimensions["contetn"]["height"]
    width: 800
    height: 408
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
                setCurrentItem(settingsSwipeView.itemAt(SettingsPage.TimePage))
                return true
            }
        }

        // TimePage.BasePage
        Item {
            id: itemBasePage
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
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
            property int backSwipeIndex: TimePage.BasePage
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
            property int backSwipeIndex: TimePage.BasePage
            smooth: false
            visible: false

            TimeSelector {
                id: timeSelectorPage
            }
        }
    }
}
