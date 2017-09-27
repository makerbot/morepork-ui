import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    id: item_mainMenu
    width: 800
    height: 480

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
        text: "PRINTIN TARATINO"
        verticalAlignment: Text.AlignTop
        anchors.horizontalCenterOffset: 0
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 20
    }

    Item {
        id: item1
        width: 150
        height: 40
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 0
        z: 2

        MouseArea {
            id: mouseArea
            anchors.fill: parent
        }

        Image {
            id: image
            y: 11
            height: 25
            anchors.left: parent.left
            anchors.leftMargin: 0
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            fillMode: Image.PreserveAspectFit
            source: "qrc:/img/arrow_19pix.png"
        }

        Text {
            id: text1
            y: 9
            color: "#a0a0a0"
            text: qsTr("BACK")
            anchors.left: image.right
            anchors.leftMargin: 5
            font.pixelSize: 20
        }
    }
}
