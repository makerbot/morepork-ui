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
            buttonHeight: 40
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
            when: isfirmwareUpdateAvailable

            PropertyChanges {
                target: main_status_text
                text: "NEW FIRMWARE AVAILABLE"
            }

            PropertyChanges {
                target: sub_status_text
                text: "A NEW VERSION OF THE FIRMWARE IS AVAILABLE. DO YOU WANT TO UPDATE TO THE MOST RECENT VERSION ?"
            }

            PropertyChanges {
                target: release_notes_text
                visible: true
            }

            PropertyChanges {
                target: button1
                buttonWidth: 265
                buttonHeight: 40
                label: "INSTALL UPDATE"
                visible: true
            }

            PropertyChanges {
                target: columnLayout
                width: 315
                height: 320
            }
        },
        State {
            name: "no_firmware_update_available"
            when: !isfirmwareUpdateAvailable

            PropertyChanges {
                target: main_status_text
                text: "NO NEWER VERSION AVAILABLE"
            }

            PropertyChanges {
                target: sub_status_text
                text: "YOUR FIRMWARE IS ALREADY UP TO DATE."
            }

            PropertyChanges {
                target: release_notes_text
                visible: false
            }

            PropertyChanges {
                target: button1
                buttonWidth: 75
                buttonHeight: 40
                label: "OK"
                visible: true
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
                target: main_status_text
                text: "FIRMWARE DOWNLOAD FAILED"
            }

            PropertyChanges {
                target: sub_status_text
                text: "TRY AGAIN OR CONNECT TO MAKERBOT DESKTOP TO CHECK FOR UPDATES."
            }

            PropertyChanges {
                target: release_notes_text
                visible: false
            }

            PropertyChanges {
                target: button1
                label: "TRY AGAIN"
                buttonWidth: 175
                buttonHeight: 40
                visible: true
            }

            PropertyChanges {
                target: button2
                label: "BACK TO MENU"
                buttonWidth: 240
                buttonHeight: 40
                visible: true
            }

            PropertyChanges {
                target: columnLayout
                width: 315
                height: 290
            }
        },
        State {
            name: "updating_firmware"
            when: bot.process.stateType == ProcessType.FirmwareUpdate

            PropertyChanges {
                target: main_status_text
                text: {
                    switch(bot.process.stateType)
                    {
                    case ProcessStateType.TransferringFirmware:
                        "UPDATING FIRMWARE [1/3]"
                        break;
                    case ProcessStateType.VerifyingFirmware:
                        "UPDATING FIRMWARE [2/3]"
                        break;
                    case ProcessStateType.InstallingFirmware:
                        "UPDATING FIRMWARE [3/3]"
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
                        "TRANSFERRING FILE..."
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
