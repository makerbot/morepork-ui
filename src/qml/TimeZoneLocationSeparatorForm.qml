import QtQuick 2.10

Item {
    width: parent.width
    height: 70

    property alias region: region.text

    Text {
        id: region
        text: qsTr("WORLD")
        anchors.left: parent.left
        anchors.leftMargin: 25
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -5
        font.family: "Antenna"
        font.letterSpacing: 3
        font.weight: Font.Bold
        font.pointSize: 14
        font.capitalization: Font.AllUppercase
        color: "#ffffff"
        smooth: false
        antialiasing: false
    }
}
