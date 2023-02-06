import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    property alias mainMenuIcon_print: mainMenuIcon_print
    property alias mainMenuIcon_material: mainMenuIcon_material
    property alias mainMenuIcon_settings: mainMenuIcon_settings
    smooth: false

    MainMenuIcon {
        id: mainMenuIcon_material
        y: 129
        smooth: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 0
        image.source: "qrc:/img/material_icon.png"
        textIconDesc.text: qsTr("MATERIAL")
    }

    MainMenuIcon {
        id: mainMenuIcon_print
        y: 129
        smooth: false
        anchors.horizontalCenter: mainMenuIcon_material.horizontalCenter
        anchors.horizontalCenterOffset: -232
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
            anchors.horizontalCenter: mainMenuIcon_material.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            scale: 0.3
            actionButton: false
            visible: !parent.imageVisible
        }
    }

    MainMenuIcon {
        id: mainMenuIcon_settings
        y: 129
        smooth: false
        anchors.horizontalCenter: mainMenuIcon_material.horizontalCenter
        anchors.horizontalCenterOffset: 232
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
}
