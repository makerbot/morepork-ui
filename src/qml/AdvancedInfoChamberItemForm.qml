import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: parent.width
    implicitHeight: columnLayout.height

    Column {
        id: columnLayout
        width: parent.width
        spacing: 40

        TextHeadline {
            style: TextHeadline.Large
            id: heading
            text: qsTr("CHAMBER")
            font.letterSpacing: 10
            width: parent.width
        }

        Column {
            width: 400
            spacing: 25

            AdvancedInfoElement {
                id: currentTempProperty
                label: qsTr("SENSOR TEMP.")
                value: bot.infoChamberCurrentTemp
            }

            AdvancedInfoElement {
                id: targetTempProperty
                label: qsTr("SENSOR TGT. TEMP.")
                value: bot.infoChamberTargetTemp
            }

            AdvancedInfoElement {
                id: buildplaneTempProperty
                label: qsTr("BUILD PLANE TEMP.")
                value: bot.buildplaneCurrentTemp
            }

            AdvancedInfoElement {
                id: buildplaneTargetProperty
                label: qsTr("BUILD PLANE TGT. TEMP.")
                value: bot.buildplaneTargetTemp
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
}
