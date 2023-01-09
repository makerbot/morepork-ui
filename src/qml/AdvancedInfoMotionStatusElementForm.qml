import QtQuick 2.10
import QtQuick.Layouts 1.3

Item {
    width: 800

    property alias axis_label: axis_label.text
    property alias enabled_value: enabled_value.text
    property alias endstop_value: endstop_value.text
    property alias position_value: position_value.text

    RowLayout {
        id: motion_status_rowLayout
        width: parent.width
        spacing: 0

        TextBody {
            style: {
                if (text == qsTr("AXIS")) {
                       TextBody.Large
                }
                else {
                       TextBody.Base
                }
            }
            id: axis_label
            text: qsTr("AXIS")
            font.weight: {
                if (text == qsTr("AXIS")) {
                    Font.Bold
                }
                else {
                    Font.Light
                }
            }
            font.capitalization: Font.AllUppercase
            Layout.fillWidth: true
            Layout.minimumWidth: 130
        }

        TextBody {
            style: {
                if (text == qsTr("ENABLED")) {
                       TextBody.Large
                }
                else {
                       TextBody.Base
                }
            }
            id: enabled_value
            text: qsTr("ENABLED")
            font.weight: Font.Bold
            font.capitalization: Font.AllUppercase
            Layout.fillWidth: true
            Layout.minimumWidth: 130
        }

        TextBody {
            style: {
                if (text == qsTr("ENDSTOP")) {
                       TextBody.Large
                }
                else {
                       TextBody.Base
                }
            }
            id: endstop_value
            text: qsTr("ENDSTOP")
            font.weight: Font.Bold
            font.capitalization: Font.AllUppercase
            Layout.fillWidth: true
            Layout.minimumWidth: 130
        }

        TextBody {
            style: {
                if (text == qsTr("POSITION")) {
                       TextBody.Large
                }
                else {
                       TextBody.Base
                }
            }
            id: position_value
            text: qsTr("POSITION")
            font.weight: Font.Bold
            font.capitalization: Font.AllUppercase
            Layout.fillWidth: true
            Layout.minimumWidth: 130
        }
    }
}
