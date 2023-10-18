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
    property real timeLeftMinutes: bot.process.timeRemaining/60
    property int currentStep: bot.process.stateType
    signal processDone
    property bool hasFailed: bot.process.errorCode !== 0
    property bool doChooseMaterial: false
    property bool hasFinished: false

    onDoChooseMaterialChanged: {
        if(doChooseMaterial)
            state = "choose_material"
    }

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
        {label: "pva", temperature : 60, time : 24, custom: false},
        {label: "nylon || nylon cf || nylon 12 cf || petg", temperature : 60, time : 24, custom: false},
        {label: "pla || tough", temperature : 45, time : 24, custom: false}
    ]

    property variant dryingMaterialsListMethodX : [
        {label: "pva", temperature : 70, time : 24, custom: false},
        {label: "rapidrinse", temperature : 70, time : 24, custom: false},
        {label: "nylon || nylon cf || nylon 12 cf", temperature : 70, time : 24, custom: false},
        {label: "abs || asa || pc-abs || petg", temperature : 60, time : 24, custom: false},
        {label: "pla || tough", temperature : 45, time : 24, custom: false}
    ]

    property variant dryingMaterialsListMethodXL : [
        {label: "abs-r", temperature: 60, time: 16, custom: false},
        {label: "abs-cf", temperature: 60, time: 16, custom: false},
        {label: "nylon cf", temperature: 70, time: 16, custom: false},
        {label: "pva", temperature: 50, time: 16, custom: false},
        {label: "rapidrinse", temperature: 70, time: 16, custom: false},
        {label: "sr-30", temperature: 0, time: 0, custom: false}
    ]

    ContentLeftSide {
        id: contentLeftSide
        image {
            source: ("qrc:/img/%1.png").arg(getImageForPrinter("dry_material"))
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
            text: qsTr("Material extrusion issues may be caused by moisture absorption by the filament.") +"\n\n" +
                  qsTr("This procedure will allow you to dry materials for improved print quality, using METHOD’s "+
                       "built-in heaters.") + "\n\n" + qsTr("Please sure the build plate is empty.")
            font.weight: Font.Normal
            visible: true
            opacity: 1
        }
        textBody1 {
            style: TextBody.ExtraLarge
            visible:false
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
        width: parent.width
        visible: false
    }

    DryMaterialCustomTemperature {
        id: customMaterialTemperature
        height: parent.height
        width: parent.width
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
                    text: qsTr("RAISING BUILD PLATE")
                    visible: true
                }
                textBody {
                    text: qsTr("For proximity to heated chamber.")
                    font.weight: Font.Normal
                    visible: true
                    opacity: 1
                }
                textBody1 {
                    visible:false
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
                    font.weight: Font.Normal
                    visible: true
                    opacity: 1
                }
                textBody1 {
                    visible:false
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
                          qsTr("Place spool in bag and add additional fresh bags of desiccant before sealing.")
                    font.weight: Font.Normal
                    visible: true
                    opacity: 1
                }
                textBody1 {
                    visible:false
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
                    source: ("qrc:/img/%1.png").arg(getImageForPrinter("dry_material"))
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
                    font.weight: Font.Normal
                    visible: true
                    opacity: 1
                }
                textBody1 {
                    visible:false
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

            PropertyChanges {
                target: customMaterialTemperature
                visible: false
            }
        },
        State {
            name: "choose_material"

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

            PropertyChanges {
                target: customMaterialTemperature
                visible: false
            }
        },
        State {
          name: "custom_material"

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
              visible: false
          }

          PropertyChanges {
              target: customMaterialTemperature
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
                            qsTr("PREPARING")
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
                        qsTr("Your material is drying. We will let you know once completed.")
                    }
                    font.weight: Font.Bold
                    opacity: 0.5
                }
                textBody1 {
                    visible: bot.process.stateType == ProcessStateType.DryingSpool
                    text: {
                        var timeRemaining = timeLeftMinutes % 60
                        var timeLeftHours = (timeLeftMinutes - timeRemaining)/60
                        qsTr("%1 REMAINING").arg(Math.round(timeLeftHours) + "H " +
                                                 Math.round(timeRemaining) + "M")
                    }
                }
                buttonPrimary {
                    visible: false
                }
                temperatureStatus {
                    visible: (bot.process.stateType == ProcessStateType.Loading)
                    showComponent: TemperatureStatus.Chamber
                }
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }

            PropertyChanges {
                target: customMaterialTemperature
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
                    text: qsTr("COMPLETED")
                    visible: true
                }
                textBody {
                    text: qsTr("The material is now dry and ready to use.")
                    font.weight: Font.Normal
                    visible: true
                    opacity: 1
                }
                textBody1 {
                    visible:false
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

            PropertyChanges {
                target: customMaterialTemperature
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
                textBody1 {
                    visible:false
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

            PropertyChanges {
                target: customMaterialTemperature
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
                    font.weight: Font.Normal
                    visible: true
                    opacity: 1
                }
                textBody1 {
                    visible:false
                }
                buttonPrimary {
                    visible: false
                }
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }

            PropertyChanges {
                target: customMaterialTemperature
                visible: false
            }
        }
    ]

    CustomPopup {
        popupName: "CancelDryingCycle"
        id: cancelDryingCyclePopup
        popupWidth: 720
        popupHeight: columnLayout_cancel_process_popup.height+145
        showTwoButtons: true
        right_button_text: qsTr("STOP PROCESS")
        right_button.onClicked: {
            bot.cancel()
            state = "cancelling"
            cancelDryingCyclePopup.close()
        }
        left_button_text: qsTr("BACK")
        left_button.onClicked: {
            cancelDryingCyclePopup.close()
        }

        ColumnLayout {
            id: columnLayout_cancel_process_popup
            width: 590
            height: children.height
            anchors.top: cancelDryingCyclePopup.popupContainer.top
            anchors.topMargin: 35
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            TextHeadline {
                id: alert_text_copy_file_popup
                text: qsTr("EXIT PROCEDURE")
                Layout.alignment: Qt.AlignHCenter
            }

            TextBody {
                id: description_text_copy_file_popup
                text: qsTr("Are you sure you want to cancel and exit the procedure?")
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.weight: Font.Light
            }
        }
    }

    CustomPopup {
        popupName: "DryingCycleClearBuildPlate"
        id: dryConfirmBuildPlateClearPopup
        popupHeight: columnLayout_clear_build_plate_popup.height+145
        showTwoButtons: true
        right_button_text: qsTr("CONFIRM")
        right_button.onClicked: {
            bot.buildPlateCleared()
            dryConfirmBuildPlateClearPopup.close()
        }
        left_button_text: qsTr("BACK")
        left_button.onClicked: {
            dryConfirmBuildPlateClearPopup.close()
        }

        ColumnLayout {
            id: columnLayout_clear_build_plate_popup
            width: 590
            height: children.height
            anchors.top: dryConfirmBuildPlateClearPopup.popupContainer.top
            anchors.topMargin: 35
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Image {
                id: build_plate_error_image
                width: sourceSize.width - 10
                height: sourceSize.height -10
                Layout.alignment: Qt.AlignHCenter
                source: "qrc:/img/process_error_small.png"
            }

            TextHeadline {
                id: title
                text: qsTr("CONFIRM BUILD PLATE IS CLEAR")
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
