import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import FreStepEnum 1.0
import MachineTypeEnum 1.0

Row {
    height: 72
    spacing: 20

    AnimatedImage {
        id: hepaFilterStatus
        smooth: false
        height: sourceSize.height
        width: sourceSize.width
        visible: (bot.hepaFilterConnected && (bot.machineType != MachineType.Magma)) ||
                  bot.hepaFilterChangeRequired
        source: bot.hepaFilterChangeRequired ? "qrc:/img/yellow_hepa_blink.gif" : "qrc:/img/white_hepa_no_blink.gif"
        cache: false
        anchors.verticalCenter: parent.verticalCenter
    }

    Image {
        id: networkConnectionStatus
        height: sourceSize.height
        width: sourceSize.width
        anchors.verticalCenter: parent.verticalCenter
        source: {
            switch(bot.net.interface) {
            case "wifi":
                "qrc:/img/wifi_connected.png"
                break;
            case "ethernet":
                "qrc:/img/ethernet_connected.png"
                break;
            default:
                "qrc:/img/no_ethernet.png"
                break;
            }
        }
    }

    Item {
        id: notificationsAndDrawerStatusItem
        width: 32
        height: topBar.height
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            width: 28
            height: 28
            radius: 14
            border.width: 2
            border.color: "#ffffff"
            color: {
                switch(drawerState) {
                case MoreporkUI.DrawerState.NotAvailable:
                    "#000000"
                    break;
                case MoreporkUI.DrawerState.Closed:
                case MoreporkUI.DrawerState.Open:
                    "#ffffff"
                    break;
                default:
                    "#00000000"
                    break;
                }
            }
            anchors.verticalCenter: parent.verticalCenter

            Image {
                smooth: false
                z: 1
                source: {
                    switch(drawerState) {
                    case MoreporkUI.DrawerState.Closed:
                        "qrc:/img/drawer_down.png"
                        break;
                    case MoreporkUI.DrawerState.Open:
                        "qrc:/img/drawer_up.png"
                        break;
                    case MoreporkUI.DrawerState.NotAvailable:
                    default:
                        break;
                    }
                }
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        LoggingMouseArea {
            logText: "[^TopDrawerDown^]"
            smooth: false
            anchors.fill: parent
            z: 2
            onClicked: drawerDownClicked()
        }
    }
}
