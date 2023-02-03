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
            mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
            settingsSwipeView.swipeToItem(SettingsPage.SystemSettingsPage)
            systemSettingsSwipeView.swipeToItem(SystemSettingsPage.FirmwareUpdatePage)
        }
    }

    property bool isUsbStorageConnected: storage.usbStorageConnected
    property bool isFirmwareFileCopying: storage.fileIsCopying

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
           bot.process.type === ProcessType.None) {
            state = "install_from_usb"
        }
    }

    property int errorCode
    property int currentState: bot.process.stateType
    onCurrentStateChanged: {
        if(bot.process.type === ProcessType.FirmwareUpdate
                && bot.process.errorCode > 0) {
            errorCode = bot.process.errorCode
            firmwareUpdateFailedPopup.open()
        }
    }
    property bool updateFirmware: false

    function getUrlForMethod() {
           return "support.makerbot.com/s/article/Method-Firmware"
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
        icon_image: LoadingIcon.Loading
        visible: true
        loading: true
    }

    Image {
        id: image
        anchors.left: parent.left
        anchors.leftMargin: 120
        anchors.verticalCenterOffset: -20
        anchors.verticalCenter: parent.verticalCenter
        visible: false
    }

    ColumnLayout {
        id: columnLayout
        x: 400
        width: 360
        height: 150
        anchors.verticalCenterOffset: 0
        anchors.verticalCenter: parent.verticalCenter
        spacing: 32

        ColumnLayout {
            spacing: 24
            width: parent.width
            height: parent.height

            TextHeadline {
                id: main_status_text
                text: qsTr("CHECKING FOR UPDATES")
                width: parent.width
                visible: true
            }

            TextSubheader {
                id: subheader_text
                font.underline: true
                visible: false

                LoggingMouseArea {
                    logText: "[" + subheader_text.text + "]"
                    id: viewReleaseNotesMouseArea
                    anchors.fill: parent
                    onClicked: {
                        firmwareUpdatePopup.open()
                        skipFirmwareUpdate = false
                        viewReleaseNotes = true
                    }
                }
            }

            TextBody {
                id: sub_status_text
                text: qsTr("PLEASE WAIT A MOMENT")
                font.weight: Font.Light
                width: parent.width
                Layout.fillWidth: true
                visible: true
            }
        }
        ColumnLayout {
            spacing: 24
            width: parent.width
            height: parent.height

            ButtonRectanglePrimary {
                id: button1
                logKey: text
                visible: false
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
            name: "updating_firmware"
            when: bot.process.type == ProcessType.FirmwareUpdate

            PropertyChanges {
                target: loading_icon
                icon_image: LoadingIcon.Loading
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
                visible: true
            }

            PropertyChanges {
                target: subheader_text
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
                font.weight: Font.Light
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
                height: 80
                anchors.verticalCenterOffset: 0
                visible: true
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

            TextHeadline {
                id: alert_text_firmware_popup
                text: ""
                color: "#ffffff"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            Item {
                id: emptyItem_firmware_popup
                width: 10
                height: 5
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                visible: true
            }

            TextBody {
                id: description_text_firmware_popup
                color: "#ffffff"
                font.weight: Font.Light
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
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
                width: sourceSize.width - 10
                height: sourceSize.height - 10
                Layout.alignment: Qt.AlignHCenter
                source: "qrc:/img/extruder_material_error.png"
            }

            TextHeadline {
                id: title
                Layout.alignment: Qt.AlignHCenter
                color: "#ffffff"
                text: qsTr("FIRMWARE UPDATE - FAILED")
            }

            TextBody {
                id: description
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                color: "#ffffff"
                text: qsTr("There was an error during this procedure. If this reoccurs, Please contact our "+
                            "support through <b>makerbot.com</b> to identify your issue.<br><br>"+
                            "CODE: %1").arg(errorCode)
            }
        }
    }
}
