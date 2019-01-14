import QtQuick 2.10

Item {
    width: 400
    height: 25

    property alias label: label.text
    property alias value: value.text
    property alias value_anchors: value.anchors

    Text {
        id: label
        width: 200
        text: "LABEL"
        font.letterSpacing: 2
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 15
        font.family: "Antennae"
        color: "#c9c9c9"
    }

    Text {
        id: value
        text: "VALUE"
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 2
        font.bold: true
        anchors.left: label.right
        anchors.leftMargin: 25
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 15
        font.family: "Antennae"
        color: "#ffffff"
    }
}
