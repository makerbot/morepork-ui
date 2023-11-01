import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.9
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import QtGraphicalEffects 1.12

// This component is the persistent printing notification button that shows up at the
// top of the notifications drawer when printing. It is assigned to the header of the
// list view in the notifications drawer. It shrinks itself and hides its contents when
// not printing.
Item {
    id: notificationItem
    height: bot.process.type == ProcessType.Print ? 100 : 0
    width: parent.width

    NotificationButton {
        id: buttonOngoingPrint
        visible: bot.process.type == ProcessType.Print
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
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

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
}
