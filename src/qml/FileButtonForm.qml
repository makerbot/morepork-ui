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
    property color buttonColor: "#050505"
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
        height: 120
        asynchronous: true
        anchors.left: parent.left
        anchors.leftMargin: 35
        anchors.verticalCenter: parent.verticalCenter
        smooth: false
        antialiasing: false
        fillMode: Image.PreserveAspectFit
    }

    ColumnLayout {
        id: columnLayout
        width: 100
        height: 50
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 175

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
        }

        RowLayout {
            id: fileDesc_rowLayout
            spacing: 10

            Text{
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
