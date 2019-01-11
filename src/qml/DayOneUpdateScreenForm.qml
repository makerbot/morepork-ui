import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    id: dayOneUpdateScreen
    width: 800
    height: 480
    smooth: false
    antialiasing: false
    property alias button1: button1
    property alias button2: button2
    property alias button3: button3
    property alias mouseArea_backArrow: mouseArea_backArrow
    property alias wifiPageDayOneUpdate: wifiPageDayOneUpdate

    property bool isFirmwareUpdateProcess: bot.process.type == ProcessType.FirmwareUpdate

    onIsFirmwareUpdateProcessChanged: {
        if(isFirmwareUpdateProcess) {
            state = "updating_firmware"
        }
        else {
            state = "base state"
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Item {
        id: dayOneUpdateTopbar
        width: 800
        height: 40
        smooth: false
        anchors.top: parent.top
        anchors.topMargin: 0

        Image {
            id: imageBackArrow
            height: sourceSize.height
            width: sourceSize.width
            smooth: false
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            fillMode: Image.PreserveAspectFit
            source: "qrc:/img/back_button.png"
            visible: false

            MouseArea {
                id: mouseArea_backArrow
                anchors.rightMargin: 10
                anchors.leftMargin: 10
                anchors.bottomMargin: 10
                anchors.topMargin: 10
                anchors.fill: parent
            }
        }

        Image {
            id: connectionTypeImage
            width: 26
            height: 26
            anchors.right: parent.right
            anchors.rightMargin: 10
            smooth: false
            anchors.verticalCenter: parent.verticalCenter
            visible: true
            source: {
                switch(bot.net.interface) {
                case "wifi":
                    "qrc:/img/wifi_connected.png"
                    break;
                case "ethernet":
                    "qrc:/img/ethernet_connected.png"
                    break;
                default:
                    "qrc:/img/no_ethernet.png"
                    break;
                }
            }
        }
    }

    FirmwareUpdatePage {
        id: firmwareUpdatePage
        anchors.verticalCenterOffset: 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        visible: false
    }

    WiFiPageForm {
        id: wifiPageDayOneUpdate
        anchors.verticalCenterOffset: 30
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        visible: false
    }

    UsbFirmwarePage {
        id: usbFirmwareList
        anchors.verticalCenterOffset: 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        visible: false
    }

    Image {
        id: header_image
        width: sourceSize.width
        height: sourceSize.height
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/sombrero_welcome.png"
        opacity: 1.0
    }

    Item {
        id: mainItem
        width: 400
        height: 450
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: header_image.width
        visible: true

        Text {
            id: title
            width: 350
            text: "NEW FIRMWARE\nUPDATE REQUIRED"
            antialiasing: false
            smooth: false
            font.letterSpacing: 3
            wrapMode: Text.WordWrap
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 0
            color: "#e6e6e6"
            font.family: "Antennae"
            font.pixelSize: 24
            font.weight: Font.Bold
            lineHeight: 1.2
            opacity: 1.0
        }

        Text {
            id: subtitle
            width: 350
            wrapMode: Text.WordWrap
            anchors.top: title.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: 0
            color: "#e6e6e6"
            font.family: "Antennae"
            font.pixelSize: 18
            font.weight: Font.Light
            text: "A critical update is required to\nimprove machine reliability and\nprint quality. Connect via ethernet,\nWi-Fi or by installing and\nconnecting with MakerBot Print."
            lineHeight: 1.2
            opacity: 1.0
        }

        RoundedButton {
            id: button1
            label_width: 325
            label: {
                if(isFirmwareUpdateProcess) {
                    "INSTALLING..."
                }
                else if(isfirmwareUpdateAvailable &&
                        (bot.net.interface == "ethernet" || bot.net.interface == "wifi")) {
                    "UPDATE VIA NETWORK"
                }
                else if(!isfirmwareUpdateAvailable &&
                        (bot.net.interface == "ethernet" || bot.net.interface == "wifi")) {
                    "CONNECTING..."
                }
                else {
                    "UPDATE VIA NETWORK"
                }
            }
            buttonWidth: 360
            buttonHeight: 50
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: subtitle.bottom
            anchors.topMargin: 25
//            opacity: disable_button ? 0.3 : 1.0
        }

        RoundedButton {
            id: button2
            label: "UPDATE VIA USB STICK"
            label_width: 325
            buttonWidth: 360
            buttonHeight: 50
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: button1.bottom
            anchors.topMargin: 20
            opacity: disable_button ? 0.3 : 1.0
            disable_button: {
                if(isFirmwareUpdateProcess &&
                    bot.process.stateType > ProcessStateType.TransferringFirmware) {
                    true
                }
                else {
                    false
                }
            }
        }

        RoundedButton {
            id: button3
            anchors.topMargin: 20
            buttonHeight: 50
            anchors.top: button2.bottom
            opacity: disable_button ? 0.3 : 1.0
            label: "WI-FI SETUP"
            buttonWidth: 360
            label_width: 325
            disable_button: {
                if(isFirmwareUpdateProcess &&
                    bot.process.stateType > ProcessStateType.TransferringFirmware) {
                    true
                }
                else {
                    false
                }
            }
        }
    }
    states: [
        State {
            name: "download_to_usb_stick"

            PropertyChanges {
                target: title
                text: "DOWNLOAD TO\nUSB STICK"
                anchors.topMargin: 40
            }

            PropertyChanges {
                target: subtitle
                text: "Visit MakerBot.com/MethodFW to download the latest firmware. Drag the file onto a usb stick and insert it into the front of the printer."
            }

            PropertyChanges {
                target: button1
                buttonWidth: 220
                label: "CHOOSE FILE"
                opacity: !storage.usbStorageConnected ? 0.3 : 1.0
            }

            PropertyChanges {
                target: button2
                opacity: 0
            }

            PropertyChanges {
                target: button3
                opacity: 0
            }

            PropertyChanges {
                target: imageBackArrow
                visible: true
            }

            PropertyChanges {
                target: mainItem
                visible: true
            }

            PropertyChanges {
                target: usbFirmwareList
                visible: false
            }
        },
        State {
            name: "connect_to_wifi"

            PropertyChanges {
                target: header_image
                opacity: 0
            }

            PropertyChanges {
                target: mainItem
                visible: false
            }

            PropertyChanges {
                target: wifiPageDayOneUpdate
                visible: true
            }

            PropertyChanges {
                target: imageBackArrow
                visible: true
            }

            PropertyChanges {
                target: usbFirmwareList
                visible: false
            }
        },
        State {
            name: "updating_firmware"

            PropertyChanges {
                target: header_image
                opacity: 0
            }

            PropertyChanges {
                target: mainItem
                visible: false
            }

            PropertyChanges {
                target: firmwareUpdatePage
                visible: true
            }

            PropertyChanges {
                target: imageBackArrow
                visible: true
            }

            PropertyChanges {
                target: usbFirmwareList
                visible: false
            }
        },
        State {
            name: "usb_fw_file_list"
            PropertyChanges {
                target: title
                text: "DOWNLOAD TO\nUSB STICK"
                anchors.topMargin: 40
                visible: false
            }

            PropertyChanges {
                target: subtitle
                text: "Visit MakerBot.com/MethodFW to download the latest firmware. Drag the file onto a usb stick and insert it into the front of the printer."
                visible: false
            }

            PropertyChanges {
                target: button2
                opacity: 0
            }

            PropertyChanges {
                target: button1
                opacity: 0.0
                buttonWidth: 220
                label: "CHOOSE FILE"
            }

            PropertyChanges {
                target: imageBackArrow
                visible: {
                    storage.fileIsCopying ? false : true
                }
            }

            PropertyChanges {
                target: mainItem
                visible: false
            }

            PropertyChanges {
                target: usbFirmwareList
                visible: true
            }

            PropertyChanges {
                target: header_image
                opacity: 0
                visible: true
            }
        }
    ]
}
