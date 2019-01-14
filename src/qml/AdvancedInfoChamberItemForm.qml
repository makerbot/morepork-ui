import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 400
    height: 240

    ColumnLayout {
        id: columnLayout
        anchors.bottomMargin: 40
        spacing: -1.5
        anchors.fill: parent

        Text {
            id: heading
            text: "CHAMBER"
            font.letterSpacing: 2
            font.weight: Font.Bold
            font.pixelSize: 20
            font.family: "Antennae"
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
            label: "CURRENT TEMP."
            value: bot.infoChamberCurrentTemp
        }

        AdvancedInfoElement {
            id: targetTempProperty
            label: "TARGET TEMP."
            value: bot.infoChamberTargetTemp
        }

        AdvancedInfoElement {
            id: fanASpeedProperty
            label: "FAN A SPEED"
            value: bot.infoChamberFanASpeed
        }

        AdvancedInfoElement {
            id: fanBSpeedProperty
            label: "FAN B SPEED"
            value: bot.infoChamberFanBSpeed
        }

        AdvancedInfoElement {
            id: heaterATempProperty
            label: "HEATER A TEMP."
            value: bot.infoChamberHeaterATemp
        }

        AdvancedInfoElement {
            id: heaterBTempProperty
            label: "HEATER B TEMP."
            value: bot.infoChamberHeaterBTemp
        }

        AdvancedInfoElement {
            id: errorCodeProperty
            label: "ERROR"
            value: bot.infoChamberError
        }
    }
}
