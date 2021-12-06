import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: item_root
    width: Math.max(textIconDesc.width + 20, 180)
    height: 180
    smooth: false
    property alias mouseArea: mouseArea
    property alias image: image
    property alias textIconDesc: textIconDesc
    property bool imageVisible: true
    property bool isDisabled: false

    Rectangle {
        id: baseRectangle
        anchors.fill: parent
        color: "#00000000"
        radius: 10
        border.width: 2
        border.color: "#00000000"
        smooth: false
        antialiasing: false
        opacity: isDisabled ? 0.3 : 1

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
            text: qsTr("Icon Name")
            anchors.top: parent.top
            anchors.topMargin: 130
            antialiasing: false
            smooth: false
            font.family: defaultFont.name
            font.letterSpacing: 3
            font.weight: Font.Light
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 22
        }

        LoggingMouseArea {
            logText: "MMI [[" + textIconDesc.text + "]]"
            id: mouseArea
            anchors.fill: parent
            smooth: false
            enabled: !isDisabled

            onPressed: {
                baseRectangle.border.color = "#ffffff"
            }

            onReleased: {
                baseRectangle.border.color = "#00000000"
            }
        }
    }
}
