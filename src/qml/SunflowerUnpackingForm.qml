import QtQuick 2.12
import QtQuick.Layouts 1.9
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import ErrorTypeEnum 1.0

LoggingItem {
    itemName: "SunflowerUnpacking"
    anchors.fill: parent
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
        popupName: "unpackingPopup"

        full_button_text: qsTr("CONFIRM")
        left_button_text: qsTr("CLOSE")
        right_button_text: qsTr("CONFIRM")

        ColumnLayout {
            width: parent.width
            height: children.height
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: -25

            Image{
                source: "qrc:/img/popup_error.png"
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 10
            }

            TextHeadline {
                id: unpackingPopupHeader
                style: TextHeadline.Base
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 7
            }

            TextBody {
                id: unpackingPopupBody
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
                state = "raising_paused"
                break;
            case ProcessStateType.CleaningUp:
               if (!bot.process.cancelled) {
                   state = "remove_box_2"
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
                target: unpackingContentRightSide.textHeader
                text: qsTr("REMOVE BOX 1 + PACKAGING")
                visible: true
            }

            PropertyChanges {
                target: unpackingContentRightSide.textBody
                text: qsTr("The build plate will lift in the following step.\n\nConfirm BOX 1 and packaging is removed and close the door before proceeding.\n\nBOX 1 contains your material case and guide tubes.")
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
                target: unpackingContentLeftSide.loadingIcon
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
            name: "raising"

            PropertyChanges {
                target: unpackingContentRightSide.textHeader
                text: qsTr("RAISING BUILD PLATE")
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
                target: unpackingContentLeftSide.loadingIcon
                visible: true
            }
        },
        State {
            name: "raising_paused"

            PropertyChanges {
                target: unpackingContentRightSide.textHeader
                text: qsTr("PROCEDURE PAUSED\n\nCLOSE PRINTER DOOR")
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
                target: unpackingContentLeftSide.loadingIcon
                visible: false
            }
        },
        State {
            name: "remove_box_2"

            PropertyChanges {
                target: unpackingContentRightSide.textHeader
                text: qsTr("REMOVE BOX 2")
                visible: true
            }

            PropertyChanges {
                target: unpackingContentRightSide.textBody
                text: qsTr("Remove BOX 2 from underneath the build plate, as well as any excess packaging and close the chamber.\n\nBOX 2 contains your extruders and additional accessories.")
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
                target: unpackingContentLeftSide.loadingIcon
                visible: false
            }
        }
    ]
}
