import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: parent.width
    implicitHeight: columnLayout.height

    Column {
        id: columnLayout
        width: parent.width
        spacing: 25

        TextHeadline {
            style: TextHeadline.Large
            id: heading
            text: qsTr("HEATING")
            font.letterSpacing: 10
            width: parent.width
        }

        AdvancedInfoElement {
            id: stateStrProperty
            label: qsTr("STATE")
            value: bot.infoHeatSysStateStr
            width: 400
        }

        AdvancedInfoElement {
            id: errorStrProperty
            label: qsTr("ERROR")
            value: bot.infoHeatSysErrorStr
            width: 400
        }
    }
}
