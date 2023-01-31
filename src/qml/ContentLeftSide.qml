import QtQuick 2.12
import QtQuick.Layouts 1.12

Item {
    width: 400
    height: 408

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
    property alias loadingIcon: loadingIcon

    anchors.left: parent.left
    anchors.bottom: parent.bottom

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

    LoadingIcon {
        id: loadingIcon
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        visible: false || showAllElements
        icon_image: LoadingIcon.Loading
    }
}
