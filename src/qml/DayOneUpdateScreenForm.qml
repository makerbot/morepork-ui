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
    property alias mouseArea_backArrow: mouseArea_backArrow
    property alias wifiPageDayOneUpdate: wifiPageDayOneUpdate
    property alias dayOneUpdatePagePopup: dayOneUpdatePagePopup
    property alias firmwareUpdatePage: firmwareUpdatePage
    property alias checkForUpdatesTimer: checkForUpdatesTimer
    property alias popupState: popupLayout.state

    property bool checkingServer: false

    function checkServer() {
        checkingServer = true
        bot.firmwareUpdateCheck(false)
        checkForUpdatesTimer.start()
        popupState = "update_check"
        dayOneUpdatePagePopup.open()
        wifiPageDayOneUpdate.wifiPopup.close()
    }

    property bool isFirmwareUpdateProcess: bot.process.type == ProcessType.FirmwareUpdate

    onIsFirmwareUpdateProcessChanged: {
        if (isFirmwareUpdateProcess) {
            dayOneUpdatePagePopup.close()
            state = "updating_firmware"
        } else {
            state = "update_now"
        }
    }

    property bool isInterfaceTypeEthernet: bot.net.interface == "ethernet"

    onIsInterfaceTypeEthernetChanged: {
        if (isInterfaceTypeEthernet && state == "connect_to_wifi") {
            checkServer()
            state = "update_now"
        }
    }

    property bool isInterfaceTypeWifi: bot.net.interface == "wifi"

    onIsInterfaceTypeWifiChanged: {
        if (isInterfaceTypeWifi && state == "connect_to_wifi") {
            checkServer()
        }
    }

    property bool isUsbStorageConnected: storage.usbStorageConnected

    onIsUsbStorageConnectedChanged: {
        if (state == "usb_fw_file_list" &&
                !isUsbStorageConnected &&
                bot.process.type == ProcessType.None) {
            state = "download_to_usb_stick"
        }
    }

    property bool isFirmwareUpdateAvailable: bot.firmwareUpdateAvailable

    onIsFirmwareUpdateAvailableChanged: {
        if (isFirmwareUpdateAvailable && checkingServer) {
            checkingServer = false
            bot.installFirmware()
            dayOneUpdatePagePopup.close()
            state = "updating_firmware"
        }
    }

    property bool doWifiFlow: !isFirmwareUpdateAvailable && bot.net.interface == "offline"

    Timer {
        id: checkForUpdatesTimer
        interval: 10000
        onTriggered: {
            if (isFirmwareUpdateAvailable) {
                dayOneUpdatePagePopup.close()
                bot.installFirmware()
            } else {
                if (bot.net.interface == "wifi") {
                    // If we are already connected to wifi but can't find
                    // firmware, we might need to change the wifi network
                    state = "connect_to_wifi"
                }
                popupState = "update_check_failed"
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
        source: "qrc:/img/fake_fre.png"
        opacity: 1.0
    }

    LoadingIcon {
        id: loading_icon
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.verticalCenterOffset: -20
        anchors.verticalCenter: parent.verticalCenter
        icon_image: LoadingIcon.Failure
        visible: false
        loading: false
    }

    ColumnLayout {
        id: mainItem
        x: 400
        width: 360
        anchors.verticalCenter: parent.verticalCenter
        spacing: 32

        ColumnLayout {
            spacing: 24
            
            TextHeadline {
                id: title
                width: parent.width
                text: "WELCOME"
                visible: true
            }

            TextBody {
                id: body
                width: parent.width
                text: "The following procedure will help you set up your METHOD XL."
                Layout.fillWidth: true
                visible: true
            }

            TextSubheader {
                id: subheader
                width: parent.width
                style: TextSubheader.Bold
                visible: false
            }
        }

        ColumnLayout {
            spacing: 24
            
            ButtonRectanglePrimary {
                id: button1
                text: "BEGIN SETUP"
                logKey: text
            }

            ButtonRectangleSecondary {
                id: button2
                logKey: text
                visible: false
            }
        }
    }
    states: [
        State {
            name: "update_now"

            PropertyChanges {
                target: header_image
                opacity: 0
            }

            PropertyChanges {
                target: title
                text: "REQUIRED UPDATE"
                anchors.topMargin: 10
            }

            PropertyChanges {
                target: body
                text: "A critical firmware update is required to improve machine reliability and print quality. It is recommended to connect to a wi-fi network or plug in an ethernet cable.\n\nFor an offline set-up, you can install via USB."
            }

            PropertyChanges {
                target: subheader
                visible: false
            }

            PropertyChanges {
                target: button1
                text: doWifiFlow? "CONNECT TO WIFI" : "DOWNLOAD UPDATE"
            }

            PropertyChanges {
                target: button2
                text: "UPDATE VIA USB DRIVE"
                visible: true
            }

            PropertyChanges {
                target: loading_icon
                visible: true
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
                target: header_image
                source: "qrc:/img/icon_usb.png"
                anchors.leftMargin: 112
                opacity: 1.0
            }

            PropertyChanges {
                target: title
                text: "FIRMWARE UPDATE - USB"
                anchors.topMargin: 40
            }

            PropertyChanges {
                target: body
                text: "Visit the site below to download latest firmware. Drag file onto USB stick and insert into front of printer."
            }

            PropertyChanges {
                target: subheader
                text: "makerbot.com/firmware-methodXL"
                visible: true
            }

            PropertyChanges {
                target: button1
                text: "CHOOSE FILE"
            }

            PropertyChanges {
                target: button2
                visible: true
                text: "BACK"
            }

            PropertyChanges {
                target: loading_icon
                visible: false
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
            name: "connect_to_wifi"

            PropertyChanges {
                target: header_image
                opacity: 0
            }

            PropertyChanges {
                target: loading_icon
                visible: false
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
                target: loading_icon
                visible: false
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
                    if (bot.process.type == ProcessType.FirmwareUpdate &&
                       bot.process.stateType > ProcessStateType.TransferringFirmware) {
                        false
                    } else {
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
                target: imageBackArrow
                visible: {
                    storage.fileIsCopying ? false : true
                }
            }

            PropertyChanges {
                target: loading_icon
                visible: false
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

    CustomPopup {
        popupName: "DayOnePopup"
        id: dayOneUpdatePagePopup
        popupWidth: 715
        full_button_text: qsTr("BACK")
        full_button.onClicked: {
            checkingServer = false
            dayOneUpdatePagePopup.close()
        }
        ColumnLayout {
            id: popupLayout
            width: 650
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Image {
                id: popupIcon
                source: "qrc:/img/process_error_small.png"
                Layout.alignment: Qt.AlignHCenter
            }

            TextHeadline {
                id: popupTitle
                Layout.alignment: Qt.AlignHCenter
            }

            BusySpinner {
                id: waitingSpinner
                spinnerActive: false
                spinnerSize: 64
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            TextBody {
                id: popupBody
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
            }

            states: [
                State {
                    name: "no_usb"

                    PropertyChanges {
                        target: dayOneUpdatePagePopup
                        popupHeight: 300
                        showOneButton: true
                    }

                    PropertyChanges {
                        target: popupLayout
                        anchors.topMargin: 110
                    }

                    PropertyChanges {
                        target: popupIcon
                        visible: true
                    }

                    PropertyChanges {
                        target: popupTitle
                        text: qsTr("NO USB DETECTED")
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        spinnerActive: false
                    }

                    PropertyChanges {
                        target: popupBody
                        text: qsTr("Please insert USB stick with latest firmware to continue.")
                        visible: true
                    }
                },
                State {
                    name: "update_check"

                    PropertyChanges {
                        target: dayOneUpdatePagePopup
                        popupHeight: 240
                        showOneButton: false
                    }

                    PropertyChanges {
                        target: popupLayout
                        anchors.topMargin: 170
                    }

                    PropertyChanges {
                        target: popupIcon
                        visible: false
                    }

                    PropertyChanges {
                        target: popupTitle
                        text: qsTr("CHECKING FOR UPDATE")
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        spinnerActive: true
                    }

                    PropertyChanges {
                        target: popupBody
                        visible: false
                    }
                },
                State {
                    name: "update_check_failed"

                    PropertyChanges {
                        target: dayOneUpdatePagePopup
                        popupHeight: 300
                        showOneButton: true
                    }

                    PropertyChanges {
                        target: popupLayout
                        anchors.topMargin: 110
                    }

                    PropertyChanges {
                        target: popupIcon
                        visible: true
                    }

                    PropertyChanges {
                        target: popupTitle
                        text: qsTr("UPDATE CHECK FAILED")
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        spinnerActive: false
                    }

                    PropertyChanges {
                        target: popupBody
                        text: qsTr("Could not reach update server - please check your network connection.")
                        visible: true
                    }
                }
            ]
        }
    }
}
