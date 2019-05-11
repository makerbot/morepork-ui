import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

MenuItem {
    id: menuItem
    width: parent.width
    height: 50

    property alias label: menuItemLabel.text
    property bool isLastItem: false

    background: Rectangle {
        radius: 10
        anchors.fill: parent
        color: pressed ? "#ffffff" : "transparent"
    }

    Text {
        id: menuItemLabel
        text: qsTr("Menu Item")
        horizontalAlignment: Text.AlignHCenter
        font.family: "Antenna"
        font.weight: Font.Light
        font.pixelSize: 18
        color: parent.enabled ? pressed ? "#000000" : "#ffffff" : "#4d4d4d"
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
        color: "#4d4d4d"
        width: parent.width
        height: 1
        smooth: false
        anchors.top: parent.bottom
        anchors.topMargin: -1
        visible: !isLastItem
    }
}
