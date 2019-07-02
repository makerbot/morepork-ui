import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: infoItem
    height: 20
    width: 600
    smooth: false
    property alias labelText: labelText.text
    property alias dataText: dataText.text
    property alias dataElement: dataText
    property alias labelElement: labelText
    property alias baseElement: baseItem

    Item {
        id: baseItem
        anchors.fill: parent
        Text {
            id: labelText
            text: "label"
            antialiasing: false
            smooth: false
            anchors.left: parent.left
            anchors.leftMargin: 0
            font.family: defaultFont.name
            font.weight: Font.Light
            font.letterSpacing: 3
            font.pixelSize: 18
            anchors.verticalCenter: parent.verticalCenter
            color: "#cbcbcb"
            font.capitalization: Font.AllUppercase
        }

        Text {
            id: dataText
            text: "data"
            anchors.left: parent.left
            anchors.leftMargin: 350
            antialiasing: false
            smooth: false
            font.family: defaultFont.name
            font.letterSpacing: 5
            font.weight: Font.Bold
            font.pixelSize: 18
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"
            font.capitalization: Font.AllUppercase
        }
    }
}
