import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 800
    height: 120

    ColumnLayout {
        id: columnLayout
        anchors.bottomMargin: 30
        spacing: 0
        anchors.fill: parent

        Text {
            id: heading
            text: qsTr("HEATING SYSTEM")
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
            id: stateStrProperty
            label: qsTr("STATE")
            value_anchors.leftMargin: -100
            value: bot.infoHeatSysStateStr
        }

        AdvancedInfoElement {
            id: errorStrProperty
            label: qsTr("ERROR")
            value_anchors.leftMargin: -100
            value: bot.infoHeatSysErrorStr
        }
    }
}
