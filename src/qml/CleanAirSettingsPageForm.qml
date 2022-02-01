import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    id: cleanAirSettingsPage
    width: 800
    height: 440
    smooth: false

    property alias cleanAirSettingsSwipeView: cleanAirSettingsSwipeView

    property alias buttonFilterStatus: buttonFilterStatus
    property alias buttonReplaceFilter: buttonReplaceFilter

    enum PageIndex {
        BasePage,                   // 0
        FilterStatusPage,           // 1
        ReplaceFilterPage           // 2
    }
    
    LoggingSwipeView {
        id: cleanAirSettingsSwipeView
        currentIndex: CleanAirSettingsPage.BasePage

        // CleanAirSettingsPage.BasePage
        Item {
            id: itemCleanAirSettings
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage

            smooth: false
            visible: true

            Flickable {
                id: flickableCleanAirSettings
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnCleanAirSettings.height

                Column {
                    id: columnCleanAirSettings
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MenuButton {
                        id: buttonFilterStatus
                        buttonText.text: qsTr("FILTER STATUS")
                        enabled: isFilterConnected()
                        onClicked: {
                            bot.getFilterHours()
                            cleanAirSettingsSwipeView.swipeToItem(CleanAirSettingsPage.FilterStatusPage)
                        }
                    }

                    MenuButton {
                        id: buttonReplaceFilter
                        buttonText.text: qsTr("REPLACE FILTER")
                        onClicked: {
                            cleanAirSettingsSwipeView.swipeToItem(CleanAirSettingsPage.ReplaceFilterPage)
                        }
                    }
                }
            }
        }

        // CleanAirSettingsPage.FilterStatusPage
        Item {
            id: filterStatusItem
            property var backSwiper: cleanAirSettingsSwipeView
            property int backSwipeIndex: CleanAirSettingsPage.BasePage
            smooth: false
            visible: false

            FilterStatusPage {

            }
        }

        // CleanAirSettingsPage.ReplaceFilterPage
        Item {
            id: replaceFilterItem
            property var backSwiper: cleanAirSettingsSwipeView
            property int backSwipeIndex: CleanAirSettingsPage.BasePage
            smooth: false
            visible: false

            property bool hasAltBack: true

            function altBack() {
                if (replaceFilterPage.itemReplaceFilter.state == "done")
                    cleanAirSettingsSwipeView.swipeToItem(CleanAirSettingsPage.BasePage)
                else if (replaceFilterPage.itemReplaceFilter.state == "step_2")
                    replaceFilterPage.itemReplaceFilter.state = "done"
                else if (replaceFilterPage.itemReplaceFilter.state == "step_3")
                    replaceFilterPage.itemReplaceFilter.state = "step_2"
                else if (replaceFilterPage.itemReplaceFilter.state == "step_4")
                    replaceFilterPage.itemReplaceFilter.state = "step_3"
                else if (replaceFilterPage.itemReplaceFilter.state == "step_5")
                    replaceFilterPage.itemReplaceFilter.state = "step_4"
                else
                    cleanAirSettingsSwipeView.swipeToItem(CleanAirSettingsPage.BasePage)
            }

            ReplaceFilterPage {
                id: replaceFilterPage
            }
        }
    }
}
