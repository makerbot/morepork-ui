import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 400
    height: 300

    property alias toolheadLabelProperty: toolheadLabelProperty
    property alias attachedProperty: attachedProperty
    property alias filamentPresentProperty: filamentPresentProperty
    property alias currentTempProperty: currentTempProperty
    property alias targetTempProperty: targetTempProperty
    property alias tempOffsetProperty: tempOffsetProperty
    property alias encoderTicksProperty: encoderTicksProperty
    property alias activeFanRpmProperty: activeFanRpmProperty
    property alias gradientFanRpmProperty: gradientFanRpmProperty
    property alias hesValueProperty: hesValueProperty
    property alias jamEnabledProperty: jamEnabledProperty
    property alias errorCodeProperty: errorCodeProperty

    ColumnLayout {
        id: columnLayout
        spacing: 1
        anchors.fill: parent

        Text {
            id: toolheadLabelProperty
            text: qsTr("TOOLHEAD LABEL")
            font.letterSpacing: 2
            font.pixelSize: 15
            font.family: defaultFont.name
            font.weight: Font.Bold
            color: "#ffffff"
        }

        Item {
            id: spacing_item
            width: 200
            height: 15
            visible: true
        }

        AdvancedInfoElement {
            id: attachedProperty
            label: qsTr("ATTACHED")
        }

        AdvancedInfoElement {
            id: filamentPresentProperty
            label: qsTr("FILAMENT PRESENT")
        }

        AdvancedInfoElement {
            id: currentTempProperty
            label: qsTr("CURRENT TEMP.")
        }

        AdvancedInfoElement {
            id: targetTempProperty
            label: qsTr("TARGET TEMP.")
        }

        AdvancedInfoElement {
            id: tempOffsetProperty
            label: qsTr("TEMP OFFSET")
        }

        AdvancedInfoElement {
            id: encoderTicksProperty
            label: qsTr("ENCODER TICKS")
        }

        AdvancedInfoElement {
            id: activeFanRpmProperty
            label: qsTr("ACTIVE FAN RPM")
        }

        AdvancedInfoElement {
            id: gradientFanRpmProperty
            label: qsTr("GRADIENT FAN RPM")
        }

        AdvancedInfoElement {
            id: hesValueProperty
            label: qsTr("HES VALUE")
        }

        AdvancedInfoElement {
            id: jamEnabledProperty
            label: qsTr("JAM ENABLED")
        }

        AdvancedInfoElement {
            id: errorCodeProperty
            label: qsTr("ERROR")
        }
    }
}
