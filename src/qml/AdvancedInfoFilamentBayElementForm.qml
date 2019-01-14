import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 400
    height: 180

    property alias filamentBayLabelProperty: filamentBayLabelProperty
    property alias temperatureProperty: temperatureProperty
    property alias humidityProperty: humidityProperty
    property alias filamentPresentProperty: filamentPresentProperty
    property alias tagPresentProperty: tagPresentProperty
    property alias tagUidProperty: tagUidProperty
    property alias errorCodeProperty: errorCodeProperty

    ColumnLayout {
        id: columnLayout
        spacing: 0
        anchors.fill: parent

        Text {
            id: filamentBayLabelProperty
            text: "FILAMENT BAY LABEL"
            font.letterSpacing: 2
            font.pixelSize: 15
            font.family: "Antennae"
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
            id: temperatureProperty
            label: "TEMPERATURE"
        }

        AdvancedInfoElement {
            id: humidityProperty
            label: "HUMIDITY"
        }

        AdvancedInfoElement {
            id: filamentPresentProperty
            label: "FILAMENT PRESENT"
        }

        AdvancedInfoElement {
            id: tagPresentProperty
            label: "TAG PRESENT"
        }

        AdvancedInfoElement {
            id: tagUidProperty
            label: "TAG UID"
            value_anchors.leftMargin: value == "Unknown" ? 25 : -50
        }

        AdvancedInfoElement {
            id: errorCodeProperty
            label: "ERROR"
        }
    }
}
