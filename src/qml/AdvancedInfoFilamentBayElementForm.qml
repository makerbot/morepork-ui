import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 400
    height: 364

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
        width: parent.width
        spacing: 40

        TextHeadline {
            style: TextHeadline.Base
            id: filamentBayLabelProperty
            text: qsTr("FILAMENT BAY LABEL")
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
