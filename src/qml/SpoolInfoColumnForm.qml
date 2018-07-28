import QtQuick 2.7
import QtQuick.Layouts 1.3

Item {
    property alias title: title
    property alias keys: keys
    property alias vals: vals
    property alias keyItem: keyItem
    property alias valItem: valItem

    property int index: 0
    property bool initialized: false

    width: parent.width/2

    Rectangle {
        anchors.fill: parent
        color: "#0000cc"
    }

    ColumnLayout {
        Text {
            id: title

            text: ""
            color: "#ffffff"
            font.letterSpacing: 1
            font.bold: true
            anchors.horizontalCenterOffset: 0
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 15
        }

        RowLayout {
            id: contents
            spacing: 20

            Component {
                id: keyItem

                Text {
                    color: "#ffffff"
                    font.pixelSize: 12
                }
            }
            Component {
                id: valItem

                Text {
                    property string key: ""

                    text: key ? bot[key] : ""
                    color: "#ffffff"
                    font.pixelSize: 12
                }
            }


            ColumnLayout {
                id: keys
            }

            ColumnLayout {
                id: vals
            }
        }
    }

}
