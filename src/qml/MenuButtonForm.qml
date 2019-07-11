import QtQuick 2.10
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
    property bool buttonNeedsAction: false
    property color buttonColor: "#00000000"
    property color buttonPressColor: "#0f0f0f"
    enabled: true

    background: Rectangle {
        opacity: menuButton.down ? 1 : 0
        color: menuButton.down ? buttonPressColor : buttonColor
        smooth: false
    }

    Rectangle {
        color: "#4d4d4d"
        width: parent.width
        height: 1
        anchors.top: parent.bottom
        anchors.topMargin: -1
        smooth: false
    }

    Item {
        id: contentItem
        anchors.fill: parent
        opacity: enabled ? 1.0 : 0.3

        Image {
            id: buttonImage
            width: sourceSize.width
            height: sourceSize.height
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            smooth: false
            antialiasing: false
        }

        Text {
            id: buttonText
            text: "Default Text"
            font.family: defaultFont.name
            font.letterSpacing: 3
            font.weight: Font.Bold
            font.pointSize: 14
            color: "#ffffff"
            anchors.left: buttonImage.right
            anchors.leftMargin: 28
            anchors.verticalCenter: parent.verticalCenter
            smooth: false
            antialiasing: false
        }

        Image {
            id: buttonAlertImage
            width: sourceSize.width
            height: sourceSize.height
            anchors.right: parent.right
            anchors.rightMargin: 30
            anchors.verticalCenter: parent.verticalCenter
            smooth: false
            antialiasing: false
            source: "qrc:/img/alert.png"
            visible: buttonNeedsAction
        }
    }
}
