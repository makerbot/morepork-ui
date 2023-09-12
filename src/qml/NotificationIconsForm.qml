import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import FreStepEnum 1.0

Row {
    height: 72
    spacing: 20

    AnimatedImage {
        id: hepaFilterStatus
        smooth: false
        height: sourceSize.height
        width: sourceSize.width
        visible: bot.hepaFilterConnected
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
            border.color: {
                switch(currentActiveDrawer) {
                case MoreporkUI.NotificationsDrawer:
                    switch(notificationsState) {
                    case MoreporkUI.NotificationsState.NoNotifications:
                    case MoreporkUI.NotificationsState.NotificationsAvailable:
                        "#ffffff"
                        break;
                    case MoreporkUI.NotificationsState.ErrorNotificationsAvailable:
                        "#fca833"
                        break;
                    }
                    break;
                case MoreporkUI.OtherDrawers:
                    "#ffffff"
                    break;
                }
            }
            color: {
                switch(currentActiveDrawer) {
                case MoreporkUI.NotificationsDrawer:
                    switch(notificationsState) {
                    case MoreporkUI.NotificationsState.NoNotifications:
                        "#00000000"
                        break;
                    case MoreporkUI.NotificationsState.ErrorNotificationsAvailable:
                        "#fca833"
                        break;
                    case MoreporkUI.NotificationsState.NotificationsAvailable:
                        "#ffffff"
                        break;
                    }
                    break;
                case MoreporkUI.OtherDrawers:
                    "#ffffff"
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
                        switch(currentActiveDrawer) {
                        case MoreporkUI.NotificationsDrawer:
                            ""
                            break;
                        case MoreporkUI.OtherDrawers:
                            "qrc:/img/drawer_down.png"
                            break;
                        }
                        break;
                    case MoreporkUI.DrawerState.Open:
                        "qrc:/img/drawer_up.png"
                        break;
                    default:
                        break;
                    }
                }
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextBody {
                text: notificationsList.length
                color: "#000000"
                visible: {
                    currentActiveDrawer == MoreporkUI.NotificationsDrawer &&
                    notificationsState != MoreporkUI.NotificationsState.NoNotifications &&
                    drawerState == MoreporkUI.DrawerState.Closed
                }
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 1
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 1
                font.weight: Font.Bold
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
