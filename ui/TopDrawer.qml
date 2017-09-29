import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Drawer {
    id: drawer
    edge: Qt.TopEdge
    opacity: 0.8
    width: parent.width
    height: column.height
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

        Column {
            id: column
            spacing: 1
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left

            Button {
                id: button_pausePrint
                height: 100
                text: qsTr("Pause Print")
                font.pointSize: 20
                background: Rectangle {
                    color: "#000000"
                }
                contentItem: Text {
                    text: button_pausePrint.text
                    font: button_pausePrint.font
                    color: "#a0a0a0"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
            }

            Button {
                id: button_cancelPrint
                height: 100
                text: qsTr("Cancel Print")
                font.pointSize: 20
                background: Rectangle {
                    color: "#000000"
                }
                contentItem: Text {
                    text: button_cancelPrint.text
                    font: button_cancelPrint.font
                    color: "#a0a0a0"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.right: parent.right
            }
        }
    }
}
