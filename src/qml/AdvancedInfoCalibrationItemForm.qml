import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 400
    height: 240

    ColumnLayout {
        id: columnLayout
        anchors.bottomMargin: 80
        spacing: -1.5
        anchors.fill: parent

        Text {
            id: heading
            text: qsTr("CALIBRATION OFFSETS")
            font.letterSpacing: 2
            font.weight: Font.Bold
            font.pixelSize: 20
            font.family: defaultFont.name
            color: "#ffffff"
        }

        Item {
            id: spacing_item
            width: 200
            height: 15
            visible: true
        }

        AdvancedInfoElement {
            id: currentTempProperty
            label: qsTr("X OFFSET")
            value: bot.offsetX
        }

        AdvancedInfoElement {
            id: targetTempProperty
            label: qsTr("Y OFFSET")
            value: bot.offsetY
        }

        AdvancedInfoElement {
            id: fanASpeedProperty
            label: qsTr("Z OFFSET")
            value: bot.offsetZ
        }
    }
}
