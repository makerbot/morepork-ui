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
        font.family: "Antennae"
        font.weight: Font.Light
        text: "Copying firmware file to disk... " + (storage.fileCopyProgress * 100.0).toFixed(1) + "%"
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -20
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: 20
        visible: storage.fileIsCopying
    }

    BusyIndicator {
        id: copyBusyIndicator
        running: true
        visible: storage.fileIsCopying
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -20
        anchors.horizontalCenter: parent.horizontalCenter


        contentItem: Item {
            implicitWidth: 64
            implicitHeight: 64

            Item {
                id: item
                x: parent.width / 2 - 32
                y: parent.height / 2 - 32
                width: 64
                height: 64
                opacity: copyBusyIndicator.running ? 1 : 0

                Behavior on opacity {
                    OpacityAnimator {
                        duration: 250
                    }
                }

                RotationAnimator {
                    target: item
                    running: copyBusyIndicator.visible && copyBusyIndicator.running
                    from: 0
                    to: 360
                    loops: Animation.Infinite
                    duration: 1500
                }

                Repeater {
                    id: repeater
                    model: 6

                    Rectangle {
                        x: item.width / 2 - width / 2
                        y: item.height / 2 - height / 2
                        implicitWidth: 2
                        implicitHeight: 16
                        radius: 0
                        color: "#ffffff"
                        transform: [
                            Translate {
                                y: -Math.min(item.width, item.height) * 0.5 + 5
                            },
                            Rotation {
                                angle: index / repeater.count * 360
                                origin.x: 1
                                origin.y: 8
                            }
                        ]
                    }
                }
            }
        }
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
            visible: !storage.storageIsEmpty
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
                    else if(model.modelData.fileBaseName !== "No Items Present") { // Ignore default fileBaseName object
                        getFwFileDetails(model.modelData)
                        storage.copyFirmwareToDisk(model.modelData.filePath + "/" + model.modelData.fileName)
                        startFirmwareUpdate()
                    }
                }

                Item { width: parent.width; height: 1; smooth: false
                    Rectangle { color: "#4d4d4d"; smooth: false; anchors.fill: parent } }
            }
        }
    }
}
