import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Drawer {
    objectName: "printingDrawer"
    edge: rootItem.rotation == 180 ? Qt.BottomEdge : Qt.TopEdge
    width: parent.width
    height: column.height
    dim: true
    interactive: false
    property alias mouseAreaTopDrawerUp: mouseAreaTopDrawerUp
    property alias buttonCancelPrint: buttonCancelPrint
    property alias buttonPausePrint: buttonPausePrint
    property alias buttonChangeFilament: buttonChangeFilament
    property alias buttonClose: buttonClose

    Rectangle {
        id: rectangle
        color: "#000000"
        smooth: false
        visible: true
        width: parent.width
        height: column.height
    }

    Flickable {
        id: flickable
        smooth: false
        anchors.fill: parent
        rotation: rootItem.rotation

        Column {
            id: column
            smooth: false
            spacing: 1
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left

            Rectangle {
                id: rectangle1
                height: 40
                color: "#000000"
                smooth: false
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Text {
                    id: textPrinterName
                    color: "#a0a0a0"
                    text: bot.name
                    antialiasing: false
                    smooth: false
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Antenna"
                    font.letterSpacing: 3
                    font.weight: Font.Light
                    font.pixelSize: 22
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }

                Image {
                    id: imageDrawerArrow
                    y: 227
                    height: 25
                    smooth: false
                    anchors.left: textPrinterName.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: textPrinterName.verticalCenter
                    rotation: 90
                    z: 1
                    source: "qrc:/img/arrow_19pix.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        id: mouseAreaTopDrawerUp
                        width: 40
                        height: 60
                        smooth: false
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        z: 2
                    }
                }
            }

            Rectangle{
                width: parent.width; height: 1; color: "#4d4d4d"
            }

            MoreporkButton {
                id: buttonPausePrint
                //buttonText.text: qsTr("Pause Print") + cpUiTr.emptyStr
                buttonText.text: "PAUSE PRINT"
                buttonImage.source: "qrc:/img/pause.png"
                buttonColor: "#000000"
                buttonPressColor: "#0a0a0a"
                height: 80
            }

            Rectangle{
                width: parent.width; height: 1; color: "#4d4d4d"
            }

            MoreporkButton {
                id: buttonCancelPrint
                //buttonText.text: qsTr("Cancel Print") + cpUiTr.emptyStr
                buttonText.text: "CANCEL PRINT"
                buttonImage.source: "qrc:/img/cancel.png"
                buttonColor: "#000000"
                buttonPressColor: "#0a0a0a"
                height: 80
            }

            Rectangle{
                width: parent.width; height: 1; color: "#4d4d4d"
            }

            MoreporkButton {
                id: buttonChangeFilament
                //buttonText.text: qsTr("Cancel Print") + cpUiTr.emptyStr
                buttonText.text: "CHANGE FILAMENT"
                buttonImage.source: "qrc:/img/change_filament.png"
                buttonColor: "#000000"
                buttonPressColor: "#0a0a0a"
                height: 80
            }

            Rectangle{
                width: parent.width; height: 1; color: "#4d4d4d"
            }

            MoreporkButton {
                id: buttonClose
                //buttonText.text: qsTr("Cancel Print") + cpUiTr.emptyStr
                buttonText.text: "CLOSE"
                buttonImage.source: "qrc:/img/close.png"
                buttonColor: "#000000"
                buttonPressColor: "#0a0a0a"
                height: 80
            }

            Rectangle{
                width: parent.width; height: 1; color: "#4d4d4d"
            }
        }
    }
}
