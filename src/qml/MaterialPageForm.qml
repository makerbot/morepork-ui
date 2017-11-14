import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.8

Item {
    property alias filamentVideo: filamentVideo
    property alias defaultItem: tempItem
    smooth: false

    Item {
        id: tempItem
        property var backSwiper: mainSwipeView
        property int backSwipeIndex: 0
        smooth: false
    }

    Video {
        id: filamentVideo
        smooth: false
        z: 3
        loops: MediaPlayer.Infinite
        anchors.right: parent.right
        anchors.rightMargin: (800-((800/480)*440))/2
        anchors.left: parent.left
        anchors.leftMargin: (800-((800/480)*440))/2
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.bottom: parent.bottom
        autoLoad: true
        autoPlay: false
        source: mainSwipeView.rotation == 180 ? "" : "qrc:/vid/filament_installation.m4v"
    }
}
