import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    id: element
    smooth: false
    property string fileName: "unknown.zip"
    property string fileBaseName

    width: 800
    height: 440

    function getFwFileDetails(file) {
        fileName = file.filePath + "/" + file.fileName
        fileBaseName = file.fileBaseName
    }

    function resetFwFileDetails() {
        fileName = ""
        fileBaseName = ""
    }

    property bool isFirmwareFileCopying: storage.fileIsCopying

    onIsFirmwareFileCopyingChanged: {
        if(isFirmwareFileCopying &&
           firmwareUpdatePage.state == "select_firmware_file") {
            copyingFirmwareFilePopup.open()
        }
        else {
            copyingFirmwareFilePopup.close()
        }
    }

    Text {
        id: noFilesText
        color: "#ffffff"
        font.family: "Antennae"
        font.weight: Font.Bold
        text: qsTr("NO FIRMWARE FILES")
        horizontalAlignment: Text.AlignHCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -75
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 19
        font.letterSpacing: 2
        visible: storage.storageIsEmpty

        Text {
            color: "#ffffff"
            font.family: "Antennae"
            font.weight: Font.Light
            text: qsTr("Choose another folder or visit MakerBot.com/MethodFW to\n" +
                        "download the latest firmware. Drag the file onto a usb\n" +
                        "stick and insert it into the front of the printer.")
            anchors.top: parent.bottom
            anchors.topMargin: 15
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 17
            font.letterSpacing: 1
            lineHeight: 1.4
        }
    }

    Item {
        id: itemUsbFwUpdateStorage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        smooth: false
        visible: true
        anchors.fill: parent
        opacity: storage.fileIsCopying ? 0.1 : 1.0

        ListView {
            smooth: false
            anchors.fill: parent
            boundsBehavior: Flickable.DragOverBounds
            spacing: 1
            orientation: ListView.Vertical
            flickableDirection: Flickable.VerticalFlick
            visible: !storage.storageIsEmpty && !storage.fileIsCopying
            model: storage.printFileList
            delegate:
                FileButton {
                smooth: false
                antialiasing: false
                fileThumbnail.source: model.modelData.isDir ?
                                          "qrc:/img/directory_icon.png" :
                                          "qrc:/img/sombrero_icon.png"
                fileThumbnail.width: model.modelData.isDir ? 140 : 70
                fileThumbnail.height: model.modelData.isDir ? 106 : 53
                fileThumbnail.anchors.leftMargin: model.modelData.isDir ? 25 : 60
                filenameText.text: model.modelData.fileBaseName
                fileDesc_rowLayout.visible: false
                onClicked: {
                    if(model.modelData.isDir) {
                        storage.backStackPush(model.modelData.filePath)
                        storage.updateFirmwareFileList(model.modelData.filePath + "/" + model.modelData.fileName)
                    }
                    else if(model.modelData.fileBaseName !== qsTr("No Items Present")) { // Ignore default fileBaseName object
                        if(storage.firmwareIsValid(model.modelData.filePath + "/" + model.modelData.fileName)) {
                            getFwFileDetails(model.modelData)
                            storage.copyFirmwareToDisk(model.modelData.filePath + "/" + model.modelData.fileName)
                            startFirmwareUpdate()
                        }
                    }
                }

                Item { width: parent.width; height: 1; smooth: false
                    Rectangle { color: "#4d4d4d"; smooth: false; anchors.fill: parent } }
            }
        }
    }

    Popup {
        id: copyingFirmwareFilePopup
        width: 800
        height: 480
        modal: true
        dim: false
        focus: true
        parent: overlay
        closePolicy: Popup.NoAutoClose
        background: Rectangle {
            id: popupBackgroundDim_copy_firmware_popup
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

        onClosed: {

        }

        Rectangle {
            id: basePopupItem_copy_firmware_popup
            color: "#000000"
            rotation: rootItem.rotation == 180 ? 180 : 0
            width: 720
            height: 265
            radius: 10
            border.width: 2
            border.color: "#ffffff"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                id: horizontal_divider_copy_firmware_popup
                width: 720
                height: 2
                color: "#ffffff"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 72
                visible: true
            }

            Item {
                id: buttonBar_copy_firmware_popup
                width: 720
                height: 72
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                visible: true

                Rectangle {
                   id: full_button_rectangle_copy_firmware_popup
                   x: 0
                   y: 0
                   width: 720
                   height: 72
                   color: "#00000000"
                   radius: 10
                   visible: true

                   Text {
                       id: full_button_text_copy_firmware_popup
                       color: "#ffffff"
                       text: qsTr("CANCEL")
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
                       id: full_button_mouseArea_copy_firmware_popup
                       anchors.fill: parent
                       onPressed: {
                           full_button_rectangle_copy_firmware_popup.color = "#ffffff"
                           full_button_text_copy_firmware_popup.color = "#000000"
                       }
                       onReleased: {
                           full_button_rectangle_copy_firmware_popup.color = "#00000000"
                           full_button_text_copy_firmware_popup.color = "#ffffff"
                       }
                       onClicked: {
                           updateFirmware = false
                           storage.cancelCopy()
                       }
                   }
               }
           }

            ColumnLayout {
                id: columnLayout_copy_firmware_popup
                width: 590
                height: 160
                spacing: 0
                anchors.top: parent.top
                anchors.topMargin: 25
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: alert_text_copy_firmware_popup
                    color: "#cbcbcb"
                    text: qsTr("COPYING FIRMWARE")
                    font.letterSpacing: 3
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: "Antennae"
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Item {
                    id: emptyItem_copy_firmware_popup
                    width: 10
                    height: 5
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    visible: true
                }

                Text {
                    id: description_text_copy_firmware_popup
                    color: "#cbcbcb"
                    text: (storage.fileCopyProgress * 100.0).toFixed(1) + "%"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.weight: Font.Light
                    wrapMode: Text.WordWrap
                    font.family: "Antennae"
                    font.pixelSize: 18
                    lineHeight: 1.3
                    visible: true
                }

                BusySpinner {
                    id: busyIndicator_copy_firmware_popup
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    spinnerActive: true
                    spinnerSize: 48
                }
            }
        }
    }
}
