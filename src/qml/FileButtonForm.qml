import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Button {
    id: fileButton
    width: parent.width
    height: 120
    smooth: false
    spacing: 0
    anchors.right: parent.right
    anchors.left: parent.left
    property alias filenameText: filenameText
    property alias fileThumbnail: fileThumbnail
    property alias fileMaterial: fileMaterial
    property alias filePrintTime: filePrintTime
    property alias fileDesc_rowLayout: fileDesc_rowLayout
    property alias materialError: materialErrorAlertIcon
    property color buttonColor: "#00000000"
    property color buttonPressColor: "#0f0f0f"

    background:
        Rectangle {
        anchors.fill: parent
        opacity: fileButton.down ? 1 : 0
        color: fileButton.down ? buttonPressColor : buttonColor
        smooth: false
    }

    Image {
        id: fileThumbnail
        sourceSize.width: 140
        sourceSize.height: 106
        asynchronous: true
        smooth: false
        antialiasing: false
        fillMode: Image.PreserveAspectFit
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 25
    }

    Item {
        id: columnLayout
        width: 100
        height: 50
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 190

        Text {
            id: filenameText
            text: "Filename Text"
            font.family: "Antenna"
            font.letterSpacing: 3
            font.weight: Font.Bold
            font.pointSize: 14
            color: "#ffffff"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            smooth: false
            antialiasing: false
            anchors.top: parent.top
            anchors.topMargin: fileDesc_rowLayout.visible ? 0 : 15
        }

        RowLayout {
            id: fileDesc_rowLayout
            anchors.top: parent.top
            anchors.topMargin: 32
            spacing: 10

            Text {
                id: filePrintTime
                text: "File Print Time"
                font.family: "Antenna"
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pointSize: 12
                color: "#ffffff"
                horizontalAlignment: Text.Left
                verticalAlignment: Text.Left
                smooth: false
                antialiasing: false
            }

            Rectangle {
                id: divider
                width: 1
                height: 20
                color: "#ffffff"
                visible: fileMaterial.visible
            }

            Text {
                id: fileMaterial
                text: "File Material"
                font.capitalization: Font.AllUppercase
                font.family: "Antenna"
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pointSize: 12
                color: "#ffffff"
                horizontalAlignment: Text.Left
                verticalAlignment: Text.Left
                smooth: false
                antialiasing: false

                Image {
                    id: materialErrorAlertIcon
                    height: 20
                    anchors.left: parent.right
                    anchors.leftMargin: 7
                    anchors.verticalCenter: parent.verticalCenter
                    width: 20
                    antialiasing: false
                    smooth: false
                    source: "qrc:/img/alert.png"
                }
            }
        }
    }

    Image {
        id: image
        width: sourceSize.width
        height: sourceSize.height
        anchors.right: parent.right
        anchors.rightMargin: 20
        rotation: 180
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/arrow_19pix.png"
    }
}
