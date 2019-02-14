import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import ProcessStateTypeEnum 1.0

Drawer {
    objectName: "printingDrawer"
    edge: rootItem.rotation == 180 ? Qt.BottomEdge : Qt.TopEdge
    width: parent.width
    height: column.height
    dim: false
    interactive: false
    background:
        Rectangle {
            rotation: rootItem.rotation == 180 ? 180 : 0
            opacity: 0.9
            smooth: false
            gradient: Gradient {
                      GradientStop { position: 0.0; color: "#00000000" }
                      GradientStop { position: 0.08; color: "#00000000" }
                      GradientStop { position: 0.09; color: "#000000" }
                      GradientStop { position: 0.79; color: "#000000" }
                      GradientStop { position: 0.80; color: "#00000000" }
                  }
            }

    onPositionChanged: {
        if(position > 0.9) {
            topBar.backButton.visible = false
            topBar.imageDrawerArrow.rotation = 90
            topBar.text_printerName.color = "#ffffff"
        }
        else {
            if(mainSwipeView.currentIndex != 0) {
                topBar.backButton.visible = true
            }
            topBar.imageDrawerArrow.rotation = -90
            topBar.text_printerName.color = "#a0a0a0"
        }
    }

    property alias buttonCancelPrint: buttonCancelPrint
    property alias buttonPausePrint: buttonPausePrint
    property alias buttonChangeFilament: buttonChangeFilament
    property alias buttonClose: buttonClose

    Flickable {
        id: flickable
        smooth: false
        anchors.fill: parent
        rotation: rootItem.rotation

        Column {
            id: column
            smooth: false
            spacing: 1
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left

            Item {
                id: empty
                height: 40
                smooth: false
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
            }

            Rectangle {
                width: parent.width; height: 1; color: "#4d4d4d"
            }

            MoreporkButton {
                id: buttonPausePrint
                buttonText.text: {
                    switch(bot.process.stateType) {
                    case ProcessStateType.Printing:
                        qsTr("PAUSE PRINT") + cpUiTr.emptyStr
                        break;
                    case ProcessStateType.Paused:
                        qsTr("RESUME PRINT") + cpUiTr.emptyStr
                        break;
                    default:
                        "PAUSE PRINT"
                        break;
                    }
                }
                buttonImage.source: "qrc:/img/pause.png"
                disableButton:
                    !(bot.process.stateType == ProcessStateType.Paused ||
                     bot.process.stateType == ProcessStateType.Printing)
                buttonColor: "#000000"
                buttonPressColor: "#0a0a0a"
                height: 80
            }

            Rectangle {
                width: parent.width; height: 1; color: "#4d4d4d"
            }

            MoreporkButton {
                id: buttonCancelPrint
                buttonText.text: qsTr("CANCEL PRINT") + cpUiTr.emptyStr
                buttonImage.source: "qrc:/img/cancel.png"
                buttonColor: "#000000"
                buttonPressColor: "#0a0a0a"
                height: 80
            }

            Rectangle {
                width: parent.width; height: 1; color: "#4d4d4d"
            }

            MoreporkButton {
                id: buttonChangeFilament
                buttonText.text: qsTr("CHANGE MATERIAL") + cpUiTr.emptyStr
                buttonImage.source: "qrc:/img/change_filament.png"
                buttonColor: "#000000"
                buttonPressColor: "#0a0a0a"
                height: 80
                disableButton: !(bot.process.stateType == ProcessStateType.Printing ||
                                 bot.process.stateType == ProcessStateType.Paused) ||
                               inFreStep
            }

            Rectangle {
                width: parent.width; height: 1; color: "#4d4d4d"
            }

            MoreporkButton {
                id: buttonClose
                buttonText.text: qsTr("CLOSE") + cpUiTr.emptyStr
                buttonImage.source: "qrc:/img/close.png"
                buttonColor: "#000000"
                buttonPressColor: "#0a0a0a"
                height: 80
            }

            Rectangle {
                width: parent.width; height: 1; color: "#4d4d4d"
            }

            Rectangle {
                id: emptyItem
                width: parent.width
                height: 100
                color: "#000000"
                opacity: position/2
            }
        }
    }
}
