import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Drawer {
    edge: Qt.TopEdge
    opacity: 0.75
    width: parent.width
    height: column.height
    dim: false
    property alias mouseAreaTopDrawerUp: mouseAreaTopDrawerUp
    property alias buttonCancelPrint: buttonCancelPrint
    property alias buttonPausePrint: buttonPausePrint

    Rectangle {
        id: rectangle
        color: "#000000"
        visible: true
        width: parent.width
        height: column.height
    }

    Flickable {
        id: flickable
        anchors.fill: parent

        Column {
            id: column
            spacing: 1
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left

            Rectangle {
                id: rectangle1
                height: 40
                color: "#000000"
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0

                Text {
                    id: textPrinterName
                    color: "#a0a0a0"
                    text: bot.name
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Antenna"
                    font.letterSpacing: 3
                    font.weight: Font.Light
                    font.pixelSize: 30
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }

                Image {
                    id: imageDrawerArrow
                    y: 227
                    height: 25
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
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        z: 2
                    }
                }
            }

            Button {
                id: buttonPausePrint
                height: 100
                text: qsTr("Pause Print")
                background: Rectangle {
                    color: "#000000"
                }
                contentItem: Text {
                    text: buttonPausePrint.text
                    font.family: "Antenna"
                    font.letterSpacing: 3
                    font.weight: Font.Light
                    font.pixelSize: 30
                    color: "#a0a0a0"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                anchors.right: parent.right
                anchors.left: parent.left
            }

            Button {
                id: buttonCancelPrint
                height: 100
                text: qsTr("Cancel Print")
                background: Rectangle {
                    color: "#000000"
                }
                contentItem: Text {
                    text: buttonCancelPrint.text
                    font.family: "Antenna"
                    font.bold: true
                    font.pixelSize: 30
                    color: "#a0a0a0"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                anchors.left: parent.left
                anchors.right: parent.right
            }

        }
    }
}
