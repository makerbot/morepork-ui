import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ColumnLayout {
    spacing: 20

    property string toolName: "TOOL"
    property int currentTemp: -999
    property int targetTemp: -999

    TextHeadline {
        text: toolName
    }
    RowLayout {
        anchors.topMargin: 10
        Layout.preferredWidth: parent.width
        TextSubheader {
            text: qsTr("CURRENT TEMP.")
        }
        TextSubheader {
            horizontalAlignment: Text.AlignRight
            Layout.alignment: Qt.AlignRight

            text: currentTemp + " C"
        }
    }
    RowLayout {
        Layout.preferredWidth: parent.width
        TextSubheader {
            verticalAlignment: Text.AlignTop

            text: qsTr("TARGET TEMP.")
        }
        TextSubheader {
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignRight
            Layout.alignment: Qt.AlignRight

            text: targetTemp + " C"
        }
    }
}


