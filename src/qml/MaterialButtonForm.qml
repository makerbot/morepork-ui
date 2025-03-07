import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Button {
    id: materialButton
    width: parent.width
    height: 80
    smooth: false
    antialiasing: false
    property alias materialNameText: materialNameText.text
    property alias materialInfoText: materialInfoText.text
    property color buttonColor: "#00000000"
    property color buttonPressColor: "#0f0f0f"

    background:
        Rectangle {
        anchors.fill: parent
        opacity: materialButton.down ? 1 : 0
        color: materialButton.down ? buttonPressColor : buttonColor
        smooth: false
    }

    Rectangle {
        color: "#4d4d4d"
        width: parent.width
        height: 1
        anchors.top: parent.top
        anchors.topMargin: 0
        smooth: false
    }

    Text {
        id: materialNameText
        text: "MATERIAL NAME"
        anchors.left: parent.left
        anchors.leftMargin: 40
        anchors.verticalCenter: parent.verticalCenter
        font.family: defaultFont.name
        font.letterSpacing: 2
        font.weight: Font.Bold
        font.pointSize: 14
        font.capitalization: Font.AllUppercase
        color: "#ffffff"
        smooth: false
        antialiasing: false
    }

    Text {
        id: materialInfoText
        text: "999 C"
        anchors.right: parent.right
        anchors.rightMargin: 25
        anchors.verticalCenter: parent.verticalCenter
        font.family: defaultFont.name
        font.letterSpacing: 3
        font.weight: Font.Bold
        font.pointSize: 14
        font.capitalization: Font.AllUppercase
        color: "#ffffff"
        smooth: false
        antialiasing: false
    }
}
