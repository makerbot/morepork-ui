import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

Item {
    width: 400
    height: 408
    smooth: false
    antialiasing: false

    // Debug flag to help with development; set to true to
    // view the layout in design view with all elements and
    // pick the ones you want when designing a new page.
    property bool showAllElements: false
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        visible: showAllElements
    }

    property alias animatedImage: animatedImage
    property alias image: image
    property alias processStatusIcon: processStatusIcon

    anchors.left: parent.left
    anchors.bottom: parent.bottom

    LinearGradient {
        z: 1
        rotation: -90
        width: parent.height
        height: 90
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: parent.width/2 - height/2
        anchors.verticalCenter: parent.verticalCenter
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 1.0; color: "#000000" }
        }
        visible: animatedImage.visible || image.visible
        cached: true
    }

    AnimatedImage {
        id: animatedImage
        width: sourceSize.width
        height: sourceSize.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: ""
        cache: false
        playing: visible
        smooth: false
        visible: false || showAllElements
    }

    Image {
        id: image
        width: sourceSize.width
        height: sourceSize.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/broken.png"
        visible: false || showAllElements
    }

    ProcessStatusIcon {
        id: processStatusIcon
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        visible: false || showAllElements
        processStatus: ProcessStatusIcon.Loading
    }
}
