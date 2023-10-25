import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

LoggingItem {
    itemName: "CleanAirSettings"
    id: cleanAirSettingsPage
    width: 800
    height: 408
    smooth: false
    anchors.fill: parent.fill
    property int hepaPrintHours: (bot.hepaFilterPrintHours).toFixed(2)
    property int hepaMaxHours: (bot.hepaFilterMaxHours).toFixed(2)
    property bool alert: bot.hepaFilterChangeRequired || !isFilterConnected()

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
                settingsSwipeView.swipeToItem(SettingsPage.ReplaceFilterPage)
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
