import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 400
    height: 230

    property alias filamentBayLabelProperty: filamentBayLabelProperty
    property alias temperatureProperty: temperatureProperty
    property alias humidityProperty: humidityProperty
    property alias filamentPresentProperty: filamentPresentProperty
    property alias tagPresentProperty: tagPresentProperty
    property alias tagUidProperty: tagUidProperty
    property alias tagVerifiedProperty: tagVerifiedProperty
    property alias verificationDoneProperty: verificationDoneProperty
    property alias errorCodeProperty: errorCodeProperty

    ColumnLayout {
        id: columnLayout
        spacing: 0
        anchors.fill: parent

        Text {
            id: filamentBayLabelProperty
            text: qsTr("FILAMENT BAY LABEL")
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
            id: temperatureProperty
            label: qsTr("TEMPERATURE")
        }

        AdvancedInfoElement {
            id: humidityProperty
            label: qsTr("HUMIDITY")
        }

        AdvancedInfoElement {
            id: filamentPresentProperty
            label: qsTr("FILAMENT PRESENT")
        }

        AdvancedInfoElement {
            id: tagPresentProperty
            label: qsTr("TAG PRESENT")
        }

        AdvancedInfoElement {
            id: tagUidProperty
            label: qsTr("TAG UID")
            value_anchors.leftMargin: value == "Unknown" ? 25 : -50
        }

        AdvancedInfoElement {
            id: tagVerifiedProperty
            label: qsTr("TAG VERIFIED")
            value_element.visible: {
                !waitingSpinner.spinnerActive
            }
            BusySpinner {
                id: waitingSpinner
                anchors.right: parent.right
                anchors.rightMargin: 135
                anchors.verticalCenter: parent.verticalCenter
                spinnerActive: {
                    tagPresentProperty.value == "true" &&
                    verificationDoneProperty.value == "false"
                }
                spinnerSize: 24
            }
        }

        AdvancedInfoElement {
            id: verificationDoneProperty
            label: qsTr("VERIFICATION DONE")
        }

        AdvancedInfoElement {
            id: errorCodeProperty
            label: qsTr("ERROR")
        }
    }
}
