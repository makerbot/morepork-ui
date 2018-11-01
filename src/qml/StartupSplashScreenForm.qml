import QtQuick 2.10

Item {
    id: item1
    anchors.fill: parent

    Image {
        id: image
        width: sourceSize.width
        height: sourceSize.height
        anchors.verticalCenterOffset: -25
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/makerbot_startup_logo.png"

        Text {
            id: startup_message_text
            text: "STARTING UP..."
            anchors.top: parent.bottom
            anchors.topMargin: 45
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 18
            font.weight: Font.Light
            font.family: "Antennae"
            font.letterSpacing: 3
            color: "#ffffff"
        }
    }
}
