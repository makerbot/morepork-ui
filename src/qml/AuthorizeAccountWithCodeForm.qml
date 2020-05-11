import QtQuick 2.10

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

    Text {
        id: otp_text
        color: "#ffffff"
        text: otp
        anchors.top: parent.top
        anchors.topMargin: 75
        anchors.horizontalCenter: parent.horizontalCenter
        font.letterSpacing: 5
        font.family: defaultFont.name
        font.weight: Font.Light
        font.pixelSize: 140
        opacity: otp_expired ? 0.2 : 1
    }

    Text {
        id: otp_instructions_text
        width: 700
        color: "#cbcbcb"
        text: qsTr("To add this printer to your account visit MakerBot.com/authorize " +
                   "and enter the code above. ") +
              (otp_expired ? qsTr("This code has expired.") :
                             qsTr("This code is valid for %1.").arg(time_left))
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        anchors.top: otp_text.bottom
        anchors.topMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: defaultFont.name
        font.weight: Font.Light
        font.pixelSize: 18
        font.letterSpacing: 1
        lineHeight: 1.2
    }

    RoundedButton {
        id: getOTPButton
        label: qsTr("GET NEW CODE")
        buttonHeight: 50
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: otp_instructions_text.bottom
        anchors.topMargin: 30
        visible: otp_expired
    }
}
