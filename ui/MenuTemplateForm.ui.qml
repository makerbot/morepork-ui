import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    id: item_mainMenu
    width: 800
    height: 480
    property alias mouseArea_topDrawerDown: mouseArea_topDrawerDown
    property alias text_printerName: text_printerName
    property alias image_drawerArrow: image_drawerArrow
    property alias mouseArea_back: mouseArea_back
    property alias backButton: backButton

    Rectangle {
        id: rectangle
        color: "#000000"
        z: -1
        anchors.fill: parent
    }

    Image {
        id: image_topFadeIn
        height: 100
        z: 1
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        source: "qrc:/img/top_fade.png"
    }

    Item {
        id: backButton
        width: 150
        height: 40
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 0
        z: 2

        MouseArea {
            id: mouseArea_back
            anchors.fill: parent
        }

        Image {
            id: image_backArrow
            y: 11
            height: 25
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 0
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            fillMode: Image.PreserveAspectFit
            source: "qrc:/img/arrow_19pix.png"
        }

        Text {
            id: text_back
            y: 9
            color: "#a0a0a0"
            text: qsTr("BACK")
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: image_backArrow.right
            anchors.leftMargin: 5
            font.pixelSize: 20
        }
    }

    Item {
        id: item_printerName
        height: 40
        z: 1
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left

        Text {
            id: text_printerName
            color: "#a0a0a0"
            text: bot.name
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 20
        }

        Image {
            id: image_drawerArrow
            y: 227
            height: 25
            anchors.left: text_printerName.right
            anchors.leftMargin: 10
            anchors.verticalCenter: text_printerName.verticalCenter
            rotation: -90
            z: 1
            source: "qrc:/img/arrow_19pix.png"
            fillMode: Image.PreserveAspectFit

            MouseArea {
                id: mouseArea_topDrawerDown
                width: 40
                height: 60
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                z: 2
            }
        }
    }
}
