import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    property alias spoolAInfo: spoolAInfo
    property alias spoolBInfo: spoolBInfo

    property bool initialized: false

    id: spoolInfo
    anchors.fill: parent
    anchors.leftMargin: 40
    anchors.rightMargin: 40

    /*
    RoundedButton {
        id: roundedButton
        x: 645
        y: 288
        buttonWidth: 120
        buttonHeight: 120
        button_text.visible: false
        Image {
            id: img
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/img/refresh.png"
            width: sourceSize.width
            height: sourceSize.height
        }

        button_mouseArea.onClicked: {
            bot.query_status()
        }

        button_mouseArea.onPressed: {
            img.source = "qrc:/img/refresh_black.png"
        }

        button_mouseArea.onReleased: {
            img.source = "qrc:/img/refresh.png"
        }

    }
    */

    RowLayout {
        anchors.fill: parent

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
