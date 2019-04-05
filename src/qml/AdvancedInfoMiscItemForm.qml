import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 400
    height: 240

    Text {
        id: heading
        text: qsTr("MISCELLANEOUS")
        font.letterSpacing: 2
        font.weight: Font.Bold
        font.pixelSize: 20
        font.family: "Antennae"
        color: "#ffffff"
    }

    ColumnLayout {
        id: columnLayout
        anchors.top: heading.bottom
        anchors.topMargin: 10
        spacing: -2

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
    }
}
