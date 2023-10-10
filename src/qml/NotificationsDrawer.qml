import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.9
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import QtGraphicalEffects 1.12

CustomDrawer {
    objectName: "notificationsDrawer"
    property string topBarTitle: qsTr("Notifications")

    CloseDrawerItem {}

    NotificationButton {
        id: buttonOngoingPrint
        anchors.top: parent.top
        anchors.topMargin: 70
        notificationPriority: MoreporkUI.NotificationPriority.Persistent
        buttonText: {
            switch(bot.process.stateType) {
            case ProcessStateType.Printing:
                qsTr("PRINTING: %1").arg(printPage.file_name)
                break;
            case ProcessStateType.Paused:
                qsTr("PAUSED: %1").arg(printPage.file_name)
                break;
            case ProcessStateType.Pausing:
                qsTr("PAUSING: %1").arg(printPage.file_name)
                break;
            case ProcessStateType.Resuming:
                qsTr("RESUMING: %1").arg(printPage.file_name)
                break;
            default:
                qsTr("PRINTING: %1").arg(printPage.file_name)
                break;
            }
        }

        PrintIcon {
            id: printIconInNotificationButton
            smooth: false
            scale: 0.2
            showActionButtons: false
            anchors.left: parent.left
            anchors.leftMargin: -44
            anchors.verticalCenter: parent.verticalCenter
        }

        ColorOverlay {
            anchors.fill: printIconInNotificationButton
            source: printIconInNotificationButton
            color: buttonOngoingPrint.down ? "#ffffff" : "#000000"
            scale: printIconInNotificationButton.scale
        }

        buttonImage: ""
        enabled: bot.process.type == ProcessType.Print
        visible: enabled

        onClicked: {
            goToPrintPage()
        }

        openOrDismissButton.onClicked: {
            goToPrintPage()
        }

        function goToPrintPage() {
            resetSettingsSwipeViewPages()
            mainSwipeView.swipeToItem(MoreporkUI.PrintPage)
        }
    }

    ListSelector {
        id: printQueueList
        visible: true
        boundsBehavior: Flickable.StopAtBounds
        model: notificationsList
        anchors.top: parent.top
        anchors.topMargin: buttonOngoingPrint.visible ? 170 : 70

        populate: Transition {
            NumberAnimation { properties: "x,y"; duration: 500 }
        }

        remove: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; to: 0; duration: 500 }
                NumberAnimation { properties: "x,y"; to: 100; duration: 500 }
            }
         }

        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: 500 }
        }

        delegate:
            NotificationButton {
                id: buttonNotification
                buttonText: model.modelData.name
                notificationPriority: model.modelData.priority
                onClicked: {
                    notificationsDrawer.close()
                    // model.modelData.func() does not work for some reason
                    notificationsList[index]["func"]()
                    removeFromNotificationsList(model.modelData.name)
                }

                openOrDismissButton.onClicked: {
                    if(notificationPriority != MoreporkUI.NotificationPriority.Persistent) {
                        // Remove the notification from the notifiations list for informational
                        // and error notifications
                        removeFromNotificationsList(model.modelData.name)
                    } else {
                        notificationsDrawer.close()
                        // Just execute the callback if it is a persistent notification.
                        // model.modelData.func() does not work for some reason
                        notificationsList[index]["func"]()
                    }
                }
            }

        footer:
            Item {
                height: 100
                width: parent.width

                TextSubheader {
                    text: notificationsState == MoreporkUI.NotificationsState.NoNotifications ?
                              qsTr("NO NOTIFICATIONS") :
                              notificationsList.length > 1 ?
                                  qsTr("%1 NOTIFICATIONS").arg(notificationsList.length) :
                                  qsTr("%1 NOTIFICATION").arg(notificationsList.length)
                    anchors.left: parent.left
                    anchors.leftMargin: 32
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

        footerPositioning: ListView.OverlayFooter
    }
}
