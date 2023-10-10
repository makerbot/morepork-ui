import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.9
import ProcessStateTypeEnum 1.0

CustomDrawer {
    objectName: "printingDrawer"
    property string topBarTitle: qsTr("Manage Print")
    property alias buttonCancelPrint: buttonCancelPrint
    property alias buttonPausePrint: buttonPausePrint
    property alias buttonChangeFilament: buttonChangeFilament

    Column {
        id: column
        width: parent.width
        height: children.height
        smooth: false
        spacing: 0
        rotation: rootItem.rotation

        CloseDrawerItem {}

        DrawerButton {
            id: buttonPausePrint
            buttonText: {
                switch(bot.process.stateType) {
                case ProcessStateType.Printing:
                    qsTr("PAUSE PRINT")
                    break;
                case ProcessStateType.Paused:
                    qsTr("RESUME PRINT")
                    break;
                default:
                    qsTr("PAUSE PRINT")
                    break;
                }
            }
            buttonImage: {
                switch(bot.process.stateType) {
                case ProcessStateType.Printing:
                    "qrc:/img/drawer_pause.png"
                    break;
                case ProcessStateType.Paused:
                    "qrc:/img/drawer_resume.png"
                    break;
                default:
                    "qrc:/img/drawer_pause.png"
                    break;
                }
            }
            enabled: (bot.process.stateType == ProcessStateType.Paused ||
                      bot.process.stateType == ProcessStateType.Printing)
        }

        DrawerButton {
            id: buttonCancelPrint
            buttonText: qsTr("CANCEL PRINT")
            buttonImage: "qrc:/img/drawer_cancel.png"
        }

        DrawerButton {
            id: buttonChangeFilament
            buttonText: qsTr("CHANGE MATERIAL")
            buttonImage: "qrc:/img/drawer_change_material.png"
            enabled: (bot.process.stateType == ProcessStateType.Printing ||
                      bot.process.stateType == ProcessStateType.Paused) &&
                      !inFreStep
        }

        Rectangle {
            id: emptyItem
            width: parent.width
            height: 120
            color: "#000000"
        }
    }
}
