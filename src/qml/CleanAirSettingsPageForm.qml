import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import MachineTypeEnum 1.0

LoggingItem {
    itemName: "CleanAirSettings"
    id: cleanAirSettingsPage
    width: 800
    height: 408
    smooth: false
    anchors.fill: parent.fill
    property int hepaPrintHours: (bot.hepaFilterPrintHours).toFixed(2)
    property int hepaMaxHours: (bot.hepaFilterMaxHours).toFixed(2)
    property bool alert: bot.hepaFilterChangeRequired ||
                         (!isFilterConnected() && bot.machineType != MachineType.Magma)

    ContentLeftSide {
        visible: true
        loadingIcon {
            loadingProgress: alert ? 0 : (hepaPrintHours *100)/ hepaMaxHours
            icon_image: {
                if(alert) {
                    LoadingIcon.Failure
                } else {
                    LoadingIcon.Loading
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
                    settingsSwipeView.swipeToItem(SettingsPage.ReplaceFilterXLPage)
                } else {
                    settingsSwipeView.swipeToItem(SettingsPage.ReplaceFilterPage)
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
