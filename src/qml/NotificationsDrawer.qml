import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.9
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

CustomDrawer {
    objectName: "notificationsDrawer"
    property string topBarTitle: qsTr("Notifications")

    CloseDrawerItem {}

    ListSelector {
        id: notificationsListView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 70
        anchors.bottom: parent.bottom
        visible: true
        clip: true
        ScrollBar.vertical: ScrollBar {
            interactive: false
        }
        boundsBehavior: Flickable.StopAtBounds
        boundsMovement: Flickable.StopAtBounds
        model: notificationsList

        snapMode: ListView.SnapToItem

        // The notifications list view cannot be scrolled by dragging but
        // only by using the scroll buttons. Dragging anywhere within the
        // list view will drag the entire notifications drawer.
        interactive: false

        // We want the printing notification button in the notifications drawer
        // when the bot is printing. Since it has a different design from other
        // notifications the easiest approach is to conditionally assign it to
        // the header when printing and not have any header component at other
        // times, but headers cannot be assigned conditionally in QML so we make
        // the printing notification button as the header and have logic in this
        // button to just shrink itself and disappear when not printing. There
        // seems to be some bugs in the way headers are handled in ListViews in
        // QML and this approach is the only one that worked to get the desired
        // behavior. All the other aproaches hid the actual header component but
        // still rendered the header area as an empty block the size of assigned
        // header component.
        header: PrintingNotificationButton {}

        delegate:
            NotificationButton {
                id: buttonNotification
                buttonText: model.modelData.name
                notificationPriority: model.modelData.priority
                onClicked: {
                    notificationsDrawer.close()
                    // model.modelData.func() does not work for some reason
                    notificationsList[index]["func"]()
                    if(notificationPriority != MoreporkUI.NotificationPriority.Persistent) {
                        removeFromNotificationsList(model.modelData.id)
                    }
                }

                openOrDismissButton.onClicked: {
                    if(notificationPriority != MoreporkUI.NotificationPriority.Persistent) {
                        // Remove the notification from the notifiations list for informational
                        // and error notifications
                        removeFromNotificationsList(model.modelData.id)
                    } else {
                        notificationsDrawer.close()
                        // Just execute the callback if it is a persistent notification.
                        // model.modelData.func() does not work for some reason
                        notificationsList[index]["func"]()
                    }
                }
            }

        footer:
            Rectangle {
                z: 2
                height: 80
                width: parent.width
                color: "#000000"

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

                // Buttons to scroll through the notifications list
                RowLayout {
                    id: scrollButtonsLayout
                    anchors.right: parent.right
                    anchors.rightMargin: 40
                    anchors.verticalCenter: parent.verticalCenter
                    z: 3
                    spacing: 30

                    Rectangle {
                        height: 50
                        width: 50
                        radius: 25
                        color: "#00000000"
                        border.width: 2
                        border.color: "#ffffff"
                        opacity: notificationsListView.atYBeginning ? 0.3 : 1

                        Image {
                            source: "qrc:/img/icon_raise.png"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            id: listUp
                            onPressed: {
                                if(!notificationsListView.atYBeginning) {
                                    notificationsListView.flick(0, 500)
                                }
                            }
                        }
                    }

                    Rectangle {
                        height: 50
                        width: 50
                        radius: 25
                        color: "#000000"
                        border.width: 2
                        border.color: "#ffffff"
                        opacity: notificationsListView.atYEnd ? 0.3 : 1

                        Image {
                            source: "qrc:/img/icon_lower.png"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            id: listDown
                            onPressed: {
                                if(!notificationsListView.atYEnd) {
                                    notificationsListView.flick(0, -500)
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    // To prevent clicking through the footer into the
                    // notification underneath
                    z: 2
                    anchors.fill: parent
                }
            }

        footerPositioning: ListView.OverlayFooter
    }

    onOpened: {
        notificationsListView.positionViewAtBeginning()
    }
}
