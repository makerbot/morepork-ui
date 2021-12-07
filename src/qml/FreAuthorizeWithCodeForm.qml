import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.3

LoggingItem {
    itemName: "FreAuthorizeWithCode"
    id: freAuthWithCode
    width: 750
    height: 320
    property string otp: "OOOOOO"
    property string polling_token: "NULL"
    property alias checkAuthTimer: checkAuthTimer
    property alias expireOTPTimer: expireOTPTimer
    property var expires: new Date()
    property string time_left: "0:00"
    property alias refreshOTP: refreshOTP
    property alias continueButton: continueButton
    property alias skipButton: skipButton
    property alias freAuthorizeWithCode_popup: freAuthorizeWithCode_popup

    property int authState: FreAuthorizeWithCode.BaseState

    enum AuthState {
        BaseState,
        FetchingOTP,
        OTPExpired,
        WaitForAuthorized,
        Authorized,
        Failed
    }

    onAuthStateChanged: {
        if(authState == FreAuthorizeWithCode.Failed ||
           authState == FreAuthorizeWithCode.Authorized) {
            freAuthorizeWithCode_popup.open()
        }
    }

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
                authState = FreAuthorizeWithCode.OTPExpired
                checkAuthTimer.stop()
                expireOTPTimer.stop()
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Text {
        id: title_text
        color: "#ffffff"
        text: qsTr("CONNECT")
        font.letterSpacing: 2
        anchors.top: parent.top
        anchors.topMargin: 35
        font.family: defaultFont.name
        font.weight: Font.Bold
        font.pixelSize: 28
    }

    Text {
        id: instructions_text
        width: parent.width
        color: "#cbcbcb"
        text: qsTr("CloudPrint is a browser-based app that enables you " +
                   "to prepare & send files directly to your printer.<br><br>" +
                   "Visit <b>cloudprint.makerbot.com</b><br>to create a Makerbot " +
                   "account and connect your printer to CloudPrint.")
        font.wordSpacing: 1
        font.letterSpacing: 0.2
        wrapMode: Text.WordWrap
        lineHeight: 1.3
        anchors.top: title_text.bottom
        anchors.topMargin: 30
        font.family: defaultFont.name
        font.weight: Font.Light
        font.pixelSize: 18
    }

    RowLayout {
        id: rowLayout
        spacing: 30
        anchors.top: instructions_text.bottom
        anchors.topMargin: 25

        RoundedButton {
            id: continueButton
            label: qsTr("CONTINUE")
            buttonHeight: 50
        }

        RoundedButton {
            id: skipButton
            label: qsTr("SKIP")
            buttonHeight: 50
        }
    }

    BusySpinner {
        id: busySpinner
        visible: false
        spinnerSize: 48
        anchors.verticalCenter: otp_text.verticalCenter
        anchors.horizontalCenter: otp_text.horizontalCenter
    }

    Text {
        id: otp_text
        color: "#ccffffff"
        text: "000000"
        visible: false
        anchors.top: instructions_text.bottom
        anchors.topMargin: 15
        font.letterSpacing: 5
        font.family: defaultFont.name
        font.weight: Font.ExtraLight
        font.pixelSize: 110
    }

    RoundedButton {
        id: refreshOTP
        anchors.left: otp_text.right
        anchors.leftMargin: 20
        anchors.bottom: otp_text.bottom
        anchors.bottomMargin: 20
        width: 55
        height: 55
        forceButtonWidth: true
        radius: width/2
        visible: false
        enabled: authState == FreAuthorizeWithCode.OTPExpired
        smooth: true

        Image {
            id: refresh_image
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/img/refresh_otp.png"
        }

        ColorOverlay {
            anchors.fill: refresh_image
            source: refresh_image
            color: refreshOTP.button_mouseArea.pressed ? "#000000" : "#00000000"
            visible: true
        }
    }

    Text {
        id: expires_in_text
        color: "#cbcbcb"
        visible: false
        anchors.top: otp_text.bottom
        anchors.topMargin: 20
        font.family: defaultFont.name
        font.weight: Font.Light
        font.pixelSize: 18
        font.wordSpacing: 1
        font.letterSpacing: 0.2
    }
    states: [
        State {
            name: "fetching_otp"
            when: authState == FreAuthorizeWithCode.FetchingOTP

            PropertyChanges {
                target: title_text
                visible: false
            }

            PropertyChanges {
                target: instructions_text
                text: qsTr("Once logged into <b>cloudprint.makerbot.com</b>,<br>Select <b>Method Series</b> under “Add Printer” and enter the following code:")
                font.wordSpacing: 1
                font.letterSpacing: 0.2
                lineHeight: 1.8
                anchors.topMargin: -20
            }

            PropertyChanges {
                target: rowLayout
                visible: false
            }

            PropertyChanges {
                target: otp_text
                visible: false
            }

            PropertyChanges {
                target: refreshOTP
                visible: false
            }

            PropertyChanges {
                target: expires_in_text
                visible: false
            }

            PropertyChanges {
                target: busySpinner
                visible: true
            }
        },
        State {
            name: "wait_for_authorized"
            when: authState == FreAuthorizeWithCode.WaitForAuthorized ||
                  authState == FreAuthorizeWithCode.Authorized

            PropertyChanges {
                target: title_text
                visible: false
            }

            PropertyChanges {
                target: instructions_text
                text: qsTr("Once logged into <b>cloudprint.makerbot.com</b>,<br>Select <b>Method Series</b> under “Add Printer” and enter the following code:")
                font.wordSpacing: 1
                font.letterSpacing: 0.2
                lineHeight: 1.8
                anchors.topMargin: -20
            }

            PropertyChanges {
                target: rowLayout
                visible: false
            }

            PropertyChanges {
                target: otp_text
                opacity: 1
                text: otp
                visible: true
            }

            PropertyChanges {
                target: refreshOTP
                visible: false
            }

            PropertyChanges {
                target: expires_in_text
                visible: false
            }

            PropertyChanges {
                target: busySpinner
                visible: false
            }

            PropertyChanges {
                target: expires_in_text
                text: qsTr("This code is valid for %1.").arg(time_left)
                visible: true
            }
        },
        State {
            name: "otp_expired"
            when: authState == FreAuthorizeWithCode.OTPExpired

            PropertyChanges {
                target: title_text
                visible: false
            }

            PropertyChanges {
                target: instructions_text
                text: qsTr("Once logged into <b>cloudprint.makerbot.com</b>,<br>Select <b>Method Series</b> under “Add Printer” and enter the following code:")
                font.wordSpacing: 1
                font.letterSpacing: 0.2
                lineHeight: 1.8
                anchors.topMargin: -20
            }

            PropertyChanges {
                target: rowLayout
                visible: false
            }

            PropertyChanges {
                target: otp_text
                text: otp
                opacity: 0.1
                visible: true
            }

            PropertyChanges {
                target: refreshOTP
                visible: true
            }

            PropertyChanges {
                target: expires_in_text
                visible: false
            }

            PropertyChanges {
                target: busySpinner
                visible: false
            }

            PropertyChanges {
                target: expires_in_text
                text: qsTr("This code has expired.")
                visible: true
            }
        }
    ]

    CustomPopup {
        id: freAuthorizeWithCode_popup
        showOneButton: false
        showTwoButtons: false
        closePolicy: Popup.CloseOnPressOutside
        onClosed: state = "base state"
        onOpened: {
            closePopupTimer.start()
        }

        ColumnLayout {
            height: 100
            anchors.verticalCenter: freAuthorizeWithCode_popup.popupContainer.verticalCenter
            anchors.horizontalCenter: freAuthorizeWithCode_popup.popupContainer.horizontalCenter
            anchors.verticalCenterOffset: -20
            spacing: 40

            Text {
                id: popup_title
                color: "#ffffff"
                text: {
                    if(authState == FreAuthorizeWithCode.Failed) {
                        qsTr("NETWORK ERROR")
                    } else if(authState == FreAuthorizeWithCode.Authorized) {
                        qsTr("CONNECTED TO CLOUDPRINT")
                    }
                }
                font.letterSpacing: 2
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 20
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            Image {
                source: "qrc:/img/process_successful.png"
                sourceSize.width: 85
                sourceSize.height: 85
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                visible: authState == FreAuthorizeWithCode.Authorized
            }
        }
    }
}
