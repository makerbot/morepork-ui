import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    id: item_root
    width: 180
    height: 180
    smooth: false
    property alias mouseArea: mouseArea
    property alias image: image
    property alias textIconDesc: textIconDesc
    property bool imageVisible: true

    Rectangle {
        id: baseRectangle
        anchors.fill: parent
        color: "#00000000"
        radius: 10
        border.width: 2
        border.color: "#00000000"
        smooth: false
        antialiasing: false

        Image {
            id: image
            x: 38
            width: 75
            height: 75
            smooth: false
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/qtquickplugin/images/template_image.png"
            visible: imageVisible
        }

        Text {
            id: textIconDesc
            x: 52
            color: "#a0a0a0"
            text: "Icon Name"
            anchors.top: parent.top
            anchors.topMargin: 130
            antialiasing: false
            smooth: false
            font.family: "Antenna"
            font.letterSpacing: 3
            font.weight: Font.Light
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 22
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            smooth: false

            onPressed: {
                baseRectangle.border.color = "#ffffff"
            }

            onReleased: {
                baseRectangle.border.color = "#00000000"
            }
        }
    }
}
