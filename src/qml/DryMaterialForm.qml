import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

LoggingItem {
    itemName: "DryMaterial"
    id: dryMaterialPage
    width: parent.width
    height: parent.height
    smooth: false
    antialiasing: false
    property alias contentLeftSide: contentLeftSide
    property alias contentRightSide: contentRightSide
    property alias cancelDryingCyclePopup: cancelDryingCyclePopup
    property alias dryConfirmBuildPlateClearPopup: dryConfirmBuildPlateClearPopup
    property alias left_button: dryConfirmBuildPlateClearPopup.left_button
    property real timeLeftHours: bot.process.timeRemaining/3600
    property int currentStep: bot.process.stateType
    signal processDone
    property bool hasFailed: bot.process.errorCode !== 0
    property bool doChooseMaterial: false
    property bool hasFinished: false

    onCurrentStepChanged: {
        if(bot.process.type == ProcessType.DryingCycleProcess) {
            switch(currentStep) {
                case ProcessStateType.WaitingForSpool:
                    state = "dry_kit_instructions_1"
                    break;
                case ProcessStateType.Loading:
                case ProcessStateType.DryingSpool:
                    doChooseMaterial = false
                    state = "drying_spool"
                    break;
                case ProcessStateType.Done:
                    if(state != "cancelling" &&
                       state != "drying_failed" &&
                       state != "base state") {
                        state = "drying_complete"
                        hasFinished = true
                    }
                    break;
                case ProcessStateType.Cancelling:
                    state = "cancelling"
                    doChooseMaterial = false
                    hasFinished = false
                    break;
            }
        } else if(bot.process.type == ProcessType.None) {
            if(state == "cancelling") {
                processDone()
            }
        }
    }

    onHasFailedChanged: {
        if(bot.process.type == ProcessType.DryingCycleProcess) {
            state = "drying_failed"
            hasFinished = true
        }
    }

    property variant dryingMaterialsListMethod : [
        {label: "pva", temperature : 60, time : 24},
        {label: "nylon || nylon cf || nylon 12 cf || petg", temperature : 60, time : 24},
        {label: "pla || tough", temperature : 45, time : 24}
    ]

    property variant dryingMaterialsListMethodX : [
        {label: "sr30", temperature : 0, time : 0},
        {label: "pva", temperature : 70, time : 24},
        {label: "rapidrinse", temperature : 70, time : 24},
        {label: "nylon || nylon cf || nylon 12 cf", temperature : 70, time : 24},
        {label: "abs || asa || pc-abs || petg", temperature : 60, time : 24},
        {label: "pla || tough", temperature : 45, time : 24}
    ]

    property variant dryingMaterialsListMethodXL : [
        {label: "custom", temperature: 0, time: 0},
        {label: "abs-r", temperature: 60, time: 16},
        {label: "abs-cf", temperature: 60, time: 16},
        {label: "nylon cf", temperature: 70, time: 16},
        {label: "pva", temperature: 50, time: 16},
        {label: "rapidrinse", temperature: 70, time: 16},
        {label: "sr-30", temperature: 0, time: 0}
    ]

    ContentLeftSide {
        id: contentLeftSide
        image {
            source: "qrc:/img/dry_material.png"
            visible: true
        }
        loadingIcon {
            visible: false
        }
        visible: true
    }

    ContentRightSide {
        id: contentRightSide
        textHeader {
            text: qsTr("DRY MATERIAL")
            visible: true
        }
        textBody {
            text: qsTr("Material extrusion issues may be caused by moisture absorption by the filament. This procedure will allow you to dry materials for improved print quality, using METHOD’s built-in heaters Please sure the build plate is empty.")
            visible: true
        }
        buttonPrimary {
            text: qsTr("START")
            visible: true
        }
        visible: true
    }

    DryMaterialSelector {
        id: materialSelector
        height: parent.height
        width: parent.height
        visible: false
    }

    states: [
        State {
            name: "positioning_build_plate"
            when: bot.process.type == ProcessType.DryingCycleProcess &&
                  bot.process.stateType == ProcessStateType.PositioningBuildPlate

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    visible: false
                }
                loadingIcon {
                    visible: true
                    icon_image: LoadingIcon.Loading
                    loadingProgress: 0
                }
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
                textHeader {
                    text: qsTr("BUILD PLATE MOVING INTO PLACE")
                    visible: true
                }
                textBody {
                    text: qsTr("The build plate is moving into position so the material can be placed closer to the heaters.")
                    visible: true
                }
                buttonPrimary {
                    visible: false
                }
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },
        State {
            name: "dry_kit_instructions_1"

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    visible: true
                    source: "qrc:/img/replace_desiccant.png"
                }
                loadingIcon {
                    visible: false
                }
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
                textHeader {
                    text: qsTr("REPLACE DESICCANT")
                    visible: true
                }
                textBody {
                    text: qsTr("SPOOL TYPE A") + "\n" +
                          qsTr("Remove cap and insert one 70g bag") + "\n" +
                          qsTr("Re-attach cap to spool") + "\n\n" +
                          qsTr("SPOOL TYPE B") + "\n" +
                          qsTr("Remove puck from spool") + "\n" +
                          qsTr("Remove cap and insert one 30g bag") + "\n" +
                          qsTr("Re-attach cap and puck to spool")
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("NEXT")
                    visible: true
                }
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },
        State {
            name: "dry_kit_instructions_2"

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    source: "qrc:/img/spool_bag.png"
                    visible: true
                }
                loadingIcon {
                    visible: false
                }
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
                textHeader {
                    text: qsTr("PLACE SPOOL IN BAG")
                    visible: true
                }
                textBody {
                    text: qsTr("Confirm your re-usable Mylar storage bag has no holes.") + "\n\n" +
                          qsTr("Place spool in bag and add additional fresh bags of desiccant before sealing.") + "\n\n" +
                          qsTr("For additional mylar bags and desiccant, purchase the MATERIAL DRY KIT at store.makerbot.com")
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("NEXT")
                    visible: true
                }
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },
        State {
            name: "waiting_for_spool"

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    source: "qrc:/img/dry_material_spool.png"
                    visible: true
                }
                loadingIcon {
                    visible: false
                }
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
                textHeader {
                    text: qsTr("PLACE THE SEALED BAG ON BUILD PLATE")
                    visible: true
                }
                textBody {
                    text: qsTr("Position the material in the center of the build plate and close the build chamber door.")
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("SELECT MATERIAL")
                    visible: true
                }
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },
        State {
            name: "choose_material"
            when: doChooseMaterial

            PropertyChanges {
                target: contentLeftSide
                visible: false
            }

            PropertyChanges {
                target: contentRightSide
                visible: false
            }

            PropertyChanges {
                target: materialSelector
                visible: true
            }
        },
        State {
            name: "drying_spool"

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    visible: false
                }
                loadingIcon {
                    visible: true
                    icon_image: LoadingIcon.Loading
                    loadingProgress: bot.process.printPercentage
                }
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
                textHeader {
                    text: {
                        if(bot.process.stateType == ProcessStateType.Loading) {
                            qsTr("HEATING CHAMBER")
                        } else if(bot.process.stateType == ProcessStateType.DryingSpool) {
                            qsTr("DRYING MATERIAL")
                        } else {
                            defaultString
                        }
                    }
                    visible: true
                }
                textBody {
                    visible: bot.process.stateType == ProcessStateType.DryingSpool
                    text: {
                        (timeLeftHours < 1 ?
                             Math.round(timeLeftHours * 60) + "M " :
                             Math.round(timeLeftHours*10)/10 + "H ") +
                        qsTr("REMAINING")
                    }
                }
                buttonPrimary {
                    visible: false
                }
                temperatureStatus {
                    visible: true
                    showComponent: TemperatureStatus.Chamber
                }
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },
        State {
            name: "drying_complete"

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    visible: false
                }
                loadingIcon {
                    visible: true
                    icon_image: LoadingIcon.Success
                }
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
                textHeader {
                    text: qsTr("DRYING COMPLETE")
                    visible: true
                }
                textBody {
                    text: qsTr("The material is now dry and ready to use.")
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("DONE")
                    visible: true
                }
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },
        State {
            name: "drying_failed"

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    visible: false
                }
                loadingIcon {
                    visible: true
                    icon_image: LoadingIcon.Failure
                }
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
                textHeader {
                    text: qsTr("DRYING FAILED")
                    visible: true
                }
                textBody {
                    visible: false
                }
                buttonPrimary {
                    text: qsTr("DONE")
                    visible: true
                }
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },
        State {
            name: "cancelling"

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    visible: false
                }
                loadingIcon {
                    visible: true
                    icon_image: LoadingIcon.Loading
                    loadingProgress: 0
                }
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
                textHeader {
                    text: qsTr("CANCELLING")
                    visible: true
                }
                textBody {
                    text: qsTr("Please wait.")
                    visible: true
                }
                buttonPrimary {
                    visible: false
                }
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        }
    ]

    CustomPopup {
        popupName: "CancelDryingCycle"
        id: cancelDryingCyclePopup
        popupWidth: 720
        popupHeight: 265

        showTwoButtons: true
        left_button_text: qsTr("STOP DRYING")
        left_button.onClicked: {
            bot.cancel()
            state = "cancelling"
            cancelDryingCyclePopup.close()
        }
        right_button_text: qsTr("CONTINUE")
        right_button.onClicked: {
            cancelDryingCyclePopup.close()
        }

        ColumnLayout {
            id: columnLayout_copy_file_popup
            width: 590
            height: children.height
            spacing: 20
            anchors.top: parent.top
            anchors.topMargin: 150
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: alert_text_copy_file_popup
                color: "#cbcbcb"
                text: qsTr("EXIT PROCEDURE")
                font.letterSpacing: 3
                Layout.alignment: Qt.AlignHCenter
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 20
            }

            Text {
                id: description_text_copy_file_popup
                color: "#cbcbcb"
                text: qsTr("Are you sure you want to cancel and exit the procedure?")
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                font.family: defaultFont.name
                font.pixelSize: 18
                font.letterSpacing: 1
                lineHeight: 1.3
            }
        }
    }

    CustomPopup {
        popupName: "DryingCycleClearBuildPlate"
        id: dryConfirmBuildPlateClearPopup
        popupWidth: 720
        popupHeight: 220

        showTwoButtons: true
        left_button_text: qsTr("CONFIRM")
        left_button.onClicked: {
            bot.buildPlateCleared()
            dryConfirmBuildPlateClearPopup.close()
        }
        right_button_text: qsTr("BACK")
        right_button.onClicked: {
            dryConfirmBuildPlateClearPopup.close()
        }

        ColumnLayout {
            id: columnLayout_clear_build_plate_popup
            width: 590
            height: 100
            anchors.top: parent.top
            anchors.topMargin: 135
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: clear_build_plate_text
                color: "#cbcbcb"
                text: qsTr("CLEAR BUILD PLATE")
                font.letterSpacing: 3
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 20
            }

            Text {
                id: clear_build_plate_desc_text
                color: "#cbcbcb"
                text: qsTr("Check to make sure the printer build plate is empty.")
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                font.family: defaultFont.name
                font.pixelSize: 18
                lineHeight: 1.3
            }
        }
    }
}
