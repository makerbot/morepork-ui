import QtQuick 2.10
import QtQuick.Layouts 1.12

Item {
    id: element
    anchors.fill: parent
    property string otp: "OOOOOO"
    property string polling_token: "NULL"
    property alias checkAuthTimer: checkAuthTimer
    property alias expireOTPTimer: expireOTPTimer
    property var expires: new Date()
    property string time_left: "0:00"
    property bool otp_expired: false
    property alias getOTPButton: getOTPButton

    Timer {
        id: checkAuthTimer
        interval: 5000
        repeat: true
        onTriggered: {
            network.checkAuthWithCode(otp, polling_token)
        }
    }

    Timer {
        id: expireOTPTimer
        interval: 1000
        repeat: true
        onTriggered: {
            var now = new Date()
            if (expires > now) {
                var dt = new Date(expires - now)
                var s = dt.getSeconds()
                time_left = dt.getMinutes() + ":" + (s > 10 ? s : "0" + s)
            } else {
                otp_expired = true
                checkAuthTimer.stop()
                expireOTPTimer.stop()
            }
        }
    }

    ColumnLayout {
        width: parent.width - 60
        height: children.height + 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -10
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 50

        ColumnLayout {
            spacing: 10
            TextBody {
                style: TextBody.Large
                text: qsTr("Log into CloudPrint and enter the code below")
                font.weight: Font.Medium
            }

            TextBody {
                style: TextBody.Large
                text: "<b>cloudprint.makerbot.com</b>  |  <b>" + qsTr("Add Printer > Method Series") + "</b>"
                font.weight: Font.Bold
            }
        }

        TextHuge {
            id: otp_text
            text: otp
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            opacity: otp_expired ? 0.2 : 1
        }

        TextSubheader {
            text: {
                otp_expired ? qsTr("This code has expired.") :
                              qsTr("This code is valid for %1").arg(time_left)
            }
        }
    }

    RefreshButton {
        id: getOTPButton
        enabled: otp_expired
    }
}
