import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import MachineTypeEnum 1.0

Item {
    width: 400
    height: 240

    Text {
        id: heading
        text: qsTr("MISCELLANEOUS")
        font.letterSpacing: 2
        font.weight: Font.Bold
        font.pixelSize: 20
        font.family: defaultFont.name
        color: "#ffffff"
    }

    ColumnLayout {
        id: columnLayout
        anchors.top: heading.bottom
        anchors.topMargin: 15
        spacing: 0

        AdvancedInfoElement {
            id: doorActivatedProperty
            label: qsTr("DOOR CLOSED")
            value: bot.infoDoorActivated
        }

        AdvancedInfoElement {
            id: lidActivatedProperty
            label: qsTr("LID CLOSED")
            value: bot.infoLidActivated
        }

        AdvancedInfoElement {
            id: topBunkFanARpmProperty
            label: qsTr("TOP BUNK FAN A RPM")
            value: bot.infoTopBunkFanARPM
        }

        AdvancedInfoElement {
            id: topBunkFanBRpmProperty
            label: qsTr("TOP BUNK FAN B RPM")
            value: bot.infoTopBunkFanBRPM
        }

        AdvancedInfoElement {
            id: cameraStateProperty
            label: qsTr("CAMERA STATE")
            value_anchors.leftMargin: value == "Unknown" ? 25 : -25
            value: bot.cameraState
        }

        AdvancedInfoElement {
            id: hbpCurrentTempProperty
            label: qsTr("HBP CURR. TEMP.")
            value: Math.floor(bot.hbpCurrentTemp)
            visible: bot.machineType == MachineType.Magma
        }

        AdvancedInfoElement {
            id: hbpTargetTempProperty
            label: qsTr("HBP TGT. TEMP.")
            value: bot.hbpTargetTemp
            visible: bot.machineType == MachineType.Magma
        }
    }
}
