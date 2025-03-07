import QtQuick 2.12
import QtQuick.Layouts 1.9
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import ErrorTypeEnum 1.0

LoggingItem {
    itemName: "SunflowerUnpacking"
    anchors.fill: parent
    property bool lowering: false
    property alias continueButton: unpackingContentRightSide.buttonPrimary
    property alias unpackingPopup: unpackingPopup

    ContentLeftSide {
        id: unpackingContentLeftSide
        visible: true
        anchors.verticalCenter: parent.verticalCenter
    }

    ContentRightSide {
        id: unpackingContentRightSide
        visible: true
        anchors.verticalCenter: parent.verticalCenter
    }

    CustomPopup {
        id: unpackingPopup
        popupName: "UnpackingPopup"

        fullButtonText: qsTr("CONFIRM")
        leftButtonText: qsTr("CLOSE")
        rightButtonText: qsTr("CONFIRM")

        Column {
            width: parent.popupWidth
            height: children.height
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: -25

            TextHeadline {
                id: unpackingPopupHeader
                width: unpackingPopup.popupWidth
                style: TextHeadline.Base
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 7
            }

            TextBody {
                id: unpackingPopupBody
                width: unpackingPopup.popupWidth
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 30
            }
        }
    }


    property int currentState: bot.process.stateType
    onCurrentStateChanged: {
        if (bot.process.type == ProcessType.MoveBuildPlateProcess) {
            switch(currentState) {
            case ProcessStateType.Cancelling:
                state = "move_paused"
                break;
            case ProcessStateType.CleaningUp:
               if (!bot.process.cancelled) {
                   if (lowering) {
                       fre.gotoNextStep(currentFreStep)
                   } else {
                       state = "remove_box_2"
                   }
               }
               break;
            default:
                break;
            }
        }
    }

    states: [
        State {
            name: "remove_box_1"

            PropertyChanges {
                target: unpackingPopup
                visible: false
            }

            PropertyChanges {
                target: unpackingPopupHeader
                text: ""
            }

            PropertyChanges {
                target: unpackingContentRightSide.textHeader
                text: qsTr("REMOVE BOX 1 + PACKAGING")
                visible: true
            }

            PropertyChanges {
                target: unpackingContentRightSide.textBody
                text: qsTr("The build plate will lift in the following step.") + "\n\n" +
                      qsTr("Confirm BOX 1 and packaging is removed and close the door before proceeding.") + "\n\n" +
                      qsTr("BOX 1 contains your material case and guide tubes.")
                visible: true
            }

            PropertyChanges {
                target: unpackingContentRightSide.buttonPrimary
                text: qsTr("CONFIRM")
                visible: true
            }

            PropertyChanges {
                target: unpackingContentLeftSide.image
                source: "qrc:/img/remove_upper_material.png"
                visible: true
            }

            PropertyChanges {
                target: unpackingContentLeftSide.processStatusIcon
                visible: false
            }
        },
        State {
            name: "confirm"

            PropertyChanges {
                target: unpackingPopup
                visible: true
                showOneButton: false
                showTwoButtons: true
            }

            PropertyChanges {
                target: unpackingPopupHeader
                text: qsTr("CONFIRM PACKAGING IS REMOVED")
            }

            PropertyChanges {
                target: unpackingPopupBody
                visible: false
            }
        },
        State {
            name: "close_door"

            PropertyChanges {
                target: unpackingPopup
                visible: true
                showOneButton: true
                showTwoButtons: false
            }

            PropertyChanges {
                target: unpackingPopupHeader
                text: qsTr("FRONT DOOR OPEN")
            }

            PropertyChanges {
                target: unpackingPopupBody
                text: qsTr("Close the front door to proceed.")
                visible: true
            }
        },
        State {
            name: "moving"

            PropertyChanges {
                target: unpackingPopup
                visible: false
            }

            PropertyChanges {
                target: unpackingPopupHeader
                text: ""
            }

            PropertyChanges {
                target: unpackingContentRightSide.textHeader
                text: lowering? qsTr("LOWERING BUILD PLATE")
                              : qsTr("RAISING BUILD PLATE")
                visible: true
            }

            PropertyChanges {
                target: unpackingContentRightSide.textBody
                text: qsTr("Please wait.")
                visible: true
            }

            PropertyChanges {
                target: unpackingContentRightSide.buttonPrimary
                visible: false
            }

            PropertyChanges {
                target: unpackingContentLeftSide.image
                visible: false
            }

            PropertyChanges {
                target: unpackingContentLeftSide.processStatusIcon
                visible: true
            }
        },
        State {
            name: "move_paused"

            PropertyChanges {
                target: unpackingContentRightSide.textHeader
                text: qsTr("PROCEDURE PAUSED") + "\n\n" + qsTr("CLOSE PRINTER DOOR")
                visible: true
            }

            PropertyChanges {
                target: unpackingContentRightSide.textBody
                text: qsTr("Close the printer door to resume")
                visible: true
            }

            PropertyChanges {
                target: unpackingContentRightSide.buttonPrimary
                text: qsTr("RESUME")
                visible: true
            }

            PropertyChanges {
                target: unpackingContentLeftSide.image
                source: "qrc:/img/methodxl_error_close_door.png"
                visible: true
            }

            PropertyChanges {
                target: unpackingContentLeftSide.processStatusIcon
                visible: false
            }
        },
        State {
            name: "remove_box_2"

            PropertyChanges {
                target: unpackingPopup
                visible: false
            }

            PropertyChanges {
                target: unpackingPopupHeader
                text: ""
            }

            PropertyChanges {
                target: unpackingContentRightSide.textHeader
                text: qsTr("REMOVE BOX 2")
                visible: true
            }

            PropertyChanges {
                target: unpackingContentRightSide.textBody
                text: qsTr("Remove BOX 2 from underneath the build plate, as well as any excess packaging and close the chamber.") + "\n\n" +
                      qsTr("BOX 2 contains your extruders and additional accessories.")
                visible: true
            }

            PropertyChanges {
                target: unpackingContentRightSide.buttonPrimary
                text: qsTr("NEXT")
                visible: true
            }

            PropertyChanges {
                target: unpackingContentLeftSide.image
                source: "qrc:/img/remove_lower_material.png"
                visible: true
            }

            PropertyChanges {
                target: unpackingContentLeftSide.processStatusIcon
                visible: false
            }
        }
    ]
}
