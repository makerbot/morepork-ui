import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    id: calibrationPage
    width: 800
    height: 440
    smooth: false
    antialiasing: false
    property alias buttonOk: buttonOk
    property alias toolheadA: toolheadA
    property alias toolheadB: toolheadB
    property alias xyCalibrateButton: xyCalibrateButton
    property alias zCalibrateButton : zCalibrateButton
    property alias buildPlateAttached: buildPlateAttached
    property alias buildPlateRemoved: buildPlateRemoved

    property int errorCode
    property bool hasFailed: bot.process.errorCode != 0
    onHasFailedChanged: {
        if(bot.process.errorCode != 0) {
            errorCode = bot.process.errorCode
            state = "failed"
        }
    }

    Switch {
        id: toolheadA
        checked: true
        anchors.horizontalCenterOffset: -250
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        Text {
            text: "Toolhead A/1"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -20
            color: "#ffffff"
            font.family: "Antennae"
            font.weight: Font.Light
            font.pixelSize: 18
        }
    }

    Switch {
        id: toolheadB
        checked: true
        anchors.horizontalCenterOffset: -50
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        Text {
            text: "Toolhead B/2"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -20
            color: "#ffffff"
            font.family: "Antennae"
            font.weight: Font.Light
            font.pixelSize: 18
        }
    }

    RoundedButton {
        id: xyCalibrateButton
        anchors.top: parent.top
        anchors.topMargin: 90
        anchors.horizontalCenterOffset: -150
        anchors.horizontalCenter: parent.horizontalCenter
        buttonWidth: 240
        buttonHeight: 50
        label: "XY Calibrate"
    }

    RoundedButton {
        id: zCalibrateButton
        anchors.horizontalCenterOffset: -150
        anchors.top: parent.top
        anchors.topMargin: 165
        anchors.horizontalCenter: parent.horizontalCenter
        buttonWidth: 200
        buttonHeight: 50
        label: "Z Calibrate"
    }

    RoundedButton {
        id: buildPlateAttached
        anchors.top: parent.top
        anchors.topMargin: 325
        anchors.horizontalCenterOffset: -150
        anchors.horizontalCenter: parent.horizontalCenter
        buttonWidth: 240
        buttonHeight: 75
        label: "BUILD PLATE INSTALLED"
    }

    RoundedButton {
        id: buildPlateRemoved
        anchors.horizontalCenterOffset: -150
        anchors.top: parent.top
        anchors.topMargin: 235
        anchors.horizontalCenter: parent.horizontalCenter
        buttonWidth: 220
        buttonHeight: 75
        label: "BUILD PLATE REMOVED"
    }

    Text {
        id: currentStepText
        text: bot.process.stepStr
        color: "#ffffff"
        font.family: "Antennae"
        font.pixelSize: 24
        font.weight: Font.Light
        anchors.left: parent.left
        anchors.leftMargin: 500
        anchors.top: parent.top
        anchors.topMargin: 210
    }

    Image {
        id: image
        width: sourceSize.width
        height: sourceSize.height
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        visible: false
        source: "qrc:/img/firmware_update_error.png"

        Text {
            id: text1
            text: "CALIBRATION FAILED"
            anchors.top: parent.bottom
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#ffffff"
            font.letterSpacing: 2
            font.family: "Antennae"
            font.pixelSize: 24
            font.weight: Font.Light
        }

        Text {
            id: text2
            text: "Error " + errorCode
            anchors.top: text1.bottom
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#ffffff"
            font.family: "Antennae"
            font.pixelSize: 24
            font.weight: Font.Light
        }

        RoundedButton {
            id: buttonOk
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: text2.bottom
            anchors.topMargin: 25
            buttonHeight: 50
            buttonWidth: 80
            label: "OK"
        }
    }

    states: [
        State {
            name: "failed"

            PropertyChanges {
                target: toolheadA
                visible: false
            }

            PropertyChanges {
                target: toolheadB
                visible: false
            }

            PropertyChanges {
                target: xyCalibrateButton
                visible: false
            }

            PropertyChanges {
                target: zCalibrateButton
                visible: false
            }

            PropertyChanges {
                target: buildPlateAttached
                visible: false
            }

            PropertyChanges {
                target: buildPlateRemoved
                visible: false
            }

            PropertyChanges {
                target: currentStepText
                visible: false
            }

            PropertyChanges {
                target: image
                visible: true
            }
        }
    ]
}
