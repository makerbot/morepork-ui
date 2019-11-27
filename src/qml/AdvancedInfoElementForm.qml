import QtQuick 2.10

Item {
    width: 400
    height: 25

    property alias label: label.text
    property alias label_width: label.width
    property alias value: value.text
    property alias value_element: value
    property alias value_anchors: value.anchors

    Text {
        id: label
        width: 200
        text: qsTr("LABEL")
        font.letterSpacing: 2
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 15
        font.family: defaultFont.name
        color: "#c9c9c9"
    }

    Text {
        id: value
        text: qsTr("VALUE")
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 2
        font.bold: true
        anchors.left: label.right
        anchors.leftMargin: 25
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 15
        font.family: defaultFont.name
        color: "#ffffff"
    }
}
