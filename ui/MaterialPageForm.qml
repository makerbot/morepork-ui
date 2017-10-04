import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.8

MenuTemplateForm {
    property alias filamentVideo: filamentVideo
    image_drawerArrow.visible: false

    Video {
        id: filamentVideo
        z: 3
        loops: 1000
        anchors.right: parent.right
        anchors.rightMargin: (800-((800/480)*440))/2
        anchors.left: parent.left
        anchors.leftMargin: (800-((800/480)*440))/2
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.bottom: parent.bottom
        autoLoad: true
        autoPlay: true
        source: "qrc:/vid/filament_installation.m4v"
    }
}
