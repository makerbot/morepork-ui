import QtQuick 2.10
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
    property var metaData
    property bool hasMeta: false
    property  bool metaCached: false

    background:
        Rectangle {
        anchors.fill: parent
        opacity: fileButton.down ? 1 : 0
        color: fileButton.down ? buttonPressColor : buttonColor
        smooth: false
    }

    Rectangle {
        color: "#4d4d4d"
        width: parent.width
        height: 1
        anchors.top: parent.bottom
        anchors.topMargin: 0
        smooth: false
    }

    ThumbnailImage {
        id: fileThumbnail
        width: 140
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
        anchors.leftMargin: 188

        Text {
            id: filenameText
            width: 525
            text: qsTr("Filename Text")
            font.family: defaultFont.name
            font.letterSpacing: 3
            font.weight: Font.Bold
            font.pointSize: 14
            color: "#ffffff"
            horizontalAlignment: Text.AlignLeft
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
                text: qsTr("File Print Time")
                font.family: defaultFont.name
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
                text: qsTr("File Material")
                font.capitalization: Font.AllUppercase
                font.family: defaultFont.name
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
        id: materialErrorAlertIcon
        height: 28
        width: 28
        anchors.right: parent.right
        anchors.rightMargin: 54
        anchors.verticalCenter: parent.verticalCenter
        antialiasing: false
        smooth: false
        source: "qrc:/img/circle_alert_112px.png"
        visible: false
    }

    Image {
        id: image
        height: 20
        width: 10
        anchors.right: parent.right
        anchors.rightMargin: 21
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/forward_arrow_42_80px.png"
    }

    Component.onCompleted: {
        this.onClicked.connect(logClick)
    }

    function logClick() {
        console.info("fileButton: [" + filenameText.text + "] clicked")
    }

}
