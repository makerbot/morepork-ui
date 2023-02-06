import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: item_root
    width: Math.max(textIconDesc.width + 20, 200)
    height: 200
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
            source: "qrc:/qtquickplugin/images/template_image.png"
            x: 38
            smooth: false
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            visible: imageVisible
            width: sourceSize.width
            height: sourceSize.height
        }

        TextBody {
            style: TextBody.ExtraLarge
            font.weight: Font.Light
            id: textIconDesc
            x: 52
            color: "#a0a0a0"
            text: qsTr("Icon Name")
            anchors.top: parent.top
            anchors.topMargin: 153
            antialiasing: false
            smooth: false
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
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
