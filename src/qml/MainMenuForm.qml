import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0

Item {
    property alias mainMenuIcon_info: mainMenuIcon_info
    property alias mainMenuIcon_preheat: mainMenuIcon_preheat
    property alias mainMenuIcon_material: mainMenuIcon_material
    property alias mainMenuIcon_print: mainMenuIcon_print
    property alias mainMenuIcon_extruder: mainMenuIcon_extruder
    property alias mainMenuIcon_settings: mainMenuIcon_settings
    smooth: false
    MainMenuIcon {
        id: mainMenuIcon_print
        y: 40
        smooth: false
        anchors.horizontalCenterOffset: -220
        anchors.horizontalCenter: mainMenuIcon_extruder.horizontalCenter
        image.source: "qrc:/img/print_icon.png"
        imageVisible: !(bot.process.type == ProcessType.Print)
        textIconDesc.text: "PRINT"

        PrintIcon {
            smooth: false
            anchors.verticalCenterOffset: -25
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            scale: 0.3
            actionButton: false
            visible: !parent.imageVisible
        }
    }

    MainMenuIcon {
        id: mainMenuIcon_extruder
        y: 40
        smooth: false
        anchors.horizontalCenter: parent.horizontalCenter
        image.source: "qrc:/img/extruder_icon.png"
        textIconDesc.text: "EXTRUDERS"
    }

    MainMenuIcon {
        id: mainMenuIcon_settings
        y: 40
        smooth: false
        anchors.horizontalCenterOffset: 220
        anchors.horizontalCenter: mainMenuIcon_extruder.horizontalCenter
        image.source: "qrc:/img/settings_icon.png"
        textIconDesc.text: "SETTINGS"

        Image {
            id: image
            width: sourceSize.width
            height: sourceSize.height
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 75
            anchors.right: parent.right
            anchors.rightMargin: 35
            source: "qrc:/img/alert.png"
            visible: isfirmwareUpdateAvailable
        }
    }

    MainMenuIcon {
        id: mainMenuIcon_info
        y: 220
        smooth: false
        anchors.horizontalCenter: mainMenuIcon_print.horizontalCenter
        image.source: "qrc:/img/info_icon.png"
        textIconDesc.text: "INFO"
    }

    MainMenuIcon {
        id: mainMenuIcon_material
        y: 220
        smooth: false
        anchors.horizontalCenter: parent.horizontalCenter
        image.source: "qrc:/img/material_icon.png"
        textIconDesc.text: "MATERIAL"
    }

    MainMenuIcon {
        id: mainMenuIcon_preheat
        y: 220
        smooth: false
        anchors.horizontalCenter: mainMenuIcon_settings.horizontalCenter
        image.source: "qrc:/img/preheat_icon.png"
        textIconDesc.text: "PREHEAT"
    }
}
