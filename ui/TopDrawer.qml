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
        z: 0
        anchors.fill: parent
    }
    
    ListView {
        id: listView
        anchors.fill: parent
        model: ListModel {
            ListElement {
                name: "Pause Print"
            }

            ListElement {
                name: "Cancel Print"
            }
        }
        delegate: Item {
            width: 800
            height: 100
            Row {
                id: row1
                spacing: 10
                Rectangle {
                    width: 800
                    height: 100
                    color: "#000000"
                    border.color: "grey"
                    border.width: 2

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
            }
        }
    }
}
