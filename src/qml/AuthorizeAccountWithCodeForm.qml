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
                checkAuthTimer.stop()
                expireOTPTimer.stop()
                beginAuthWithCode()
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
    }

    Text {
        id: expires_in_text
        width: 155
        color: "#cbcbcb"
        text: qsTr("Expires In %1").arg(time_left)
        anchors.right: parent.right
        anchors.rightMargin: 50
        font.pixelSize: 18
        anchors.top: otp_text.bottom
        font.family: defaultFont.name
        font.weight: Font.Light
        wrapMode: Text.WordWrap
        anchors.topMargin: 10
        font.letterSpacing: 1
    }

    Text {
        id: otp_instructions_text
        width: 700
        color: "#cbcbcb"
        text: qsTr("To add this printer to your account visit my.makerbot.com or " +
                   "download the MakerBot Connect application. Then press the 'Add " +
                   "a Printer' button and choose 'Authorize With Printer Code'.")
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
}
