import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 400
    height: columnLayout.height

    property alias toolheadLabelProperty: toolheadLabelProperty
    property alias attachedProperty: attachedProperty
    property alias filamentPresentProperty: filamentPresentProperty
    property alias currentTempProperty: currentTempProperty
    property alias targetTempProperty: targetTempProperty
    property alias tempOffsetProperty: tempOffsetProperty
    property alias encoderTicksProperty: encoderTicksProperty
    property alias activeFanRpmProperty: activeFanRpmProperty
    property alias activeFanFailSecsProperty: activeFanFailSecsProperty
    property alias gradientFanRpmProperty: gradientFanRpmProperty
    property alias gradientFanFailSecsProperty: gradientFanFailSecsProperty
    property alias hesValueProperty: hesValueProperty
    property alias jamEnabledProperty: jamEnabledProperty
    property alias errorCodeProperty: errorCodeProperty

    Column {
        id: columnLayout
        width: parent.width
        spacing: 25

        TextHeadline {
            style: TextHeadline.Base
            id: toolheadLabelProperty
            text: ("TOOLHEAD LABEL")
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
            id: activeFanFailSecsProperty
            label: qsTr("AC. FAN FAIL SECS")
        }

        AdvancedInfoElement {
            id: gradientFanRpmProperty
            label: qsTr("GRADIENT FAN RPM")
        }

        AdvancedInfoElement {
            id: gradientFanFailSecsProperty
            label: qsTr("GR. FAN FAIL SECS")
        }

        AdvancedInfoElement {
            id: hesValueProperty
            label: "HES " + qsTr("VALUE")
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
