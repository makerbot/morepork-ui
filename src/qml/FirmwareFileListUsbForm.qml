import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import MachineTypeEnum 1.0

Item {
    id: element
    smooth: false
    width: 800
    height: 440
    property string fileName: "unknown.zip"
    property string fileBaseName

    function getFwFileDetails(file) {
        fileName = file.filePath + "/" + file.fileName
        fileBaseName = file.fileBaseName
    }

    function resetFwFileDetails() {
        fileName = ""
        fileBaseName = ""
    }

    Text {
        id: noFilesText
        color: "#ffffff"
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
            text: {
                qsTr("Choose another folder or visit <b>makerbot.com/%1</b> to<br> download the " +
                     "latest firmware. Drag the file onto a usb<br> stick and insert it into " +
                     "the front of the printer.").arg(getUrlByMachineType(bot.machineType))
            }
            anchors.top: parent.bottom
            anchors.topMargin: 15
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 17
            font.letterSpacing: 1
            lineHeight: 1.4
        }
    }

    Text {
        id: itemUsbCurrentFwText
        color: "#ffffff"
        font.family: "Antennae"
        font.weight: Font.Light
        text: qsTr("CURRENT FIRMWARE: %1").arg(bot.version)
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        visible: !storage.storageIsEmpty && !storage.fileIsCopying
        font.pixelSize: 18
        font.letterSpacing: 1
        lineHeight: 1.4
    }

    Item {
        id: itemUsbFwUpdateStorage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        smooth: false
        visible: true
        anchors.top: itemUsbCurrentFwText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
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
            clip: true
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
}
