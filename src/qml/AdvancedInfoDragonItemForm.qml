import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 800
    height: 128

    ColumnLayout {
        id: columnLayout
        width: parent.width
        spacing: 50

        TextHeadline {
            style: TextHeadline.Large
            id: heading
            text: qsTr("HEATING SYSTEM")
            font.letterSpacing: 10
        }

        AdvancedInfoElement {
            id: stateStrProperty
            label: qsTr("STATE")
            value: bot.infoHeatSysStateStr
        }

        AdvancedInfoElement {
            id: errorStrProperty
            label: qsTr("ERROR")
            value: bot.infoHeatSysErrorStr
        }
    }
}
