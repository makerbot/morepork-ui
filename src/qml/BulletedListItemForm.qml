import QtQuick 2.10

Item {
    id: item1
    width: 300
    height: 35
    property alias bulletNumber: bulletNumber.text
    property alias bulletText: bulletText.text

    Item {
        id: bulletItem
        width: 26
        height: 26
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            id: bulletCircle
            color: "#ffffff"
            radius: 13
            anchors.fill: parent

            Text {
                id: bulletNumber
                text: "0"
                font.bold: true
                color: "#000000"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 2
                font.pixelSize: 14
                font.family: "Antennae"
                smooth: false
                antialiasing: false
            }
        }
    }

    Text {
        id: bulletText
        text: "default text"
        anchors.left: bulletItem.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        color: "#ffffff"
        font.pixelSize: 19
        font.family: "Antennae"
        font.weight: Font.Light
        smooth: false
        antialiasing: false
    }
}
