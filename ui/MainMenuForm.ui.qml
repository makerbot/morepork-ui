import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    id: item_mainMenu
    width: 800
    property alias mainMenuIcon_info: mainMenuIcon_info
    property alias mainMenuIcon_preheat: mainMenuIcon_preheat
    property alias mainMenuIcon_material: mainMenuIcon_material
    property alias mainMenuIcon_print: mainMenuIcon_print
    property alias mainMenuIcon_extruder: mainMenuIcon_extruder
    property alias mainMenuIcon_settings: mainMenuIcon_settings

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
        text: qsTr("PRINTIN TARATINO")
        verticalAlignment: Text.AlignTop
        anchors.horizontalCenterOffset: 0
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 20
    }

    MainMenuIcon {
        id: mainMenuIcon_print
        z: 2
        anchors.bottom: mainMenuIcon_extruder.bottom
        anchors.bottomMargin: 0
        anchors.horizontalCenterOffset: -220
        anchors.horizontalCenter: mainMenuIcon_extruder.horizontalCenter
        image.source: "qrc:/img/icon/print_icon.png"
        text_iconDesc.text: "PRINT"
    }

    MainMenuIcon {
        id: mainMenuIcon_extruder
        y: 80
        z: 2
        anchors.horizontalCenter: parent.horizontalCenter
        image.source: "qrc:/img/icon/extruder_icon.png"
        text_iconDesc.text: "EXTRUDER"
    }

    MainMenuIcon {
        id: mainMenuIcon_settings
        z: 2
        anchors.horizontalCenterOffset: 220
        anchors.horizontalCenter: mainMenuIcon_extruder.horizontalCenter
        anchors.bottom: mainMenuIcon_extruder.bottom
        anchors.bottomMargin: 0
        image.source: "qrc:/img/icon/settings_icon.png"
        text_iconDesc.text: "SETTINGS"
    }

    MainMenuIcon {
        id: mainMenuIcon_info
        z: 2
        anchors.horizontalCenter: mainMenuIcon_print.horizontalCenter
        anchors.bottom: mainMenuIcon_material.bottom
        anchors.bottomMargin: 0
        image.source: "qrc:/img/icon/info_icon.png"
        text_iconDesc.text: "INFO"
    }

    MainMenuIcon {
        id: mainMenuIcon_material
        y: 250
        z: 2
        anchors.horizontalCenter: parent.horizontalCenter
        image.source: "qrc:/img/icon/material_icon.png"
        text_iconDesc.text: "MATERIAL"
    }

    MainMenuIcon {
        id: mainMenuIcon_preheat
        z: 2
        anchors.horizontalCenter: mainMenuIcon_settings.horizontalCenter
        anchors.bottom: mainMenuIcon_material.bottom
        anchors.bottomMargin: 0
        image.source: "qrc:/img/icon/preheat_icon.png"
        text_iconDesc.text: "PREHEAT"
    }
}
