import QtQuick 2.12
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.12

DrawerButton {
    id: notificationButton

    property int notificationPriority: MoreporkUI.NotificationPriority.Informational

    buttonBackgroundColor: {
        notificationPriority == MoreporkUI.NotificationPriority.Persistent ?
                    "#ffffff" : "#333333"
    }
    buttonPressBackgroundColor: {
        notificationPriority == MoreporkUI.NotificationPriority.Persistent ?
                    "#333333" : "#ffffff"
    }
    buttonContentColor: {
        notificationPriority == MoreporkUI.NotificationPriority.Persistent ?
                    "#000000" : "#ffffff"
    }
    buttonPressContentColor: {
        notificationPriority == MoreporkUI.NotificationPriority.Persistent ?
                    "#ffffff" : "#000000"
    }

    property alias buttonText: buttonText.text
    property alias buttonImage: buttonImage.source
    property alias openOrDismissButton: openOrDismissButton

    contentItem:
        Item {
            anchors.fill: parent
            Image {
                z: 1
                id: buttonImage
                width: sourceSize.width
                height: sourceSize.height
                anchors.left: parent.left
                anchors.leftMargin: 60
                anchors.verticalCenter: parent.verticalCenter
                smooth: false
                antialiasing: false
                source: {
                    switch(notificationPriority) {
                    case MoreporkUI.NotificationPriority.Informational:
                        "qrc:/img/informational_notification.png"
                        break;
                    case MoreporkUI.NotificationPriority.Persistent:
                    case MoreporkUI.NotificationPriority.Error:
                        "qrc:/img/error_notification.png"
                        break;
                    default:
                        ""
                    }
                }
            }

            TextBody {
                id: buttonText
                style: TextBody.ExtraLarge
                text: qsTr("Notification Button Text")
                color: notificationButton.down ? buttonPressContentColor : buttonContentColor
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignHCenter
                anchors.left: parent.left
                anchors.leftMargin: 120
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 2
            }

            Image {
                z: 1
                width: sourceSize.width
                height: sourceSize.height
                anchors.right: parent.right
                anchors.rightMargin: 60
                anchors.verticalCenter: parent.verticalCenter
                smooth: false
                antialiasing: false
                source: {
                    switch(notificationPriority) {
                    case MoreporkUI.NotificationPriority.Persistent:
                        "qrc:/img/open_notification.png"
                        break;
                    case MoreporkUI.NotificationPriority.Error:
                    case MoreporkUI.NotificationPriority.Informational:
                        "qrc:/img/dismiss_notification.png"
                        break;
                    default:
                        ""
                    }
                }

                MouseArea {
                    id: openOrDismissButton
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: 75
                    width: 75
                }
            }
        }

    ColorOverlay {
       anchors.fill: contentItem
       source: contentItem
       color: {
           notificationButton.down ? buttonPressContentColor : "#00000000"
       }
   }

    function logClick() {
        console.info("NotificationButton [" + buttonText.text + "] clicked")
    }
}
