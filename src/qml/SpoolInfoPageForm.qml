import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    property alias spoolAInfo: spoolAInfo
    property alias spoolBInfo: spoolBInfo

    property bool initialized: false

    id: spoolInfo
    width: 800
    height: 440

    RefreshButton {
        enabled: (bot.spoolAUpdateFinished && bot.spoolBUpdateFinished)
        button_mouseArea.onClicked: { }
        busy: !enabled
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 40

        SpoolInfoColumn {
            id: spoolAInfo
            index: 0
            anchors.top: parent.top
        }

        SpoolInfoColumn {
            id: spoolBInfo
            index: 1
            anchors.top: parent.top
        }
    }
}
