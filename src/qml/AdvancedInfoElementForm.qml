import QtQuick 2.10

Item {
    width: 400

    property alias label_element: label
    property alias label: label.text
    property alias label_width: label.width
    property alias value: value.text
    property alias value_element: value
    property alias value_anchors: value.anchors

    TextBody {
        style: TextBody.Base
        font.weight: Font.Light
        id: label
        width: 250
        text: qsTr("LABEL")
        anchors.verticalCenter: parent.verticalCenter
        font.letterSpacing: 2
    }

    TextBody {
        style: TextBody.Base
        font.weight: Font.Bold
        id: value
        text: qsTr("VALUE")
        font.capitalization: Font.AllUppercase
        horizontalAlignment: Text.AlignRight
        anchors.right: parent.right
        anchors.rightMargin: 63
        anchors.verticalCenter: parent.verticalCenter
    }
}
