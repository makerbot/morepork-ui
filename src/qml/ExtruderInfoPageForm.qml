import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

FlickableMenu {
    id: flickableExtruderInfo
    contentHeight: contents.height + 35
    width: 800
    height: 440
    smooth: false
    anchors.topMargin: 35

    RowLayout {
        id: contents
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 32

        ExtruderInfoContents {
            id: extAInfo
            Layout.alignment: Qt.AlignTop

            toolIdx: 0
            header: qsTr("A/1")
            extType: bot.getExtruderName(bot.extruderATypeStr)
            serial: bot.extruderASerial
            shortRetractCount: bot.extruderAShortRetractCount
            longRetractCount: bot.extruderALongRetractCount
            lifetimeDistance: bot.extruderAExtrusionTotalDistance
        }

        ExtruderInfoContents {
            id: extBInfo
            Layout.alignment: Qt.AlignTop

            toolIdx: 1
            header: qsTr("B/1")
            extType: bot.getExtruderName(bot.extruderBTypeStr)
            serial: bot.extruderBSerial
            shortRetractCount: bot.extruderBShortRetractCount
            longRetractCount: bot.extruderBLongRetractCount
            lifetimeDistance: bot.extruderBExtrusionTotalDistance
        }
    }
}
