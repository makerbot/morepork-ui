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
            text: "TOOLHEAD LABEL"
            font.letterSpacing: 2
            font.pixelSize: 15
            font.family: "Antenna"
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
            label: "ATTACHED"
        }

        AdvancedInfoElement {
            id: filamentPresentProperty
            label: "FILAMENT PRESENT"
        }

        AdvancedInfoElement {
            id: currentTempProperty
            label: "CURRENT TEMP."
        }

        AdvancedInfoElement {
            id: targetTempProperty
            label: "TARGET TEMP."
        }

        AdvancedInfoElement {
            id: encoderTicksProperty
            label: "ENCODER TICKS"
        }

        AdvancedInfoElement {
            id: activeFanRpmProperty
            label: "ACTIVE FAN RPM"
        }

        AdvancedInfoElement {
            id: gradientFanRpmProperty
            label: "GRADIENT FAN RPM"
        }

        AdvancedInfoElement {
            id: hesValueProperty
            label: "HES VALUE"
        }

        AdvancedInfoElement {
            id: jamEnabledProperty
            label: "JAM ENABLED"
        }

        AdvancedInfoElement {
            id: errorCodeProperty
            label: "ERROR"
        }
    }
}
