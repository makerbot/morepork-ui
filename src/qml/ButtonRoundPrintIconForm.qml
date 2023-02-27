import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle 
{
    id: action_circle
    property alias mouseArea: action_mouseArea
    property string image_source: "qrc:/img/pause.png"
    width: radius * 2
    height: radius * 2
    color: "#000000"
    radius: 40
    visible: true

    Image {
        id: action_image
        width: parent.width
        height: parent.height
        smooth: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: image_source
    }

    LoggingMouseArea {
        logText: "printing - action_circle: [?action image?]"
        id: action_mouseArea
        smooth: false
        anchors.fill: parent
    }   
}