import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import MachineTypeEnum 1.0

LoggingItem {
    itemName: "CleanAirSettings"
    id: cleanAirSettingsPage
    smooth: false
    anchors.fill: parent
    property int hepaPrintHours: (bot.hepaFilterPrintHours).toFixed(2)
    property int hepaMaxHours: (bot.hepaFilterMaxHours).toFixed(2)
    property bool alert: bot.hepaFilterChangeRequired ||
                         (!isFilterConnected() && bot.machineType != MachineType.Magma)

    property alias cleanAirSettingsSwipeView: cleanAirSettingsSwipeView

    enum SwipeIndex {
        BasePage,                   // 0
        ReplaceFilterPage,          // 1
        ReplaceFilterXLPage         // 2
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
                    text: (isFilterConnected() || bot.machineType == MachineType.Magma) ?
                              qsTr("Filter Status") :
                              qsTr("Clean Air Not Detected")
                    visible: true
                }
                textBody {
                    text: qsTr("Lifetime is dependent on multiple factors.")
                    visible: (isFilterConnected() || bot.machineType == MachineType.Magma)
                }
                timeStatus {
                    currentValue: hepaPrintHours
                    lifetimeValue: hepaMaxHours
                    exceededLifetimeValue: bot.hepaFilterChangeRequired
                    visible: (isFilterConnected() || bot.machineType == MachineType.Magma)
                }
                buttonSecondary1 {
                    text: qsTr("REPLACE FILTER")
                    visible: true
                    onClicked: {
                        if(bot.machineType == MachineType.Magma) {
                            cleanAirSettingsSwipeView.swipeToItem(CleanAirSettingsPage.ReplaceFilterXLPage)
                        } else {
                            cleanAirSettingsSwipeView.swipeToItem(CleanAirSettingsPage.ReplaceFilterPage)
                        }
                    }
                }
                buttonSecondary2 {
                    text: qsTr("RESET FILTER")
                    enabled: (isFilterConnected() || bot.machineType == MachineType.Magma)
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

        // CleanAirSettingsPage.ReplaceFilterXLPage
        Item {
            id: replaceFilterXLItem
            property var backSwiper: cleanAirSettingsSwipeView
            property int backSwipeIndex: CleanAirSettingsPage.BasePage
            property string topBarTitle: qsTr("Replace Filter")
            property bool backIsCancel: (replaceFilterXLPage.itemReplaceFilterXL.state == "moving_build_plate") ||
                                        (replaceFilterXLPage.itemReplaceFilterXL.state == "done" &&
                                         replaceFilterXLPage.isBuildPlateRaised)
            smooth: false
            visible: false

            property bool hasAltBack: true

            function altBack() {
                replaceFilterXLPage.goBack()
            }

            ReplaceFilterXLPage {
                id: replaceFilterXLPage
            }
        }
    }
}
