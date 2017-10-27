import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    property alias mainMenuIcon_info: mainMenuIcon_info
    property alias mainMenuIcon_preheat: mainMenuIcon_preheat
    property alias mainMenuIcon_material: mainMenuIcon_material
    property alias mainMenuIcon_print: mainMenuIcon_print
    property alias mainMenuIcon_extruder: mainMenuIcon_extruder
    property alias mainMenuIcon_settings: mainMenuIcon_settings

    MainMenuIcon {
        id: mainMenuIcon_print
        z: 2
        anchors.bottom: mainMenuIcon_extruder.bottom
        anchors.bottomMargin: 0
        anchors.horizontalCenterOffset: -220
        anchors.horizontalCenter: mainMenuIcon_extruder.horizontalCenter
        image.source: "qrc:/img/print_icon.png"
        textIconDesc.text: "PRINT"
    }

    MainMenuIcon {
        id: mainMenuIcon_extruder
        y: parent.height*0.15
        z: 2
        anchors.horizontalCenter: parent.horizontalCenter
        image.source: "qrc:/img/extruder_icon.png"
        textIconDesc.text: "EXTRUDER"
    }

    MainMenuIcon {
        id: mainMenuIcon_settings
        z: 2
        anchors.horizontalCenterOffset: 220
        anchors.horizontalCenter: mainMenuIcon_extruder.horizontalCenter
        anchors.bottom: mainMenuIcon_extruder.bottom
        anchors.bottomMargin: 0
        image.source: "qrc:/img/settings_icon.png"
        textIconDesc.text: "SETTINGS"
    }

    MainMenuIcon {
        id: mainMenuIcon_info
        z: 2
        anchors.horizontalCenter: mainMenuIcon_print.horizontalCenter
        anchors.bottom: mainMenuIcon_material.bottom
        anchors.bottomMargin: 0
        image.source: "qrc:/img/info_icon.png"
        textIconDesc.text: "INFO"
    }

    MainMenuIcon {
        id: mainMenuIcon_material
        y: parent.height*0.525
        z: 2
        anchors.horizontalCenter: parent.horizontalCenter
        image.source: "qrc:/img/material_icon.png"
        textIconDesc.text: "MATERIAL"
    }

    MainMenuIcon {
        id: mainMenuIcon_preheat
        z: 2
        anchors.horizontalCenter: mainMenuIcon_settings.horizontalCenter
        anchors.bottom: mainMenuIcon_material.bottom
        anchors.bottomMargin: 0
        image.source: "qrc:/img/preheat_icon.png"
        textIconDesc.text: "PREHEAT"
    }
}
