import QtQuick 2.4
import QtQuick.Controls 2.3
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

    LoadingIcon {
        id: loading_icon
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.verticalCenterOffset: -20
        anchors.verticalCenter: parent.verticalCenter
        loading: true
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
                loading: false
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
                text: "A new version of software is available. Do you want to update to the most recent version " + bot.firmwareUpdateVersion + " ?"
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
                loading: false
            }

            PropertyChanges {
                target: image
                source: "qrc:/img/process_successful.png"
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
                text: "No update is required at this time."
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
                loading: false
            }

            PropertyChanges {
                target: image
                source: "qrc:/img/error.png"
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
                loading: true
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
                    // Since 'transfer' step also maps to
                    // 'loading' state in print process
                    case ProcessStateType.Loading:
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
                    // Since 'transfer' step also maps to
                    // 'loading' state in print process
                    case ProcessStateType.Loading:
                    case ProcessStateType.TransferringFirmware:
                        "TRANSFERRING... " + bot.process.printPercentage + "%"
                        break;
                    case ProcessStateType.VerifyingFirmware:
                        "VERIFYING FILE... " + bot.process.printPercentage + "%"
                        break;
                    case ProcessStateType.InstallingFirmware:
                        "INSTALLING... " + bot.process.printPercentage + "%"
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
