import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 400
    height: columnLayout.height

    Column {
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
