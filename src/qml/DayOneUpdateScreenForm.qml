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
    property alias dayOneUpdatePagePopup: dayOneUpdatePagePopup
    property alias firmwareUpdatePage: firmwareUpdatePage

    property bool isFirmwareUpdateProcess: bot.process.type == ProcessType.FirmwareUpdate

    onIsFirmwareUpdateProcessChanged: {
        if(isFirmwareUpdateProcess) {
            dayOneUpdatePagePopup.close()
            state = "updating_firmware"
        }
        else {
            state = "update_now"
        }
    }

    property bool isInterfaceTypeEthernet: bot.net.interface == "ethernet"

    onIsInterfaceTypeEthernetChanged: {
        if(!isInterfaceTypeEthernet) {
            if(dayOneUpdatePagePopup.opened) {
                dayOneUpdatePagePopup.close()
            }
        }
    }

    property bool isInterfaceTypeWifi: bot.net.interface == "wifi"

    onIsInterfaceTypeWifiChanged: {
        if(isInterfaceTypeWifi) {
            if(state == "connect_to_wifi") {
                dayOneUpdatePagePopup.open()
            }
        }
    }

    property bool isUsbStorageConnected: storage.usbStorageConnected

    onIsUsbStorageConnectedChanged: {
        if(state == "usb_fw_file_list" &&
           !isUsbStorageConnected &&
           bot.process.type == ProcessType.None) {
            state = "download_to_usb_stick"
        }
    }

    property bool isCancelUpdateProcess: false
    property bool isEthernetConnected: false
    property bool setDownloadFailed: false
    property bool setFirmwareFileCorrupted: false

    Timer {
        id: checkForUpdatesTimer
        interval: 3000
        onTriggered: {
            if(isfirmwareUpdateAvailable) {
                checkForUpdatesTimer.stop()
                dayOneUpdatePagePopup.close()
                bot.installFirmware()
            }
            else {
                bot.firmwareUpdateCheck(false)
                checkForUpdatesTimer.restart()
            }
        }
    }

    property bool isFirmwareDownloadFailed: bot.process.errorCode == 1054

    onIsFirmwareDownloadFailedChanged: {
        if(isFirmwareDownloadFailed) {
            setDownloadFailed = true
            if(!dayOneUpdatePagePopup.opened) {
                dayOneUpdatePagePopup.open()
            }
        }
    }

    property bool isFirmwareFileCorrupted: bot.process.errorCode == 1031

    onIsFirmwareFileCorruptedChanged: {
        if(isFirmwareFileCorrupted) {
            setFirmwareFileCorrupted = true
            if(!dayOneUpdatePagePopup.opened) {
                dayOneUpdatePagePopup.open()
            }
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
                width: 80
                height: 60
                anchors.verticalCenterOffset: 10
                anchors.horizontalCenterOffset: 30
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
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

    FirmwareFileListUsb {
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
            text: "WELCOME"
            antialiasing: false
            smooth: false
            font.letterSpacing: 3
            wrapMode: Text.WordWrap
            anchors.top: parent.top
            anchors.topMargin: 90
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
            text: "Follow these steps to set up your\n" + productName + " Performance 3D Printer."
            lineHeight: 1.2
            opacity: 1.0
        }

        RoundedButton {
            id: button1
            label_width: 325
            label: "BEGIN SETUP"
            buttonWidth: 220
            buttonHeight: 50
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: subtitle.bottom
            anchors.topMargin: 25
        }

        RoundedButton {
            id: button2
            label: "UPDATE VIA WI-FI"
            label_width: 325
            buttonWidth: 360
            buttonHeight: 50
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: button1.bottom
            anchors.topMargin: 20
            opacity: 0
        }

        RoundedButton {
            id: button3
            anchors.topMargin: 20
            buttonHeight: 50
            anchors.top: button2.bottom
            label: "UPDATE VIA USB STICK"
            buttonWidth: 360
            label_width: 325
            opacity: 0
        }
    }
    states: [
        State {
            name: "update_now"

            PropertyChanges {
                target: title
                text: "NEW FIRMWARE\nUPDATE REQUIRED"
                anchors.topMargin: 10
            }

            PropertyChanges {
                target: subtitle
                text: "A critical update is required to\nimprove machine reliability and\nprint quality. Connect via ethernet,\nWi-Fi or by installing and\nconnecting with MakerBot Print."
            }

            PropertyChanges {
                target: button1
                opacity: 1.0
                buttonWidth: 360
                label: "UPDATE VIA ETHERNET"
            }

            PropertyChanges {
                target: button2
                opacity: 1.0
                buttonWidth: 360
                label: "UPDATE VIA WI-FI"
            }

            PropertyChanges {
                target: button3
                opacity: 1.0
                buttonWidth: 360
                label: "UPDATE VIA USB STICK"
            }

            PropertyChanges {
                target: imageBackArrow
                visible: false
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
            name: "download_to_usb_stick"

            PropertyChanges {
                target: title
                text: "DOWNLOAD TO\nUSB STICK"
                anchors.topMargin: 40
            }

            PropertyChanges {
                target: subtitle
                text: "Visit MakerBot.com/"+ productName +"FW to download the latest firmware. Drag the file onto a usb stick and insert it into the front of the printer."
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
                visible: {
                    if(bot.process.type == ProcessType.FirmwareUpdate &&
                       bot.process.stateType > ProcessStateType.TransferringFirmware) {
                        false
                    }
                    else {
                        true
                    }
                }
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
                text: "Visit MakerBot.com/"+ productName +"FW to download the latest firmware. Drag the file onto a usb stick and insert it into the front of the printer."
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
                target: firmwareUpdatePage
                visible: true
            }

            PropertyChanges {
                target: header_image
                opacity: 0
                visible: true
            }
        }
    ]

    Popup {
        id: dayOneUpdatePagePopup
        width: 800
        height: 480
        modal: true
        dim: false
        focus: true
        parent: overlay
        closePolicy: Popup.CloseOnPressOutside
        background: Rectangle {
            id: popupBackgroundDim_dayOneUpdatePopup
            color: "#000000"
            rotation: rootItem.rotation == 180 ? 180 : 0
            opacity: 0.5
            anchors.fill: parent
        }
        enter: Transition {
                NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.InQuad; from: 0.0; to: 1.0 }
        }
        exit: Transition {
                NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.InQuad; from: 1.0; to: 0.0 }
        }

        onOpened: {
            if(!isEthernetConnected &&
               !isCancelUpdateProcess &&
               !setDownloadFailed &&
               !setFirmwareFileCorrupted) {
                checkForUpdatesTimer.start()
            }
        }

        onClosed: {
            isEthernetConnected = false
            isCancelUpdateProcess = false
            setDownloadFailed = false
            setFirmwareFileCorrupted = false
        }

        Rectangle {
            id: basePopupItem_dayOneUpdatePopup
            color: "#000000"
            rotation: rootItem.rotation == 180 ? 180 : 0
            width: 720
            height: {
                if(isEthernetConnected) {
                    300
                }
                else if(isCancelUpdateProcess) {
                    320
                }
                else if(setDownloadFailed) {
                    250
                }
                else if(setFirmwareFileCorrupted) {
                    250
                }
                else {
                    320
                }
            }
            radius: 10
            border.width: 2
            border.color: "#ffffff"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                id: horizontal_divider_dayOneUpdatePopup
                width: 720
                height: 2
                color: "#ffffff"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 72
            }

            Rectangle {
                id: vertical_divider_dayOneUpdatePopup
                x: 359
                y: 328
                width: 2
                height: 72
                color: "#ffffff"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.horizontalCenter: parent.horizontalCenter
                visible: {
                    if(isCancelUpdateProcess) {
                        true
                    }
                    else {
                        false
                    }
                }
            }

            Item {
                id: buttonBar_dayOneUpdatePopup
                width: 720
                height: 72
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                Rectangle {
                    id: left_rectangle_dayOneUpdatePopup
                    x: 0
                    y: 0
                    width: 360
                    height: 72
                    color: "#00000000"
                    radius: 10
                    visible: vertical_divider_dayOneUpdatePopup.visible

                    Text {
                        id: left_text_dayOneUpdatePopup
                        color: "#ffffff"
                        text: "CANCEL UPDATE"
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: false
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: "Antennae"
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MouseArea {
                        id: left_mouseArea_dayOneUpdatePopup
                        anchors.fill: parent
                        onPressed: {
                            left_rectangle_dayOneUpdatePopup.color = "#ffffff"
                            left_text_dayOneUpdatePopup.color = "#000000"
                        }
                        onReleased: {
                            left_rectangle_dayOneUpdatePopup.color = "#00000000"
                            left_text_dayOneUpdatePopup.color = "#ffffff"
                        }
                        onClicked: {
                            bot.cancel()
                            dayOneUpdatePagePopup.close()
                        }
                    }
                }

                Rectangle {
                    id: right_rectangle_dayOneUpdatePopup
                    x: 360
                    y: 0
                    width: 360
                    height: 72
                    color: "#00000000"
                    radius: 10
                    visible: vertical_divider_dayOneUpdatePopup.visible

                    Text {
                        id: right_text_dayOneUpdatePopup
                        color: "#ffffff"
                        text: "CONTINUE"
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: "Antennae"
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MouseArea {
                        id: right_mouseArea_dayOneUpdatePopup
                        anchors.fill: parent
                        onPressed: {
                            right_rectangle_dayOneUpdatePopup.color = "#ffffff"
                            right_text_dayOneUpdatePopup.color = "#000000"
                        }
                        onReleased: {
                            right_rectangle_dayOneUpdatePopup.color = "#00000000"
                            right_text_dayOneUpdatePopup.color = "#ffffff"
                        }
                        onClicked: {
                            dayOneUpdatePagePopup.close()
                        }
                    }
                }

                Rectangle {
                    id: full_button_rectangle_dayOneUpdatePopup
                    x: 0
                    y: 0
                    width: 720
                    height: 72
                    color: "#00000000"
                    radius: 10
                    visible: {
                        if(isCancelUpdateProcess) {
                            false
                        }
                        else {
                            true
                        }
                    }

                    Text {
                        id: full_button_text_dayOneUpdatePopup
                        color: "#ffffff"
                        text: {
                            if(setDownloadFailed) {
                                "OK"
                            }
                            else if(setFirmwareFileCorrupted) {
                                "OK"
                            }
                            else {
                                "CANCEL"
                            }
                        }
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: false
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: "Antennae"
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MouseArea {
                        id: full_button_mouseArea_dayOneUpdatePopup
                        anchors.fill: parent
                        onPressed: {
                            full_button_rectangle_dayOneUpdatePopup.color = "#ffffff"
                            full_button_text_dayOneUpdatePopup.color = "#000000"
                        }
                        onReleased: {
                            full_button_rectangle_dayOneUpdatePopup.color = "#00000000"
                            full_button_text_dayOneUpdatePopup.color = "#ffffff"
                        }
                        onClicked: {
                            if(isEthernetConnected) {
                                dayOneUpdatePagePopup.close()
                            }
                            else {
                                if(checkForUpdatesTimer.running) {
                                    checkForUpdatesTimer.stop()
                                }
                                dayOneUpdatePagePopup.close()
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                id: columnLayout_dayOneUpdatePopup
                width: 590
                height: 175
                anchors.top: parent.top
                anchors.topMargin: isEthernetConnected ? 20 : 45
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: header_text_dayOneUpdatePopup
                    color: "#cbcbcb"
                    text: {
                        if(isEthernetConnected) {
                            "DISCONNECT THE ETHERNET CABLE TO\nSET UP WI-FI"
                        }
                        else if(isCancelUpdateProcess) {
                            "CANCEL UPDATE PROCESS?"
                        }
                        else if(setDownloadFailed) {
                            "FIRMWARE DOWNLOAD ERROR"
                        }
                        else if(setFirmwareFileCorrupted) {
                            "FIRMWARE FILE CORRUPTED"
                        }
                        else {
                            "CHECKING CONNECTION"
                        }
                    }
                    horizontalAlignment: isEthernetConnected ?
                                             Text.AlignHCenter : Text.AlignLeft
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 3
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: "Antennae"
                    font.weight: Font.Bold
                    font.pixelSize: 20
                    lineHeight: isEthernetConnected ?
                                    1.3 : 1.0
                }

                Text {
                    id: sub_text
                    color: "#cbcbcb"
                    text: {
                        if(isEthernetConnected) {
                            ""
                        }
                        else if(setDownloadFailed) {
                            "Could not download firmware. Please try again. If the problem continues, contact support."
                        }
                        else if(setFirmwareFileCorrupted) {
                            "Please try downloading it again."
                        }
                        else if(isCancelUpdateProcess) {
                            "This will cancel the current update process. An update is still required. You can choose a different method for updating firmware."
                        }
                        else {
                            if(isInterfaceTypeWifi) {
                                "Looking for latest firmware."
                            }
                            else {
                                "Be sure the ethernet cable is attached and connected to an\nonline router."
                            }
                        }
                    }
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.weight: Font.Light
                    wrapMode: Text.WordWrap
                    font.family: "Antennae"
                    font.pixelSize: 18
                    lineHeight: 1.3
                    visible: !isEthernetConnected
                }

                BusySpinner {
                    id: busyIndicator_dayOneUpdatePopup
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    spinnerActive: {
                        if(isEthernetConnected) {
                            true
                        }
                        else if(setDownloadFailed) {
                            false
                        }
                        else if(setFirmwareFileCorrupted) {
                            false
                        }
                        else if(isCancelUpdateProcess) {
                            false
                        }
                        else {
                            true
                        }
                    }
                    spinnerSize: 48
                }
            }
        }
    }
}
