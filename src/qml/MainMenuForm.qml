import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    property alias mainMenuIcon_print: mainMenuIcon_print
    property alias mainMenuIcon_material: mainMenuIcon_material
    property alias mainMenuIcon_settings: mainMenuIcon_settings
    property string topBarTitle: qsTr("Home")

    smooth: false
    anchors.fill: parent

    RowLayout {
        id: mainMenuLayout
        spacing: 5
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -2
        anchors.horizontalCenter: parent.horizontalCenter

        MainMenuIcon {
            id: mainMenuIcon_print
            Layout.margins: 14
            Layout.alignment: Qt.AlignHCenter
            smooth: false
            imageVisible: !(bot.process.type == ProcessType.Print)
            image.source: "qrc:/img/print_icon.png"

            PrintIcon {
                smooth: false
                scale: 0.4
                actionButton: false
                visible: !parent.imageVisible
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -20
            }

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

        }

        MainMenuIcon {
            id: mainMenuIcon_material
            Layout.margins: 13
            Layout.alignment: Qt.AlignHCenter
            smooth: false
            image.source: "qrc:/img/material_icon.png"
            textIconDesc.text: qsTr("MATERIAL")

            Image {
                id: no_material_warning
                width: 30
                height: 30
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 75
                anchors.right: parent.right
                anchors.rightMargin: 35
                source: "qrc:/img/extruder_material_error.png"
                visible: !bot["extruderAPresent"] || !bot["extruderAFilamentPresent"]
            }
        }

        MainMenuIcon {
            id: mainMenuIcon_settings
            Layout.margins: 14
            Layout.alignment: Qt.AlignHCenter
            smooth: false
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
}
