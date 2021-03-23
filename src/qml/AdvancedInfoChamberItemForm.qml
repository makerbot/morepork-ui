import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 400
    height: 240

    ColumnLayout {
        id: columnLayout
        anchors.bottomMargin: 30
        spacing: 0
        anchors.fill: parent

        Text {
            id: heading
            text: qsTr("CHAMBER")
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
            label: qsTr("CURRENT TEMP.")
            value: bot.infoChamberCurrentTemp
        }

        AdvancedInfoElement {
            id: targetTempProperty
            label: qsTr("TARGET TEMP.")
            value: bot.infoChamberTargetTemp
        }

        AdvancedInfoElement {
            id: fanASpeedProperty
            label: qsTr("FAN A SPEED")
            value: bot.infoChamberFanASpeed
        }

        AdvancedInfoElement {
            id: fanBSpeedProperty
            label: qsTr("FAN B SPEED")
            value: bot.infoChamberFanBSpeed
        }

        AdvancedInfoElement {
            id: heaterATempProperty
            label: qsTr("HEATER A TEMP.")
            value: bot.infoChamberHeaterATemp
        }

        AdvancedInfoElement {
            id: heaterBTempProperty
            label: qsTr("HEATER B TEMP.")
            value: bot.infoChamberHeaterBTemp
        }

        AdvancedInfoElement {
            id: errorCodeProperty
            label: qsTr("ERROR")
            value: bot.infoChamberError
        }
    }
}
