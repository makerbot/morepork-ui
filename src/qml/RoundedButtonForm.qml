import QtQuick 2.10

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
    property bool is_button_transparent: true
    property string button_pressed_color: "#ffffff"
    property string button_not_pressed_color: "#000000"

    id: button_rectangle
    width: 200
    height: 40
    color: is_button_transparent ? "#00000000" : button_not_pressed_color
    radius: 8
    smooth: false
    antialiasing: false
    border.width: 2
    border.color: "#ffffff"
    opacity: disable_button ? 0.3 : 1

    Text {
        id: button_text
        width: label_width
        text: "Button Text"
        anchors.verticalCenterOffset: 7
        font.capitalization: Font.AllUppercase
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.family: "Antenna"
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
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: parent.height + 30
        smooth: false
        antialiasing: false
        preventStealing: true
        enabled: !disable_button
    }
}
