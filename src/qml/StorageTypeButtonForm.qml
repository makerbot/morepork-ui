import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Button {
    id: storageTypeButton
    width: parent.width
    height: 120
    smooth: false
    spacing: 0
    anchors.right: parent.right
    anchors.left: parent.left
    property alias storageName: storageNameText.text
    property alias storageThumbnail: storageThumbnail
    property alias storageDescription: storageDescriptionText.text
    property real storageUsed: 0.0
    property color buttonColor: "#00000000"
    property color buttonPressColor: "#0f0f0f"
    enabled: true

    background:
        Rectangle {
        anchors.fill: parent
        opacity: storageTypeButton.down ? 1 : 0
        color: storageTypeButton.down ? buttonPressColor : buttonColor
        smooth: false
    }

    Rectangle {
        color: "#4d4d4d"
        width: parent.width
        height: 1
        anchors.top: parent.bottom
        anchors.topMargin: -1
        smooth: false
    }

    Item {
        id: contentItem
        anchors.fill: parent
        opacity: enabled ? 1.0 : 0.4

        Image {
            id: storageThumbnail
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
                id: storageNameText
                width: 525
                text: qsTr("Storage Name Text")
                font.family: "Antenna"
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
                anchors.topMargin: rowlayout.visible ? 0 : 15
            }

            RowLayout {
                id: rowlayout
                anchors.top: parent.top
                anchors.topMargin: 32
                spacing: 10

                Text {
                    id: storageDescriptionText
                    text: qsTr("Storage Description")
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
            id: materialErrorAlertIcon
            height: 20
            anchors.right: percentUsedText.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: 20
            antialiasing: false
            smooth: false
            source: "qrc:/img/alert.png"
            visible: (storageUsed >= 80.0)
        }

        Text {
            id: percentUsedText
            text: qsTr("%1\% USED").arg(storageUsed)
            font.family: "Antenna"
            font.letterSpacing: 3
            font.weight: Font.Light
            font.pointSize: 12
            color: "#ffffff"
            smooth: false
            antialiasing: false
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: image.left
            anchors.rightMargin: 15
            visible: enabled && storageUsed != 0.0
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

    Component.onCompleted: {
        this.onClicked.connect(uiLogSTBtn)
    }

    function uiLogSTBtn() {
        console.info("STB [=" + storageName + "=] clicked")
    }

}
