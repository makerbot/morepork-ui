import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: infoItem
    height: 45
    property alias textData: textData
    property alias textLabel: textLabel

    RowLayout {
        spacing: 25
        anchors.verticalCenter: parent.verticalCenter
        Text {
            id: textLabel
            text: "Info Label"
            font.family: "Antenna"
            font.letterSpacing: 3
            font.pixelSize: 28
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"

        }

        Text {
            id: textData
            text: "null"
            font.family: "Antenna"
            font.letterSpacing: 3
            font.weight: Font.Light
            font.pixelSize: 26
            verticalAlignment: Text.AlignTop
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"
        }
    }
}
