import QtQuick 2.10

Item {
    id: item1
    anchors.fill: parent

    Image {
        id: image
        width: sourceSize.width
        height: sourceSize.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/makerbot_startup_splash.png"
    }
}
