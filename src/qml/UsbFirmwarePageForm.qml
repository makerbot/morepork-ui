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

    Text {
        color: "#ffffff"
        width: 800
        font.family: "Antennae"
        font.weight: Font.Light
        text: "Copying firmware file to disk... " + (storage.fileCopyProgress * 100.0).toFixed(1) + "%"
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 15
        font.pointSize: 18
        visible: storage.fileIsCopying
    }

    BusySpinner {
        id: copyBusyIndicator
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -35
        anchors.horizontalCenter: parent.horizontalCenter
        spinnerActive: storage.fileIsCopying
        spinnerSize: 36
    }

    Text {
        color: "#ffffff"
        font.family: "Antennae"
        font.weight: Font.Light
        text: "No Firmware Files Found"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.pointSize: 20
        visible: storage.storageIsEmpty
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
            model: storage.fileList
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
                    else if(model.modelData.fileBaseName !== "No Items Present") { // Ignore default fileBaseName object
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
