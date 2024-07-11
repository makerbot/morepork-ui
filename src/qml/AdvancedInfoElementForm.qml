import QtQuick 2.10

Item {
    width: parent.width
    height: label.height

    property alias label_element: label
    property alias label: label.text
    property alias label_width: label.width
    property alias value: value.text
    property alias value_element: value
    property alias value_anchors: value.anchors

    TextBody {
        id: label
        text: "LABEL"

        style: TextBody.Base
        font.weight: Font.Light
        lineHeight: 1.1
        lineHeightMode: Text.ProportionalHeight
        wrapMode: Text.WordWrap
        font.letterSpacing: 2

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: value.left
        anchors.rightMargin: 20
        anchors.left: parent.left
  }

    TextBody {
        id: value
        text: "VALUE"

        style: TextBody.Base
        font.capitalization: Font.AllUppercase
        font.weight: Font.Bold
        lineHeight: 1.2
        lineHeightMode: Text.ProportionalHeight

        horizontalAlignment: Text.AlignRight

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

    }
}
