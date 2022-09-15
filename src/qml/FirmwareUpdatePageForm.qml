import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import MachineTypeEnum 1.0

LoggingItem {
    itemName: "FirmwareUpdatePage"
    id: firmwareUpdatePage
    width: 800
    height: 440
    smooth: false
    antialiasing: false
    property alias button1: button1
    property alias button2: button2

    property bool isFwUpdProcess: bot.process.type == ProcessType.FirmwareUpdate
    onIsFwUpdProcessChanged: {
        if(isFwUpdProcess) {
            if(mainSwipeView.currentIndex != MoreporkUI.SettingsPage) {
                mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
            }
            if(settingsSwipeView.currentIndex != SettingsPage.FirmwareUpdatePage) {
                settingsSwipeView.swipeToItem(SettingsPage.FirmwareUpdatePage)
            }
        }
    }

    property bool isUsbStorageConnected: storage.usbStorageConnected
    property bool isFirmwareFileCopying: storage.fileIsCopying
    property string firmwareVersion: bot.version

    onIsFirmwareFileCopyingChanged: {
        if(isFirmwareFileCopying &&
           firmwareUpdatePage.state == "select_firmware_file") {
            retrievingFirmwarePopup.open()
        }
        else {
            retrievingFirmwarePopup.close()
        }
    }
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
            firmwareUpdateFailedPopup.open()
        }
    }
    property bool updateFirmware: false

    function getUrlByMachineType(type) {
        switch(type) {
        case MachineType.Fire:
            return "methodFW"
        case MachineType.Lava:
            return "methodXFW"
        case MachineType.Magma:
            return "methodXLFW"
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
        icon_image: "loading"
        visible: true
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
            anchors.topMargin: 60
            wrapMode: Text.WordWrap
            font.letterSpacing: 3
            color: "#cbcbcb"
            font.family: defaultFont.name
            font.weight: Font.Bold
            font.capitalization: Font.AllUppercase
            font.pixelSize: 18
            lineHeight: 1.35
            visible: true
        }

        Text {
            id: ver_status_text
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: 70
            font.wordSpacing: 1
            font.letterSpacing: 2
            color: "#cbcbcb"
            font.family: defaultFont.name
            font.weight: Font.Light
            font.pixelSize: 14
            lineHeight: 1.35
            wrapMode: Text.WordWrap
            visible: false
        }

        Text {
            id: release_notes_text
            text: qsTr("%1 RELEASE NOTES").arg(bot.firmwareUpdateVersion)
            color: "#cbcbcb"
            font.family: defaultFont.name
            font.weight: Font.Light
            font.underline: true
            font.capitalization: Font.AllUppercase
            font.pixelSize: 14
            visible: false
            anchors.top: parent.top
            anchors.topMargin: 70
            font.wordSpacing: 1
            font.letterSpacing: 2

            LoggingMouseArea {
                logText: "[" + release_notes_text.text + "]"
                id: viewReleaseNotesMouseArea
                anchors.fill: parent
                onClicked: {
                    firmwareUpdatePopup.open()
                    skipFirmwareUpdate = false
                    viewReleaseNotes = true
                }
            }
        }

        Text {
            id: sub_status_text
            text: qsTr("PLEASE WAIT A MOMENT")
            width: parent.width
            anchors.top: parent.top
            anchors.topMargin: 100
            font.wordSpacing: 1
            font.letterSpacing: 2
            color: "#cbcbcb"
            font.family: defaultFont.name
            font.weight: Font.Light
            font.pixelSize: 14
            lineHeight: 1.35
            wrapMode: Text.WordWrap
            visible: true
        }

        ButtonRectanglePrimary {
            id: button1
            text: qsTr("TEXT")
            logKey: text
            visible: false
            anchors.top: parent.top
            anchors.topMargin: 0
        }

        ButtonRectangleSecondary {
            id: button2
            logKey: text
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
                icon_image: "failure"
                visible: true
            }

            PropertyChanges {
                target: image
                visible: false
            }

            PropertyChanges {
                target: main_status_text
                text: qsTr("NEW FIRMWARE AVAILABLE")
                anchors.topMargin: 30
                visible: true
            }

            PropertyChanges {
                target: ver_status_text
                visible: false
            }

            PropertyChanges {
                target: release_notes_text
                visible: true
            }

            PropertyChanges {
                target: sub_status_text
                text: qsTr("Recommended to improve machine reliability and print quality.")
                anchors.topMargin: 110
                visible: true
            }

            PropertyChanges {
                target: button1
                anchors.topMargin: 180
                text: qsTr("INSTALL VIA NETWORK")
                visible: true
                enabled: !isProcessRunning()
            }

            PropertyChanges {
                target: button2
                anchors.topMargin: 260
                text: qsTr("INSTALL VIA USB")
                visible: true
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
                icon_image: "success"
                visible: true
            }

            PropertyChanges {
                target: image
                visible: false
            }

            PropertyChanges {
                target: main_status_text
                text: qsTr("FIRMWARE IS UP TO DATE")
                anchors.topMargin: 30
                visible: true
            }

            PropertyChanges {
                target: ver_status_text
                text: qsTr("VERSION %1").arg(firmwareVersion)
                visible: true
            }

            PropertyChanges {
                target: release_notes_text
                visible: false
            }

            PropertyChanges {
                target: sub_status_text
                text: qsTr("No update is required at this time.")
                anchors.topMargin: 110
                visible: true
            }

            PropertyChanges {
                target: button1
                text: qsTr("CONFIRM")
                visible: true
                anchors.topMargin: 155
            }

            PropertyChanges {
                target: button2
                anchors.topMargin: 230
                text: qsTr("INSTALL VIA USB")
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
            name: "updating_firmware"
            when: bot.process.type == ProcessType.FirmwareUpdate

            PropertyChanges {
                target: loading_icon
                icon_image: "loading"
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
                        qsTr("UPDATING FIRMWARE [1/3]")
                        break;
                    case ProcessStateType.VerifyingFirmware:
                        qsTr("UPDATING FIRMWARE [2/3]")
                        break;
                    case ProcessStateType.InstallingFirmware:
                        qsTr("UPDATING FIRMWARE [3/3]")
                        break;
                    default:
                        qsTr("CHECKING FOR UPDATES")
                        break;
                    }
                }
                anchors.topMargin: 60
                visible: true
            }

            PropertyChanges {
                target: ver_status_text
                visible: false
            }

            PropertyChanges {
                target: release_notes_text
                visible: false
            }

            PropertyChanges {
                target: sub_status_text
                text: {
                    switch(bot.process.stateType)
                    {
                    case ProcessStateType.TransferringFirmware:
                        qsTr("TRANSFERRING FILE... (%1\%)").arg(bot.process.printPercentage)
                        break;
                    case ProcessStateType.VerifyingFirmware:
                        qsTr("VERIFYING FILE... (%1\%)").arg(bot.process.printPercentage)
                        break;
                    case ProcessStateType.InstallingFirmware:
                        qsTr("INSTALLING FILE... (%1\%)").arg(bot.process.printPercentage)
                        break;
                    default:
                        qsTr("PLEASE WAIT A MOMENT")
                        break;
                    }
                }
                anchors.topMargin: 100
                visible: true
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
                visible: false
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
                visible: false
            }

            PropertyChanges {
                target: ver_status_text
                text: qsTr("CURRENT FIRMWARE: %1").arg(firmwareVersion)
                anchors.topMargin: 70
                visible: true
            }

            PropertyChanges {
                target: release_notes_text
                visible: false
            }

            PropertyChanges {
                target: sub_status_text
                text: {
                    qsTr("Visit <font color=\"#E85A4F\"><b>makerbot.com/%1</b></font> to download "
                         + "the latest firmware. Drag the file onto a usb stick and insert it into "
                         + "the front of the printer.").arg(getUrlByMachineType(bot.machineType))
                }
                anchors.topMargin: 110
                visible: true
            }

            PropertyChanges {
                target: button1
                text: qsTr("CHOOSE FILE")
                visible: true
                anchors.topMargin: 220
                enabled: storage.usbStorageConnected
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


    CustomPopup {
        popupName: "RetrievingFirmware"
        id: retrievingFirmwarePopup
        popupWidth: 720
        popupHeight: 280
        showOneButton: true

        visible: bot.process.type === ProcessType.FirmwareUpdate
                 && bot.process.stateType === ProcessStateType.DownloadingFirmware

        full_button_text: qsTr("CANCEL")
        full_button.onClicked: {
            if(columnLayout_firmware_popup.state == "copying") {
                updateFirmware = false
                storage.cancelCopy()
            }
            else {
                bot.cancel()
            }
        }

        onClosed: {

        }

        ColumnLayout {
            id: columnLayout_firmware_popup
            width: 590
            height: 180
            anchors.top: parent.top
            anchors.topMargin: 110
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            BusySpinner {
                id: busyIndicator_firmware_popup
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                spinnerActive: true
                spinnerSize: 48
            }

            Text {
                id: alert_text_firmware_popup
                color: "#cbcbcb"
                font.letterSpacing: 3
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 20
            }

            Item {
                id: emptyItem_firmware_popup
                width: 10
                height: 5
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                visible: true
            }

            Text {
                id: description_text_firmware_popup
                color: "#cbcbcb"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                font.family: defaultFont.name
                font.pixelSize: 16
                lineHeight: 1.3
                visible: true
            }
            states: [
                State {
                    name: "downloading"
                    when: bot.process.type === ProcessType.FirmwareUpdate
                          && bot.process.stateType === ProcessStateType.DownloadingFirmware

                    PropertyChanges {
                        target: alert_text_firmware_popup
                        text: qsTr("DOWNLOADING FIRMWARE")
                    }
                    PropertyChanges {
                        target: description_text_firmware_popup
                        text: qsTr("%1").arg(bot.process.printPercentage) + "%"
                    }
                },
                State {
                    name: "copying"
                    when: isFirmwareFileCopying

                    PropertyChanges {
                        target: alert_text_firmware_popup
                        text: qsTr("COPYING FIRMWARE")
                    }

                    PropertyChanges {
                        target: description_text_firmware_popup
                        text: (storage.fileCopyProgress * 100.0).toFixed(1) + "%"
                    }
                }
            ]
        }
    }

    CustomPopup {
        popupName: "FirmwareUpdateFailure"
        id: firmwareUpdateFailedPopup
        visible: false
        popupWidth: 750
        popupHeight: 350

        showOneButton: true
        full_button_text: qsTr("CLOSE")
        full_button.onClicked: {
            if(isfirmwareUpdateAvailable) {
                firmwareUpdatePage.state = "firmware_update_available"
            }
            else {
                firmwareUpdatePage.state = "no_firmware_update_available"
            }
           firmwareUpdateFailedPopup.close()
        }

        onClosed: {

        }
        ColumnLayout {
            id: columnLayout_firmware_failure
            width: 650
            height: 200
            anchors.top: parent.top
            anchors.topMargin: 80
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Image {
                id: error_image
                width: sourceSize.width - 20
                height: sourceSize.height - 20
                Layout.alignment: Qt.AlignHCenter
                source: "qrc:/img/extruder_material_error.png"
            }

            TextHeadline {
                id: title
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("FIRMWARE UPDATE - FAILED")
            }

            TextBody {
                id: description
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("There was an error during this procedure. If this reoccurs, Please contact our "+
                            "support through <b>makerbot.com</b> to identify your issue.<br><br>"+
                            "CODE: %1").arg(bot.process.errorCode)
            }
        }
    }
}
