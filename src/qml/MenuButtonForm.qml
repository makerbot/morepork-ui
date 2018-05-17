import QtQuick 2.4
import QtQuick.Controls 2.2

Button {
    id: menuButton
    height: 90
    smooth: false
    spacing: 0
    anchors.right: parent.right
    anchors.left: parent.left
    property alias buttonText: buttonText
    property alias buttonImage: buttonImage
    property color buttonColor: "#00000000"
    property color buttonPressColor: "#0f0f0f"

    background: Rectangle {
        opacity: menuButton.down ? 1 : 0
        color: menuButton.down ? buttonPressColor : buttonColor
        smooth: false
    }

    Image {
        id: buttonImage
        width: 55*1.2
        height: 40*1.2
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        smooth: false
        antialiasing: false
    }

    contentItem: Text {
        id: buttonText
        text: "Default Text"
        font.family: "Antenna"
        font.letterSpacing: 3
        font.weight: Font.Bold
        font.pointSize: 14
        color: "#ffffff"
        anchors.left: buttonImage.right
        anchors.leftMargin: 25
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        smooth: false
        antialiasing: false
    }
}
