import QtQuick 2.10
import QtQuick.Controls 2.4

Tumbler {
    property alias tumblerName: tumblerName.text
    id: tumbler
    width: 120
    property int upperOffset: 65
    property int lowerOffset: 50

    Rectangle {
        id: topline
        width: parent.width
        height: 1
        color: "#ffffff"
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: (-1)*upperOffset
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
        id: bottomLine
        width: parent.width
        height: 1
        color: "#ffffff"
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: lowerOffset
        anchors.horizontalCenter: parent.horizontalCenter

        TextSubheader {
            id: tumblerName
            text: ""
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.bottom
            anchors.topMargin: 10
        }
    }
}
