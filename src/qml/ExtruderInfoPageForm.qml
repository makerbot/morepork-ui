import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

FlickableMenu {
    property bool extruderAStatsReady: bot.extruderAStatsReady
    property bool extruderBStatsReady: bot.extruderBStatsReady

    id: flickableExtruderInfo
    contentHeight: Math.max(extAInfo.height, extBInfo.height) + 35
    width: 800
    height: 440
    smooth: false
    anchors.topMargin: 35

    ExtruderInfoContents {
        id: extAInfo
        anchors.leftMargin: 32
        anchors.left: parent.left
        anchors.top: parent.top

        toolIdx: 0
        header: qsTr("A/1")
        extType: bot.getExtruderName(bot.extruderATypeStr)
        serial: bot.extruderASerial
        shortRetractCount: bot.extruderAShortRetractCount
        longRetractCount: bot.extruderALongRetractCount
        lifetimeDistance: bot.extruderAExtrusionTotalDistance
        extruderPresent: bot.extruderAPresent
        statsReady: bot.extruderAStatsReady
    }

    ExtruderInfoContents {
        id: extBInfo
        anchors.left: extAInfo.right
        anchors.leftMargin: 35
        anchors.top: parent.top

        toolIdx: 1
        header: qsTr("B/1")
        extType: bot.getExtruderName(bot.extruderBTypeStr)
        serial: bot.extruderBSerial
        shortRetractCount: bot.extruderBShortRetractCount
        longRetractCount: bot.extruderBLongRetractCount
        lifetimeDistance: bot.extruderBExtrusionTotalDistance
        extruderPresent: bot.extruderBPresent
        statsReady: bot.extruderBStatsReady
    }
}
