import QtQuick 2.10

Item {
    width: 640
    height: 25

    property alias axis_label: axis_label.text
    property alias enabled_value: enabled_value.text
    property alias endstop_value: endstop_value.text
    property alias position_value: position_value.text

    Text {
        id: axis_label
        width: 50
        text: qsTr("AXIS")
        font.letterSpacing: 2
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 15
        font.family: "Antennae"
        color: "#c9c9c9"
    }

    Text {
        id: enabled_value
        width: 100
        text: qsTr("ENABLED")
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 2
        anchors.left: axis_label.right
        anchors.leftMargin: 70
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 15
        font.family: "Antennae"
        color: "#ffffff"
    }

    Text {
        id: endstop_value
        width: 100
        color: "#ffffff"
        text: qsTr("ENDSTOP")
        font.letterSpacing: 2
        font.pixelSize: 15
        font.capitalization: Font.AllUppercase
        anchors.leftMargin: 70
        font.family: "Antennae"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: enabled_value.right
    }

    Text {
        id: position_value
        width: 100
        color: "#ffffff"
        text: qsTr("POSITION")
        font.letterSpacing: 2
        font.pixelSize: 15
        font.capitalization: Font.AllUppercase
        anchors.leftMargin: 70
        font.family: "Antennae"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: endstop_value.right
    }
}
