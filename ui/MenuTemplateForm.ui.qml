import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    id: item_mainMenu
    width: 800
    height: 480
    property alias image_drawerArrow: image_drawerArrow
    property alias backButton: backButton
    property alias mouseArea_topDrawer: mouseArea_topDrawer
    property alias mouseArea_back: mouseArea_back

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

    Text {
        id: text_printerName
        x: 325
        y: 10
        z: 2
        height: 19
        color: "#a0a0a0"
        text: bot.name // "PRINTIN TARATINO"
        verticalAlignment: Text.AlignTop
        anchors.horizontalCenterOffset: 0
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 20
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

    Image {
        id: image_drawerArrow
        height: 25
        anchors.left: text_printerName.right
        anchors.leftMargin: 10
        rotation: -90
        z: 1
        anchors.verticalCenterOffset: 0
        source: "qrc:/img/arrow_19pix.png"
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        anchors.verticalCenter: text_printerName.verticalCenter
        fillMode: Image.PreserveAspectFit

        MouseArea {
            id: mouseArea_topDrawer
            width: 40
            height: 60
            anchors.horizontalCenter: parent.horizontalCenter
            z: 2
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
