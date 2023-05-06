import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ColumnLayout {
    width: 360
    spacing: 8

    property alias componentName: component_name.text
    property int customCurrentTemperature: -999
    property int customTargetTemperature: -999
    property alias showComponentName: component_name.visible

    TextHeadline {
        id: component_name
        text: "COMPONENT"
        visible: true
    }

    RowLayout {
        spacing: 44

        ColumnLayout {
            spacing: 4

            TextBody {
                text: qsTr("Current")
            }

            TextBody {
                text: customCurrentTemperature + " C"
                font.weight: Font.Bold
            }
        }

        ColumnLayout {
            spacing: 4

            TextBody {
                text: qsTr("Target")
            }

            TextBody {
                text: customTargetTemperature + " C"
                font.weight: Font.Bold
            }
        }
    }
}
