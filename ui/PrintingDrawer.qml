import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Drawer {
    objectName: "printingDrawer"
    edge: swipeView.rotation == 180 ? Qt.BottomEdge : Qt.TopEdge
    opacity: 0.75
    width: parent.width
    height: column.height
    dim: false
    property alias mouseArea_topDrawerUp: mouseArea_topDrawerUp
    property alias button_cancelPrint: button_cancelPrint
    property alias button_pausePrint: button_pausePrint

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
        rotation: swipeView.rotation

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
                    id: text_printerName
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
                    id: image_drawerArrow
                    y: 227
                    height: 25
                    anchors.left: text_printerName.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: text_printerName.verticalCenter
                    rotation: 90
                    z: 1
                    source: "arrow_19pix.png"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        id: mouseArea_topDrawerUp
                        width: 40
                        height: 60
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        z: 2
                    }
                }
            }

            Button {
                id: button_pausePrint
                height: 100
                text: qsTr("Pause Print")
                background: Rectangle {
                    color: "#000000"
                }
                contentItem: Text {
                    text: button_pausePrint.text
                    font.family: "Antenna"
                    font.letterSpacing: 3
                    font.weight: Font.Light
                    font.pointSize: 30
                    color: "#a0a0a0"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                anchors.right: parent.right
                anchors.left: parent.left
            }

            Button {
                id: button_cancelPrint
                height: 100
                text: qsTr("Cancel Print")
                background: Rectangle {
                    color: "#000000"
                }
                contentItem: Text {
                    text: button_cancelPrint.text
                    font.family: "Antenna"
                    font.letterSpacing: 3
                    font.weight: Font.Light
                    font.pointSize: 30
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
