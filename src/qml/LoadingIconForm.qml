import QtQuick 2.10

Rectangle {
    id: loading_icon
    width: 250
    height: 250
    color: "#00000000"
    radius: 125
    border.width: 3
    border.color: "#484848"
    antialiasing: true
    smooth: true
    visible: true

    property alias loading: loading_icon.visible

    Image {
        id: inner_image
        width: 68
        height: 68
        smooth: false
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        source: "qrc:/img/loading_gears.png"
        visible: parent.visible

        RotationAnimator {
            target: inner_image
            from: 360000
            to: 0
            duration: 10000000
            running: parent.visible
        }
    }

    Image {
        id: outer_image
        width: 214
        height: 214
        smooth: false
        source: "qrc:/img/loading_rings.png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        visible: parent.visible

        RotationAnimator {
            target: outer_image
            from: 0
            to: 360000
            duration: 10000000
            running: parent.visible
        }
    }
}
