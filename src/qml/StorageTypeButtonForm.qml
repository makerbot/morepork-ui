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
    property alias storageThumbnailSourceSize: storageThumbnail.sourceSize
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

        Item {
            id: storageThumbnailItem
            height: parent.height
            width: 188
            anchors.left: parent.left

            Image {
                id: storageThumbnail
                asynchronous: true
                smooth: false
                antialiasing: false
                // fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Item {
            id: columnLayout
            width: 100
            height: 50
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: storageThumbnailItem.right

            Text {
                id: storageNameText
                width: 525
                text: "Storage Name Text"
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
                    text: "Storage Description"
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
            text: qsTr("%1\% AVAILABLE").arg(100-storageUsed)
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
            height: 20
            width: 10
            anchors.right: parent.right
            anchors.rightMargin: 21
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/img/forward_arrow_42_80px.png"
        }
    }

    Component.onCompleted: {
        this.onReleased.connect(uiLogSTBtn)
    }

    function uiLogSTBtn() {
        console.info("STB [=" + storageName + "=] clicked")
    }

}
