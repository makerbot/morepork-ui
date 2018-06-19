import QtQuick 2.4

Rectangle {
    property alias button_rectangle: button_rectangle
    property alias button_text: button_text
    property alias button_mouseArea: button_mouseArea
    property alias buttonWidth: button_rectangle.width
    property alias buttonHeight: button_rectangle.height
    property alias label: button_text.text
    property int label_size: 20
    property int label_width: 300
    property bool disable_button: false

    id: button_rectangle
    width: 200
    height: 40
    color: "#00000000"
    radius: 8
    smooth: false
    antialiasing: false
    border.width: 2
    border.color: "#ffffff"

    Text {
        id: button_text
        width: label_width
        text: "Button Text"
        anchors.verticalCenterOffset: 7
        font.capitalization: Font.AllUppercase
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.family: "Antennae"
        color: "#ffffff"
        smooth: false
        antialiasing: false
        font.letterSpacing: 3
        font.weight: Font.Bold
        font.pixelSize: label_size
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        lineHeight: 1.5
    }

    MouseArea {
        id: button_mouseArea
        smooth: false
        antialiasing: false
        anchors.fill: parent
    }
}
