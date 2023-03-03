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
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#00000000"
        radius: 10
        border.width: 2
        border.color: "#00000000"
        smooth: false
        antialiasing: false
        opacity: isDisabled ? 0.3 : 1

        ColumnLayout {
            id:iconColumnLayout
            spacing: 19
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: image
                source: "qrc:/qtquickplugin/images/template_image.png"
                smooth: false
                Layout.alignment: Qt.AlignHCenter
                visible: imageVisible
                width: sourceSize.width
                height: sourceSize.height
            }

            TextBody {
                style: TextBody.ExtraLarge
                font.weight: Font.Light
                id: textIconDesc
                text: qsTr("Icon Name")
                antialiasing: false
                smooth: false
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
            }
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
