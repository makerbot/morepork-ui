import QtQuick 2.10

Item {
    width: parent.width

    property alias label_element: label
    property alias label: label.text
    property alias label_width: label.width
    property alias value: value.text
    property alias value_element: value
    property alias value_anchors: value.anchors

    TextBody {
        id: label
        style: TextBody.Base
        font.weight: Font.Light
        width: 235
        text: "LABEL"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: value.left
        anchors.left: parent.left
        font.letterSpacing: 2
        anchors.left: parent.left
    }

    TextBody {
        id: value
        style: TextBody.Base
        font.weight: Font.Bold
        // We need to specify width to word wrap
        width: parent.width - label.width - anchors.leftMargin
        text: "VALUE"
        font.capitalization: Font.AllUppercase
        anchors.left: label.right
        anchors.leftMargin: 5
        horizontalAlignment: Text.AlignRight
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
    }
}
