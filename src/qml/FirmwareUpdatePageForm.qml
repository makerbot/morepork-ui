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
    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

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

    ColumnLayout {
        id: columnLayout
        x: 400
        y: 120
        width: 350
        height: 150
        anchors.verticalCenterOffset: -20
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: main_status_text
            text: "CHECKING FOR UPDATES"
            wrapMode: Text.WordWrap
            font.letterSpacing: 3
            color: "#cbcbcb"
            font.family: "Antennae"
            font.weight: Font.Bold
            font.capitalization: Font.AllUppercase
            font.pixelSize: 20
            Layout.fillWidth: true
            visible: true
        }

        Text {
            id: sub_status_text
            text: "PLEASE WAIT A MOMENT"
            font.wordSpacing: 1
            font.letterSpacing: 2
            color: "#cbcbcb"
            font.family: "Antennae"
            font.weight: Font.Light
            font.capitalization: Font.AllUppercase
            font.pixelSize: 18
            Layout.fillWidth: true
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
            buttonHeight: 45
            label: "TEXT"
            visible: false
        }

        RoundedButton {
            id: button2
            visible: false
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
            }

            PropertyChanges {
                target: sub_status_text
                text: "A NEW VERSION OF SOFTWARE IS AVAILABLE. DO YOU WANT TO UPDATE TO THE MOST RECENT VERSION " + bot.firmwareUpdateVersion + " ?"
            }

            PropertyChanges {
                target: release_notes_text
                visible: true
            }

            PropertyChanges {
                target: button1
                buttonWidth: 265
                buttonHeight: 45
                label: "INSTALL UPDATE"
                visible: true
                button_mouseArea.onClicked: {
                    bot.installFirmware()
                }
            }

            PropertyChanges {
                target: columnLayout
                width: 315
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
            }

            PropertyChanges {
                target: sub_status_text
                text: "NO UPDATE IS REQUIRED AT THIS TIME."
            }

            PropertyChanges {
                target: release_notes_text
                visible: false
            }

            PropertyChanges {
                target: button1
                buttonWidth: 75
                buttonHeight: 45
                label: "OK"
                visible: true
                button_mouseArea.onClicked: {
                    goBack()
                }
            }

            PropertyChanges {
                target: button2
                visible: false
            }

            PropertyChanges {
                target: columnLayout
                width: 350
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
            }

            PropertyChanges {
                target: sub_status_text
                text: "Make sure your printer is connected to the internet and please try again."
            }

            PropertyChanges {
                target: release_notes_text
                visible: false
            }

            PropertyChanges {
                target: button1
                label: "TRY AGAIN"
                buttonWidth: 175
                buttonHeight: 45
                visible: true
                button_mouseArea.onClicked: {
                    bot.firmwareUpdateCheck("False")
                }
            }

            PropertyChanges {
                target: button2
                label: "BACK TO MENU"
                buttonWidth: 240
                buttonHeight: 45
                visible: true
                button_mouseArea.onClicked: {
                    settingsSwipeView.swipeToItem(0)
                }
            }

            PropertyChanges {
                target: columnLayout
                width: 315
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
                width: 350
                height: 150
            }
        }
    ]
}
