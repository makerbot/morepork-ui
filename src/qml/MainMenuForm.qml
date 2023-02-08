import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    anchors.fill: parent
    property alias mainMenuIcon_info: mainMenuIcon_info
    property alias mainMenuIcon_advanced: mainMenuIcon_advanced
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
        textIconDesc.text: {
            if(bot.process.type == ProcessType.Print) {
                switch(bot.process.stateType) {
                case ProcessStateType.Loading:
                case ProcessStateType.Printing:
                    qsTr("PRINTING")
                    break;
                case ProcessStateType.Pausing:
                    qsTr("PAUSING")
                    break;
                case ProcessStateType.Paused:
                    qsTr("PAUSED")
                    break;
                case ProcessStateType.Resuming:
                    qsTr("RESUMING")
                    break;
                case ProcessStateType.Completed:
                    qsTr("PRINT COMPLETE")
                    break;
                case ProcessStateType.Failed:
                    qsTr("PRINT FAILED")
                    break;
                default:
                    qsTr("PRINT")
                    break;
                }
            }
            else {
                qsTr("PRINT")
            }
        }

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
        Rectangle {
            id: filament_rectangle_left
            z: -1
            width: 22
            height: 50
            color: "#cbcbcb"
            smooth: false
            antialiasing: false
            anchors.verticalCenterOffset: -34
            anchors.horizontalCenterOffset: -20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            visible: bot.extruderAPresent && bot.extruderAFilamentPresent
        }
        Rectangle {
            id: filament_rectangle_right
            z: -1
            width: 10
            height: 40
            color: "#cbcbcb"
            smooth: false
            antialiasing: false
            anchors.verticalCenterOffset: -35
            anchors.horizontalCenterOffset: 8
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            visible: bot.extruderBPresent && bot.extruderBFilamentPresent
        }

        image.source: {
            if(bot.extruderAPresent && bot.extruderBPresent) {
                "qrc:/img/extruder_both.png"
            }
            else if(bot.extruderAPresent && !bot.extruderBPresent) {
                "qrc:/img/extruder_left.png"
            }
            else if(!bot.extruderAPresent && bot.extruderBPresent) {
                "qrc:/img/extruder_right.png"
            }
            else {
                "qrc:/img/extruder_none.png"
            }
        }
        textIconDesc.text: qsTr("EXTRUDERS")
    }

    MainMenuIcon {
        id: mainMenuIcon_settings
        y: 40
        smooth: false
        anchors.horizontalCenterOffset: 220
        anchors.horizontalCenter: mainMenuIcon_extruder.horizontalCenter
        image.source: "qrc:/img/settings_icon.png"
        textIconDesc.text: qsTr("SETTINGS")

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
        textIconDesc.text: qsTr("INFO")
    }

    MainMenuIcon {
        id: mainMenuIcon_material
        y: 220
        smooth: false
        anchors.horizontalCenter: parent.horizontalCenter
        image.source: "qrc:/img/material_icon.png"
        textIconDesc.text: qsTr("MATERIAL")
    }

    MainMenuIcon {
        id: mainMenuIcon_advanced
        y: 220
        smooth: false
        anchors.horizontalCenter: mainMenuIcon_settings.horizontalCenter
        image.source: "qrc:/img/advanced_icon.png"
        textIconDesc.text: qsTr("ADVANCED")
    }
}
