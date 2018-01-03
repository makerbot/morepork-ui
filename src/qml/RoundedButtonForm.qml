import QtQuick 2.4

Rectangle {

    property alias button_rectangle: button_rectangle
    property alias button_text: button_text
    property alias button_mouseArea: button_mouseArea
    property alias buttonWidth: button_rectangle.width
    property alias buttonHeight: button_rectangle.height
    property alias label: button_text.text

    id: button_rectangle
    width: 200
    height: 40
    color: "#00000000"
    radius: 10
    smooth: false
    antialiasing: false
    border.width: 2
    border.color: "#ffffff"

    Text {
        id: button_text
        width: 300
        text: "Button Text"
        font.capitalization: Font.AllUppercase
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.family: "Antennae"
        color: "#ffffff"
        smooth: false
        antialiasing: false
        font.letterSpacing: 3
        font.weight: Font.Bold
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
    }

    MouseArea {
        id: button_mouseArea
        smooth: false
        antialiasing: false
        anchors.fill: parent
    }
}
