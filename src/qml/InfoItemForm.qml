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
        TextBody {
            style: TextBody.Regular

            id: labelText
            font.weight: Font.Medium
            text: "label"
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.verticalCenter: parent.verticalCenter
            antialiasing: false
            smooth: false
            font.capitalization: Font.AllUppercase
            width: 270
        }

        TextBody {
            style: TextBody.Regular

            id: dataText
            font.weight: Font.Bold
            text: "data"
            anchors.left: parent.left
            anchors.leftMargin: 320
            anchors.verticalCenter: parent.verticalCenter
            antialiasing: false
            smooth: false
            font.capitalization: Font.AllUppercase
            width: 415
            elide: Text.ElideRight
        }
    }
}
