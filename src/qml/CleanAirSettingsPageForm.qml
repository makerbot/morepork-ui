import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

LoggingItem {
    itemName: "CleanAirSettings"
    id: cleanAirSettingsPage
    smooth: false
    anchors.fill: parent
    property int hepaPrintHours: (bot.hepaFilterPrintHours).toFixed(2)
    property int hepaMaxHours: (bot.hepaFilterMaxHours).toFixed(2)
    property bool alert: bot.hepaFilterChangeRequired || !isFilterConnected()

    property alias cleanAirSettingsSwipeView: cleanAirSettingsSwipeView

    enum SwipeIndex {
        BasePage,                   // 0
        ReplaceFilterPage           // 1
    }

    LoggingSwipeView {
        id: cleanAirSettingsSwipeView
        logName: "cleanAirSettingsSwipeView"
        currentIndex: CleanAirSettingsPage.BasePage
        smooth: false
        visible: true

        // CleanAirSettingsPage.BasePage
        Item {
            id: itemCleanAirSettings
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage

            ContentLeftSide {
                visible: true
                loadingIcon {
                    loadingProgress: (hepaPrintHours *100)/ hepaMaxHours
                    icon_image: {
                        if(alert) {
                            LoadingIcon.Failure
                        } else {
                            LoadingIcon.Progress
                        }
                    }
                    visible: true
                }
            }

            ContentRightSide {
                visible: true
                textHeader {
                    text: isFilterConnected() ? qsTr("Filter Status") :
                                                qsTr("Clean Air Not Detected")
                    visible: true
                }
                textBody {
                    text: qsTr("Lifetime is dependent on multiple factors.")
                    visible: isFilterConnected()
                }
                timeStatus {
                    currentValue: hepaPrintHours
                    lifetimeValue: hepaMaxHours
                    exceededLifetimeValue: bot.hepaFilterChangeRequired
                    visible: isFilterConnected()
                }
                buttonSecondary1 {
                    text: qsTr("REPLACE FILTER")
                    visible: true
                    onClicked: {
                        cleanAirSettingsSwipeView.swipeToItem(CleanAirSettingsPage.ReplaceFilterPage)
                    }
                }
                buttonSecondary2 {
                    text: qsTr("RESET FILTER")
                    enabled: isFilterConnected()
                    visible: true
                    onClicked: {
                        hepaFilterResetPopup.open()
                    }
                }
            }
        }

        // CleanAirSettingsPage.ReplaceFilterPage
        Item {
            id: replaceFilterItem
            property var backSwiper: cleanAirSettingsSwipeView
            property int backSwipeIndex: CleanAirSettingsPage.BasePage
            property string topBarTitle: qsTr("Replace Filter")
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
                else
                    cleanAirSettingsSwipeView.swipeToItem(CleanAirSettingsPage.BasePage)
            }

            ReplaceFilterPage {
                id: replaceFilterPage
            }
        }
    }
}
