import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import MachineTypeEnum 1.0

Item {
    width: 400
    height: bot.machineType == MachineType.Magma ? (257 + 86) : 257

    ColumnLayout {
        id: columnLayout
        width: parent.width
        spacing: 40

        TextHeadline {
            style: TextHeadline.Large
            id: heading
            text: qsTr("MISCELLANEOUS")
            font.letterSpacing: 10
        }

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
