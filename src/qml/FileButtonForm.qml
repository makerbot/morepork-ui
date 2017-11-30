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
    property color buttonColor: "#050505"
    property color buttonPressColor: "#0f0f0f"

    background: Rectangle {
        opacity: 1
        color: fileButton.down ? buttonPressColor : buttonColor
        smooth: false
    }

    Image {
        id: fileThumbnail
        width: sourceSize.width
        height: sourceSize.height
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        smooth: false
        antialiasing: false
    }

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
        id: rowLayout
        width: 100
        height: 100

        Text{
            id: filePrintTime
            text: "Filename Text"
            font.family: "Antenna"
            font.letterSpacing: 3
            font.weight: Font.Light
            font.pointSize: 14
            color: "#ffffff"
            horizontalAlignment: Text.Left
            verticalAlignment: Text.Left
            smooth: false
            antialiasing: false

        }

        Text {
            id: fileMaterial
            text: "Filename Text"
            font.family: "Antenna"
            font.letterSpacing: 3
            font.weight: Font.Light
            font.pointSize: 14
            color: "#ffffff"
            horizontalAlignment: Text.Left
            verticalAlignment: Text.Left
            smooth: false
            antialiasing: false

        }

    }
}
