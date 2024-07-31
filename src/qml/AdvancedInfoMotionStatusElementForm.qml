import QtQuick 2.10
import QtQuick.Layouts 1.3

Item {
    width: parent.width
    height: motion_status_rowLayout.height
    property alias axis: axis_label
    property alias enabled: enabled_value
    property alias endstop: endstop_value
    property alias position: position_value
    property alias axis_label: axis_label.text
    property alias enabled_value: enabled_value.text
    property alias endstop_value: endstop_value.text
    property alias position_value: position_value.text

    RowLayout {
        id: motion_status_rowLayout
        width: parent.width
        spacing: 0

        TextBody {
            id: axis_label
            style: TextBody.Base
            text: qsTr("AXIS")
            font.weight: Font.Light
            font.capitalization: Font.AllUppercase
            Layout.minimumWidth: 130
        }

        TextBody {
            style: TextBody.Base
            id: enabled_value
            text: qsTr("ENABLED")
            font.weight: Font.Light
            font.capitalization: Font.AllUppercase
            Layout.minimumWidth: 130
        }

        TextBody {
            style: TextBody.Base
            id: endstop_value
            text: qsTr("ENDSTOP")
            font.weight: Font.Light
            font.capitalization: Font.AllUppercase
            Layout.minimumWidth: 130
        }

        TextBody {
            style: TextBody.Base
            id: position_value
            text: qsTr("POSITION")
            font.weight: Font.Light
            font.capitalization: Font.AllUppercase
            Layout.minimumWidth: 130
        }
    }
}
