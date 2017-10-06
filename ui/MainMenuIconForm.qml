import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    id: item_root
    width: 150
    height: 150
    property alias mouseArea: mouseArea
    property alias image: image
    property alias text_iconDesc: text_iconDesc

    Image {
        id: image
        x: 38
        width: 100
        height: 100
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        Layout.maximumHeight: 125
        Layout.maximumWidth: 125
        Layout.fillHeight: false
        Layout.fillWidth: false
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        source: "qrc:/qtquickplugin/images/template_image.png"
    }

    Text {
        id: text_iconDesc
        x: 52
        color: "#a0a0a0"
        text: qsTr("Icon Name")
        font.family: "Antenna"
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: image.bottom
        anchors.topMargin: 10
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 20
    }

    MouseArea {
        id: mouseArea
        anchors.rightMargin: -125
        anchors.leftMargin: -125
        anchors.bottomMargin: -140
        anchors.top: image.bottom
        anchors.right: image.left
        anchors.bottom: image.top
        anchors.left: image.right
        anchors.topMargin: -110
    }
}
