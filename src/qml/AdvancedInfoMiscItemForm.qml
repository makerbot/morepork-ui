import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 400
    height: 240

    Text {
        id: heading
        text: "MISCELLANEOUS"
        font.letterSpacing: 2
        font.weight: Font.Bold
        font.pixelSize: 20
        font.family: "Antenna"
        color: "#ffffff"
    }

    ColumnLayout {
        id: columnLayout
        anchors.top: heading.bottom
        anchors.topMargin: 10
        spacing: -2

        AdvancedInfoElement {
            id: doorActivatedProperty
            label: "DOOR CLOSED"
            value: bot.infoDoorActivated
        }

        AdvancedInfoElement {
            id: lidActivatedProperty
            label: "LID CLOSED"
            value: bot.infoLidActivated
        }

        AdvancedInfoElement {
            id: topBunkFanARpmProperty
            label: "TOP BUNK FAN A RPM"
            value: bot.infoTopBunkFanARPM
        }

        AdvancedInfoElement {
            id: topBunkFanBRpmProperty
            label: "TOP BUNK FAN B RPM"
            value: bot.infoTopBunkFanBRPM
        }
    }
}
