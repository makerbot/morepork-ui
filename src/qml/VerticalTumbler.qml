import QtQuick 2.10
import QtQuick.Controls 2.4

Tumbler {
    property alias tumblerName: tumblerName.text
    id: tumbler
    width: 120

    Rectangle {
        id: topline
        width: parent.width
        height: 1
        color: "#ffffff"
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -65
    }

    Rectangle {
        id: bottomLine
        width: parent.width
        height: 1
        color: "#ffffff"
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 50

        TextSubheader {
            id: tumblerName
            text: ""
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.bottom
            anchors.topMargin: 10
        }
    }
}
