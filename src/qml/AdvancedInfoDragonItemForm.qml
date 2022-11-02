import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 400
    height: 128

    ColumnLayout {
        id: columnLayout
        width: parent.width
        spacing: 43

        TextHeadline {
            style: TextHeadline.Large
            id: heading
            text: qsTr("HEATING SYSTEM")
        }

        AdvancedInfoElement {
            id: stateStrProperty
            label: qsTr("STATE")
            value_anchors.leftMargin: -100
            value: bot.infoHeatSysStateStr
       }

        AdvancedInfoElement {
            id: errorStrProperty
            label: qsTr("ERROR")
            value_anchors.leftMargin: -100
            value: bot.infoHeatSysErrorStr
        }
    }
}
