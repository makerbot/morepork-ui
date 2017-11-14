import QtQuick 2.0
import QtQuick.Controls 2.2

Button {
    id: moreporkButton
    height: 100
    smooth: false
    spacing: 0
    anchors.right: parent.right
    anchors.left: parent.left
    property alias buttonText: buttonText
    property color buttonColor: "#050505"
    property color buttonPressColor: "#0f0f0f"

    background: Rectangle {
        color: moreporkButton.down ? buttonPressColor : buttonColor
        smooth: false
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
        smooth: false
        antialiasing: false
    }
}
