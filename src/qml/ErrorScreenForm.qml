import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import ErrorTypeEnum 1.0

Item {
    width: 800
    height: 440
    smooth: false

    property alias button1: button1
    property alias button2: button2
    property int errorCode: bot.process.errorType

    onErrorCodeChanged: {
        switch(errorCode) {
        case ErrorType.LidNotPlaced:
            if(bot.process.type == ProcessType.Print) {
                state = "lid_open_error"
            }
            break;
        case ErrorType.DoorNotClosed:
            if(bot.process.type == ProcessType.Print) {
                state = "door_open_error"
            }
            break;
        default:
            state = "base state"
            break;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Item {
        id: mainItem
        anchors.fill: parent

        Image {
            id: errorImage
            width: sourceSize.width
            height: sourceSize.height
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/img/error_close_door.png"
        }

        Item {
            id: errorMessageContainer
            width: 350
            height: 350
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: errorImage.right
            anchors.leftMargin: 30

            Image {
                id: errorIcon
                width: 35
                height: 35
                anchors.top: parent.top
                anchors.topMargin: 10
                source: "qrc:/img/alert.png"
            }

            Text {
                id: errorMessageTitle
                text: "ERROR TITLE"
                anchors.top: parent.top
                anchors.topMargin: 65
                font.bold: true
                font.family: "Antennae"
                font.weight: Font.Bold
                font.pixelSize: 26
                font.letterSpacing: 2
                lineHeight: 1.1
                color: "#ffffff"
                smooth: false
                antialiasing: false
            }

            Text {
                id: errorMessageDescription
                text: "Error description"
                anchors.top: errorMessageTitle.bottom
                anchors.topMargin: 30
                font.family: "Antennae"
                font.pixelSize: 18
                lineHeight: 1.2
                color: "#e8e8e8"
                smooth: false
                antialiasing: false
            }

            RoundedButton {
                id: button1
                anchors.top: errorMessageDescription.bottom
                anchors.topMargin: 30
                label: "BUTTON 1"
                label_width: 250
                label_size: 22
                buttonWidth: 260
                buttonHeight: 50
            }

            RoundedButton {
                id: button2
                anchors.top: button1.bottom
                anchors.topMargin: 20
                label: "BUTTON 2"
                label_width: 200
                label_size: 22
                buttonWidth: 260
                buttonHeight: 50
            }
        }
    }
    states: [
        State {
            name: "door_open_error"

            PropertyChanges {
                target: errorImage
                source: "qrc:/img/error_close_door.png"
            }

            PropertyChanges {
                target: errorMessageTitle
                text: "PRINT PAUSED.\nCLOSE BUILD\nCHAMBER DOOR."
            }

            PropertyChanges {
                target: errorMessageDescription
                text: "Close the build chamber door to\ncontinue printing."
            }

            PropertyChanges {
                target: button2
                visible: false
            }

            PropertyChanges {
                target: button1
                label: "RESUME PRINT"
            }
        },

        State {
            name: "lid_open_error"

            PropertyChanges {
                target: errorImage
                source: "qrc:/img/error_close_door.png"
            }

            PropertyChanges {
                target: errorMessageTitle
                text: "PRINT PAUSED.\nCLOSE THE\nTOP LID."
            }

            PropertyChanges {
                target: errorMessageDescription
                text: "Put the lid back on the printer\nto continue printing."
            }

            PropertyChanges {
                target: button2
                visible: false
            }

            PropertyChanges {
                target: button1
                label: "RESUME PRINT"
            }
        },
        State {
            name: "filament_jam_error"

            PropertyChanges {
                target: errorIcon
                visible: false
            }

            PropertyChanges {
                target: errorMessageTitle
                text: "MATERIAL JAM\nDETECTED"
                anchors.topMargin: 40
            }
        }
    ]



}
