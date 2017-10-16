import QtQuick 2.0
import QtQuick.Controls 2.2

Button {
    id: moreporkButton
    height: 100
    spacing: 0
    anchors.right: parent.right
    anchors.left: parent.left
    property alias buttonText: buttonText

    background: Rectangle {
        color: moreporkButton.down ? "#0a0a0a" : "#050505"
    }

    contentItem: Text {
        id: buttonText
        text: qsTr("MoreporkButton Text")
        font.family: "Antenna"
        font.letterSpacing: 3
        font.weight: Font.Light
        font.pointSize: 30
        color: "#a0a0a0"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }


}
