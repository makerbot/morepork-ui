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
    height: 480

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

        ListView {
            smooth: false
            anchors.fill: parent
            boundsBehavior: Flickable.DragOverBounds
            spacing: 1
            orientation: ListView.Vertical
            flickableDirection: Flickable.VerticalFlick
            visible: !storage.storageIsEmpty
            model: storage.printFileList
            delegate:
                FileButton {
                smooth: false
                antialiasing: false
                filenameText.text: model.modelData.fileBaseName
                fileDesc_rowLayout.visible: !model.modelData.isDir
                onClicked: {
                    if(model.modelData.isDir) {
                        storage.backStackPush(model.modelData.filePath)
                        storage.updateFirmwareFileList(model.modelData.filePath + "/" + model.modelData.fileName)
                    }
                    else if(model.modelData.fileBaseName !== "No Items Present") { // Ignore default fileBaseName object
                        getFwFileDetails(model.modelData)
                        storage.copyFirmwareToDisk(model.modelData.filePath + "/" + model.modelData.fileName)
                        startFirmwareUpdate("/home/firmware/" + model.modelData.fileName)
                    }
                }

                Item { width: parent.width; height: 1; smooth: false
                    Rectangle { color: "#4d4d4d"; smooth: false; anchors.fill: parent } }
            }
        }
    }
}
