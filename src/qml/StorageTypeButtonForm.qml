import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Button {
    id: storageTypeButton
    width: parent.width
    height: 100
    smooth: false
    spacing: 0
    anchors.right: parent.right
    anchors.left: parent.left
    property alias storageName: storageNameText.text
    property alias storageImage: storageTypeImage.source
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
        anchors.bottom: parent.bottom
        smooth: false
    }

    Item {
        id: contentItem
        anchors.fill: parent
        opacity: enabled ? 1.0 : 0.4

        Item {
            id: storageTypeImageContainer
            width: 160
            height: parent.height

            Image {
                id: storageTypeImage
                width: sourceSize.width
                height: sourceSize.height
                smooth: false
                antialiasing: false
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        ColumnLayout {
            id: storageNameDescriptionColumnLayout
            width: children.width
            height: children.height
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: storageTypeImageContainer.right

            TextBody {
                id: storageNameText
                style: TextBody.Large
                text: "Storage Name Text"
                verticalAlignment: Text.AlignVCenter
            }

            TextSubheader {
                id: storageDescriptionText
                text: "Storage Description"
                visible: text == "" ? false : true
                verticalAlignment: Text.AlignVCenter
            }
        }

        RowLayout {
            id: storageUsedRowLayout
            width: children.width
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: openMenuItemImage.left
            anchors.rightMargin: 5

            Image {
                id: storageAlertIcon
                height: 20
                width: 20
                antialiasing: false
                smooth: false
                source: "qrc:/img/alert.png"
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                visible: (storageUsed >= 80.0)
            }

            TextSubheader {
                id: percentUsedText
                text: qsTr("%1\% AVAILABLE").arg(100-storageUsed)
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                visible: enabled && storageUsed != 0.0
            }
        }

        Image {
            id: openMenuItemImage
            width: sourceSize.width
            height: sourceSize.height
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/img/open_menu_item_arrow.png"
        }
    }

    Component.onCompleted: {
        this.onReleased.connect(uiLogSTBtn)
    }

    function uiLogSTBtn() {
        console.info("STB [=" + storageName + "=] clicked")
    }
}
