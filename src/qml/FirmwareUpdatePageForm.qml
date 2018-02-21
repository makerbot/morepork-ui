import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    id: item1
    width: 800
    height: 440
    smooth: false
    antialiasing: false
    property alias button1: button1
    property alias button2: button2

    Rectangle {
        id: loading_icon
        width: 250
        height: 250
        color: "#00000000"
        radius: 125
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.verticalCenterOffset: -20
        anchors.verticalCenter: parent.verticalCenter
        border.width: 3
        border.color: "#484848"
        antialiasing: true
        smooth: true
        visible: true

        Image {
            id: inner_image
            width: 68
            height: 68
            smooth: false
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/img/loading_gears.png"
            visible: parent.visible

            RotationAnimator {
                target: inner_image
                from: 360000
                to: 0
                duration: 10000000
                running: parent.visible
            }
        }

        Image {
            id: outer_image
            width: 214
            height: 214
            smooth: false
            source: "qrc:/img/loading_rings.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            visible: parent.visible

            RotationAnimator {
                target: outer_image
                from: 0
                to: 360000
                duration: 10000000
                running: parent.visible
            }
        }
    }

    Image {
        id: image
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.verticalCenterOffset: -20
        anchors.verticalCenter: parent.verticalCenter
        visible: false
    }

    Item {
        id: columnLayout
        x: 400
        width: 350
        height: 150
        anchors.verticalCenterOffset: -20
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: main_status_text
            text: "CHECKING FOR UPDATES"
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: 0
            wrapMode: Text.WordWrap
            font.letterSpacing: 3
            color: "#cbcbcb"
            font.family: "Antennae"
            font.weight: Font.Bold
            font.capitalization: Font.AllUppercase
            font.pixelSize: 20
            lineHeight: 1.35
            visible: true
        }

        Text {
            id: sub_status_text
            text: "PLEASE WAIT A MOMENT"
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: 70
            font.wordSpacing: 1
            font.letterSpacing: 2
            color: "#cbcbcb"
            font.family: "Antennae"
            font.weight: Font.Light
            font.capitalization: Font.AllUppercase
            font.pixelSize: 18
            lineHeight: 1.35
            wrapMode: Text.WordWrap
            visible: true
        }

        Text {
            id: release_notes_text
            text: "RELEASE NOTES"
            color: "#cbcbcb"
            font.family: "Antennae"
            font.weight: Font.Light
            font.underline: true
            font.capitalization: Font.AllUppercase
            font.pixelSize: 18
            visible: false
            anchors.top: parent.top
            anchors.topMargin: 0

            MouseArea {
                id: viewReleaseNotesMouseArea
                anchors.fill: parent
                onClicked: {
                    rootAppWindow.viewReleaseNotes = true
                    firmwareUpdatePopup.open()
                }
            }
        }

        RoundedButton {
            id: button1
            buttonWidth: 265
            buttonHeight: 50
            label: "TEXT"
            visible: false
            anchors.top: parent.top
            anchors.topMargin: 0
        }

        RoundedButton {
            id: button2
            visible: false
            anchors.top: parent.top
            anchors.topMargin: 0
        }
    }
    states: [
        State {
            name: "firmware_update_available"
            when: isfirmwareUpdateAvailable && bot.process.type != ProcessType.FirmwareUpdate

            PropertyChanges {
                target: loading_icon
                visible: false
            }

            PropertyChanges {
                target: image
                source: "qrc:/img/firmware_update_available.png"
                height: sourceSize.height
                width: sourceSize.width
                visible: true
            }

            PropertyChanges {
                target: main_status_text
                text: "NEW SOFTWARE AVAILABLE"
                anchors.topMargin: 30
            }

            PropertyChanges {
                target: sub_status_text
                text: "A NEW VERSION OF SOFTWARE IS AVAILABLE. DO YOU WANT TO UPDATE TO THE MOST RECENT VERSION " + bot.firmwareUpdateVersion + " ?"
                anchors.topMargin: 110
            }

            PropertyChanges {
                target: release_notes_text
                anchors.topMargin: 235
                visible: true
            }

            PropertyChanges {
                target: button1
                anchors.topMargin: 275
                buttonWidth: 265
                buttonHeight: 50
                label: "INSTALL UPDATE"
                visible: true
            }

            PropertyChanges {
                target: button2
                visible: false
            }

            PropertyChanges {
                target: columnLayout
                height: 335
            }
        },
        State {
            name: "no_firmware_update_available"
            when: !isfirmwareUpdateAvailable && bot.process.type != ProcessType.FirmwareUpdate

            PropertyChanges {
                target: loading_icon
                visible: false
            }

            PropertyChanges {
                target: image
                source: "qrc:/img/firmware_update_success.png"
                height: sourceSize.height
                width: sourceSize.width
                visible: true
            }

            PropertyChanges {
                target: main_status_text
                text: "SOFTWARE IS UP TO DATE"
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: sub_status_text
                text: "NO UPDATE IS REQUIRED AT THIS TIME."
                anchors.topMargin: 100
            }

            PropertyChanges {
                target: release_notes_text
                visible: false
            }

            PropertyChanges {
                target: button1
                buttonWidth: 75
                buttonHeight: 50
                label: "OK"
                visible: true
                anchors.topMargin: 180
            }

            PropertyChanges {
                target: button2
                visible: false
            }

            PropertyChanges {
                target: columnLayout
                height: 250
            }
        },
        State {
            name: "firmware_update_failed"

            PropertyChanges {
                target: loading_icon
                visible: false
            }

            PropertyChanges {
                target: image
                source: "qrc:/img/firmware_update_error.png"
                height: sourceSize.height
                width: sourceSize.width
                visible: true
            }

            PropertyChanges {
                target: main_status_text
                text: "SOFTWARE DOWNLOAD FAILED"
                anchors.topMargin: 20
            }

            PropertyChanges {
                target: sub_status_text
                text: "Make sure your printer is connected to the internet and please try again."
                anchors.topMargin: 100
            }

            PropertyChanges {
                target: release_notes_text
                visible: false
            }

            PropertyChanges {
                target: button1
                label: "TRY AGAIN"
                buttonWidth: 175
                buttonHeight: 50
                visible: true
                anchors.topMargin: 200
            }

            PropertyChanges {
                target: button2
                label: "BACK TO MENU"
                buttonWidth: 240
                buttonHeight: 50
                visible: true
                anchors.topMargin: 265
            }

            PropertyChanges {
                target: columnLayout
                height: 290
            }
        },
        State {
            name: "updating_firmware"
            when: bot.process.type == ProcessType.FirmwareUpdate

            PropertyChanges {
                target: loading_icon
                visible: true
            }

            PropertyChanges {
                target: image
                visible: false
            }

            PropertyChanges {
                target: main_status_text
                text: {
                    switch(bot.process.stateType)
                    {
                    case ProcessStateType.TransferringFirmware:
                        "UPDATING SOFTWARE [1/3]"
                        break;
                    case ProcessStateType.VerifyingFirmware:
                        "UPDATING SOFTWARE [2/3]"
                        break;
                    case ProcessStateType.InstallingFirmware:
                        "UPDATING SOFTWARE [3/3]"
                        break;
                    default:
                        "CHECKING FOR UPDATES"
                        break;
                    }
                }
                anchors.topMargin: 0
            }

            PropertyChanges {
                target: sub_status_text
                text: {
                    switch(bot.process.stateType)
                    {
                    case ProcessStateType.TransferringFirmware:
                        "TRANSFERRING..."
                        break;
                    case ProcessStateType.VerifyingFirmware:
                        "VERIFYING FILE..."
                        break;
                    case ProcessStateType.InstallingFirmware:
                        "INSTALLING..."
                        break;
                    default:
                        "PLEASE WAIT A MOMENT"
                        break;
                    }
                }
                anchors.topMargin: 75
            }

            PropertyChanges {
                target: release_notes_text
                visible: false
            }

            PropertyChanges {
                target: button1
                visible: false
            }

            PropertyChanges {
                target: button2
                visible: false
            }

            PropertyChanges {
                target: columnLayout
                height: 150
            }
        }
    ]
}
