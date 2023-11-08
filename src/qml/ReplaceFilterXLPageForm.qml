import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import ExtruderTypeEnum 1.0
import MachineTypeEnum 1.0

Item {
    id: replaceFilterXLPage
    width: parent.width
    height: parent.height
    smooth: false

    property alias contentLeftSide: contentLeftSide
    property alias contentRightSide: contentRightSide
    property alias itemReplaceFilterXL: itemReplaceFilter
    property alias replaceFilterXLPopup : replaceFilterPopup
    property alias replace_filter_next_button: contentRightSide.buttonPrimary
    property bool isBuildPlateRaised: false
    property bool replaceFilterProcess: false
    property bool flagCancel: false

    LoggingItem {
        itemName: "ReplaceFilterXL"
        id: itemReplaceFilter
        width: parent.width
        height: parent.height
        anchors.fill: parent.fill
        smooth: false
        visible: true

        ContentLeftSide {
            id: contentLeftSide
            visible: true
            image {
                source: "qrc:/img/clean_air_start.png"
                visible: true
            }
            loadingIcon {
                icon_image: LoadingIcon.Loading
                visible: false
            }
        }

        property int currentState: bot.process.stateType
        onCurrentStateChanged: {

            if (replaceFilterProcess &&
                    bot.process.type == ProcessType.MoveBuildPlateProcess) {
                switch(currentState) {
                case ProcessStateType.Cancelling:
                    replaceFilterPopup.popupState = "end_process"
                    replaceFilterPopup.open()
                    break;
                case ProcessStateType.CleaningUp:
                   if (!bot.process.cancelled) {
                        if(isBuildPlateRaised) {
                            settingsSwipeView.swipeToItem(SettingsPage.CleanAirSettingsPage)
                            replaceFilterProcess = false
                            isBuildPlateRaised = false
                            state = "done"
                        }
                        else {
                            isBuildPlateRaised = true
                            state = "step_2"
                        }
                   }
                   break;
                default:
                    break;
                }
            }
        }

        ContentRightSide {
            id: contentRightSide
            visible: true
            textHeader {
                text: qsTr("Replace Filter")
                visible: true
            }
            textBody {
                text: qsTr("This procedure allows you to install new filters.")
                visible: true
            }
            numberedSteps {
                visible: false

            }

            buttonPrimary {
                text: qsTr("START")
                visible: true
                onClicked: {

                    if(itemReplaceFilter.state == "step_2") {
                        itemReplaceFilter.state = "step_3"
                    }
                    else if (itemReplaceFilter.state == "step_3") {
                        itemReplaceFilter.state = "step_4"
                    }
                    else if (itemReplaceFilter.state == "step_4") {
                        /*bot.resetFilterHours()
                        bot.hepaFilterPrintHours = 0
                        bot.hepaFilterChangeRequired = false*/
                        replaceFilterPopup.popupState = "end_process"
                        replaceFilterPopup.open()
                    }
                    else {
                        if(!isBuildPlateRaised) {
                            replaceFilterProcess = true
                            replaceFilterPopup.popupState = "start"
                            replaceFilterPopup.open()
                        } else {
                            itemReplaceFilter.state = "step_2"
                        }
                    }
                }
            }
        }

        states: [
            State {
                name: "moving_build_plate"

                PropertyChanges {
                    target: contentLeftSide.image
                    visible: false
                }

                PropertyChanges {
                    target: contentLeftSide.loadingIcon
                    visible: true
                }

                PropertyChanges {
                    target: contentRightSide.textHeader
                    text: isBuildPlateRaised ? qsTr("Lowering Build Plate") :
                                     qsTr("Raising Build Plate")
                }

                PropertyChanges {
                    target: contentRightSide.textBody
                    text: qsTr("Please wait.")
                    visible: true
                }

                PropertyChanges {
                    target: contentRightSide.numberedSteps
                    visible: false
                }

                PropertyChanges {
                    target: contentRightSide.buttonPrimary
                    visible: false
                }
            },
            State {
                name: "step_2"

                PropertyChanges {
                    target: contentLeftSide.image
                    source: "qrc:/img/clean_air_open.png"
                }

                PropertyChanges {
                    target: contentLeftSide.loadingIcon
                    visible: false
                }

                PropertyChanges {
                    target: contentRightSide.textHeader
                    text: qsTr("Remove Current Filters")
                }

                PropertyChanges {
                    target: contentRightSide.textBody
                    visible: false
                }

                PropertyChanges {
                    target: contentRightSide.numberedSteps
                    steps: [qsTr("Use the tab to disengage and open the filter housing."),
                        qsTr("Remove both carbon and HEPA filter")]
                    activeSteps: [true, true]
                    visible: true
                }

                PropertyChanges {
                    target: contentRightSide.buttonPrimary
                    text: qsTr("NEXT")
                }
            },
            State {
                name: "step_3"

                PropertyChanges {
                    target: contentLeftSide.image
                    source: "qrc:/img/clean_air_replace.png"
                }

                PropertyChanges {
                    target: contentLeftSide.loadingIcon
                    visible: false
                }

                PropertyChanges {
                    target: contentRightSide.textHeader
                    text: qsTr("Install New Filters")
                }

                PropertyChanges {
                    target: contentRightSide.textBody
                    visible: false
                }

                PropertyChanges {
                    target: contentRightSide.numberedSteps
                    steps: [qsTr("Place the carbon filter followed by HEPA filter in the pocket."),
                        qsTr("Hook and snap tab of filter cover into place.")]
                    activeSteps: [true, true]
                    visible: true
                }

                PropertyChanges {
                    target: contentRightSide.buttonPrimary
                    text: qsTr("NEXT")
                }
            },
            State {
                name: "step_4"

                PropertyChanges {
                    target: contentLeftSide.image
                    source: "qrc:/img/clean_air_start.png"
                }

                PropertyChanges {
                    target: contentLeftSide.loadingIcon
                    visible: false
                }

                PropertyChanges {
                    target: contentRightSide.textHeader
                    text: qsTr("Repeat On Other Side")
                }

                PropertyChanges {
                    target: contentRightSide.textBody
                    text: qsTr("Conduct the same procedure on the other side of the printer before finishing.")
                    visible: true
                }

                PropertyChanges {
                    target: contentRightSide.numberedSteps
                    visible: false
                }

                PropertyChanges {
                    target: contentRightSide.buttonPrimary
                    text: qsTr("CONFIRM + RESET")
                }
            }
        ]
    }

    CustomPopup {
        id: replaceFilterPopup
        popupName: "replaceFilterPopup"
        popupHeight: replaceFilterPopupColumnLayout.height + 145
        showOneButton: popupState == "close_door"
        showTwoButtons: popupState == "start" ||
                        popupState == "end_process"
        full_button_text: qsTr("CONFIRM")
        left_button_text: qsTr("BACK")
        right_button_text: qsTr("CONFIRM")

        property string popupState: "start"

        right_button.enabled: bot.chamberErrorCode != 48
        full_button.enabled: bot.chamberErrorCode != 48
        right_button.onClicked: {
            if(flagCancel) {
                // Cancel
                bot.cancel()
                flagCancel = false
            }

            if (bot.chamberErrorCode != 48 || bot.doorErrorDisabled) {
                itemReplaceFilter.state = "moving_build_plate"
                doMove()
                close()
            } else {
                popupState = "close_door"
            }
        }
        left_button.onClicked: {
            replaceFilterPopup.close()
        }
        full_button.onClicked: {
            if (bot.chamberErrorCode != 48 || bot.doorErrorDisabled) {
                itemReplaceFilter.state = "moving_build_plate"
                doMove()
                close()
            } else {
                popupState = "close_door"
            }
        }

        ColumnLayout {
            id: replaceFilterPopupColumnLayout
            height: children.height
            anchors.top: replaceFilterPopup.popupContainer.top
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Image{
                id: replaceFilterPopupImage
                source: "qrc:/img/popup_error.png"
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 10
            }

            TextHeadline {
                id: replaceFilterPopupHeader
                style: TextHeadline.Base
                text: qsTr("Clear Build Plate + Close Door")
                Layout.alignment: Qt.AlignHCenter
            }

            TextBody {
                id: replaceFilterPopupBody
                text: qsTr("Confirm the build plate is clear and the door is closed to proceed.")
                Layout.alignment: Qt.AlignHCenter
            }

            states: [
                State {
                    when: replaceFilterPopup.popupState == "start"

                    PropertyChanges {
                        target: replaceFilterPopupHeader
                        text: qsTr("Clear Build Plate + Close Door")
                    }

                    PropertyChanges {
                        target: replaceFilterPopupBody
                        text: qsTr("Confirm the build plate is clear and the door is closed to proceed.")
                    }
                },
                State {
                    when: replaceFilterPopup.popupState == "close_door"

                    PropertyChanges {
                        target: replaceFilterPopupHeader
                        text: qsTr("Front Door Open")
                    }

                    PropertyChanges {
                        target: replaceFilterPopupBody
                        text: qqsTr("Close the front door to proceed.")
                    }
                },
                State {
                    when: replaceFilterPopup.popupState == "end_process"

                    PropertyChanges {
                        target: replaceFilterPopupHeader
                        text: qsTr("End Process + Close Door")
                    }

                    PropertyChanges {
                        target: replaceFilterPopupBody
                        text: qsTr("Confirm you are done with the process and the door is closed to proceed.")
                    }
                }

            ]
        }
    }
}
