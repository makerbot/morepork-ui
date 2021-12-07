import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import MachineTypeEnum 1.0

LoggingItem {
    itemName: "FirmwareUpdatePage"
    id: item1
    width: 800
    height: 440
    smooth: false
    antialiasing: false
    property alias button1: button1
    property alias button2: button2

    property bool isFwUpdProcess: bot.process.type == ProcessType.FirmwareUpdate
    onIsFwUpdProcessChanged: {
        if(isFwUpdProcess) {
            if(mainSwipeView.currentIndex != 3) {
                mainSwipeView.swipeToItem(3)
            }
            if(settingsSwipeView.currentIndex != 5) {
                settingsSwipeView.swipeToItem(5)
            }
        }
    }

    property bool isUsbStorageConnected: storage.usbStorageConnected

    onIsUsbStorageConnectedChanged: {
        if(state == "select_firmware_file" &&
           !isUsbStorageConnected &&
           bot.process.type == ProcessType.None) {
            state = "install_from_usb"
        }
    }

    property int errorCode
    property int currentState: bot.process.stateType
    onCurrentStateChanged: {
        if(bot.process.errorCode > 0) {
            errorCode = bot.process.errorCode
            state = "firmware_update_failed"
        }
    }

    Rectangle {
        color: "#000000"
        anchors.fill: parent
    }

    FirmwareFileListUsb {
        id: firmwareFileListUsb
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        visible: false
    }

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
            text: qsTr("CHECKING FOR UPDATES")
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: 0
            wrapMode: Text.WordWrap
            font.letterSpacing: 3
            color: "#cbcbcb"
            font.family: defaultFont.name
            font.weight: Font.Bold
            font.capitalization: Font.AllUppercase
            font.pixelSize: 20
            lineHeight: 1.35
            visible: true
        }

        Text {
            id: sub_status_text
            text: qsTr("PLEASE WAIT A MOMENT")
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: 70
            font.wordSpacing: 1
            font.letterSpacing: 2
            color: "#cbcbcb"
            font.family: defaultFont.name
            font.weight: Font.Light
            font.pixelSize: 18
            lineHeight: 1.35
            wrapMode: Text.WordWrap
            visible: true
        }

        Text {
            id: release_notes_text
            text: qsTr("RELEASE NOTES")
            color: "#cbcbcb"
            font.family: defaultFont.name
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
                    firmwareUpdatePopup.open()
                    skipFirmwareUpdate = false
                    viewReleaseNotes = true
                }
            }
        }

        RoundedButton {
            id: button1
            buttonWidth: 265
            buttonHeight: 50
            label: qsTr("TEXT")
            visible: false
            anchors.top: parent.top
            anchors.topMargin: 0
        }

        RoundedButton {
            id: button2
            buttonHeight: 50
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
                text: qsTr("NEW SOFTWARE AVAILABLE")
                anchors.topMargin: 30
            }

            PropertyChanges {
                target: sub_status_text
                text: qsTr("A new version of software is available. Do you want to update to the most recent version %1?").arg(bot.firmwareUpdateVersion)
                anchors.topMargin: 110
            }

            PropertyChanges {
                target: release_notes_text
                anchors.topMargin: 225
                visible: true
            }

            PropertyChanges {
                target: button1
                anchors.topMargin: 275
                buttonWidth: 265
                label: qsTr("INSTALL UPDATE")
                visible: true
                disable_button: isProcessRunning()
            }

            PropertyChanges {
                target: button2
                visible: false
            }

            PropertyChanges {
                target: columnLayout
                height: 335
            }

            PropertyChanges {
                target: firmwareFileListUsb
                visible: false
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
                text: qsTr("SOFTWARE IS UP TO DATE")
                anchors.topMargin: 35
            }

            PropertyChanges {
                target: sub_status_text
                text: qsTr("No update is required at this time.")
                anchors.topMargin: 85
            }

            PropertyChanges {
                target: release_notes_text
                visible: false
            }

            PropertyChanges {
                target: button1
                buttonWidth: 100
                label: qsTr("OK")
                visible: true
                anchors.topMargin: 160
            }

            PropertyChanges {
                target: button2
                anchors.topMargin: 230
                label: qsTr("UPDATE VIA USB STICK")
                buttonWidth: 360
                label_width: 325
                visible: true
            }

            PropertyChanges {
                target: columnLayout
                height: 250
                anchors.verticalCenterOffset: -55
            }

            PropertyChanges {
                target: firmwareFileListUsb
                visible: false
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
                text: qsTr("SOFTWARE UPDATE FAILED")
                anchors.topMargin: 20
            }

            PropertyChanges {
                target: sub_status_text
                text: qsTr("Make sure your printer is connected to the internet and please try again.")
                anchors.topMargin: 100
            }

            PropertyChanges {
                target: release_notes_text
                visible: false
            }

            PropertyChanges {
                target: button1
                label: qsTr("OK")
                buttonWidth: 175
                visible: true
                anchors.topMargin: 200
            }


            PropertyChanges {
                target: columnLayout
                height: 290
            }

            PropertyChanges {
                target: firmwareFileListUsb
                visible: false
            }
        },
        State {
            name: "updating_firmware"
            when: bot.process.type == ProcessType.FirmwareUpdate

            PropertyChanges {
                target: loading_icon
                loading: true
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
                    // Since 'transfer' step also maps to
                    // 'loading' state in print process
                    case ProcessStateType.Loading:
                    case ProcessStateType.TransferringFirmware:
                        qsTr("UPDATING SOFTWARE [1/3]")
                        break;
                    case ProcessStateType.VerifyingFirmware:
                        qsTr("UPDATING SOFTWARE [2/3]")
                        break;
                    case ProcessStateType.InstallingFirmware:
                        qsTr("UPDATING SOFTWARE [3/3]")
                        break;
                    default:
                        qsTr("CHECKING FOR UPDATES")
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
                        qsTr("TRANSFERRING... %1\%").arg(bot.process.printPercentage)
                        break;
                    case ProcessStateType.VerifyingFirmware:
                        qsTr("VERIFYING FILE... %1\%").arg(bot.process.printPercentage)
                        break;
                    case ProcessStateType.InstallingFirmware:
                        qsTr("INSTALLING... %1\%").arg(bot.process.printPercentage)
                        break;
                    default:
                        qsTr("PLEASE WAIT A MOMENT")
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

            PropertyChanges {
                target: firmwareFileListUsb
                visible: false
            }
        },
        State {
            name: "install_from_usb"
            PropertyChanges {
                target: loading_icon
                loading: false
            }

            PropertyChanges {
                target: image
                width: sourceSize.width
                height: sourceSize.height
                source: "qrc:/img/firmware_update_available.png"
                visible: true
            }

            PropertyChanges {
                target: main_status_text
                text: qsTr("DOWNLOAD TO\nUSB STICK")
                anchors.topMargin: 20
            }

            PropertyChanges {
                target: sub_status_text
                text: {
                    if (bot.machineType == MachineType.Fire) {
                        qsTr("Visit MakerBot.com/MethodFW to download the latest firmware. Drag the file onto a usb stick and insert it into the front of the printer.")

                    } else if (bot.machineType == MachineType.Lava) {
                        qsTr("Visit MakerBot.com/MethodXFW to download the latest firmware. Drag the file onto a usb stick and insert it into the front of the printer.")
                    } else if (bot.machineType == MachineType.Magma) {
                        qsTr("Visit MakerBot.com/MethodXLFW to download the latest firmware. Drag the file onto a usb stick and insert it into the front of the printer.")
                    }

                }
                anchors.topMargin: 100
            }

            PropertyChanges {
                target: release_notes_text
                visible: false
            }

            PropertyChanges {
                target: button1
                buttonWidth: 220
                label: qsTr("CHOOSE FILE")
                visible: true
                anchors.topMargin: 260
                disable_button: !storage.usbStorageConnected
            }

            PropertyChanges {
                target: button2
                visible: false
            }

            PropertyChanges {
                target: columnLayout
                height: 320
            }

            PropertyChanges {
                target: firmwareFileListUsb
                visible: false
            }
        },
        State {
            name: "select_firmware_file"
            PropertyChanges {
                target: loading_icon
                visible: false
                loading: false
            }

            PropertyChanges {
                target: image
                visible: false
            }

            PropertyChanges {
                target: columnLayout
                height: 290
                visible: false
            }

            PropertyChanges {
                target: firmwareFileListUsb
                visible: true
            }
        }
    ]
}
