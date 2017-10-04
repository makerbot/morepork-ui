import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: infoItem
    height: 40
    property alias text_data: text_data
    property alias text_label: text_label

    RowLayout {
        anchors.verticalCenter: parent.verticalCenter
        Text {
            id: text_label
            text: "Info Label"
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"
            font.pixelSize: 20
        }

        Text {
            id: text_data
            text: "nulll"
            verticalAlignment: Text.AlignTop
            anchors.verticalCenter: parent.verticalCenter
            color: "#ffffff"
            font.pixelSize: 20
        }
    }
}
