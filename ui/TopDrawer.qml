import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Drawer {
    id: drawer
    edge: Qt.TopEdge
    opacity: 0.8

    Rectangle {
        id: rectangle
        color: "#000000"
        visible: true
        width: parent.width
        height: parent.height
    }
    
    ListView {
        id: listView
        boundsBehavior: Flickable.StopAtBounds
        anchors.fill: parent

        model: ListModel {
            ListElement {
                name: "Pause Print"
                lastItem: false
            }

            ListElement {
                name: "Cancel Print"
                lastItem: true
            }
        }

        delegate: Item {
            //property bool lastItem: false
            width: parent.width
            height: lastItem ? 100 : 101
            MouseArea {
                id: mouseArea
                width: parent.width
                height: 100

                Text {
                    z: 100
                    text: name
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 40
                    color: "#ffffff"
                }
            }
            Rectangle {
                color: "#a0a0a0"
                width: parent.width
                height: (lastItem == true) ? 0 : 1
                anchors.top: mouseArea.bottom
            }
        }
    }

    width: parent.width
    height: ((listView.count-1)*101)+100
}
