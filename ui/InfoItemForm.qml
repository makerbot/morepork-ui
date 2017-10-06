import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: infoItem
    height: 45
    property alias text_data: text_data
    property alias text_label: text_label

    RowLayout {
        anchors.verticalCenter: parent.verticalCenter
        Text {
            id: text_label
            text: "Info Label"
            font.family: "Antenna"
            font.bold: true
            font.pixelSize: 30
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"

        }

        Text {
            id: text_data
            text: "nulll"
            font.family: "Antenna"
            font.pixelSize: 30
            verticalAlignment: Text.AlignTop
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"
        }
    }
}
