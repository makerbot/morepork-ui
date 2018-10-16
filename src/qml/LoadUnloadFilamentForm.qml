import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    id: loadUnloadForm
    width: 800
    height: 420

    property alias acknowledgeButton: acknowledgeButton
    property int currentTemperature: bayID == 1 ? bot.extruderACurrentTemp : bot.extruderBCurrentTemp
    property int targetTemperature: bayID == 1 ? bot.extruderATargetTemp : bot.extruderBTargetTemp
    property bool filamentPresentSwitch: false
    property bool isExternalLoad: false
    property int bayID: 0
    property int currentActiveTool: bot.process.currentToolIndex + 1
    // Hold onto the current bay ID even after the process completes
    onCurrentActiveToolChanged: {
        if(currentActiveTool > 0) {
            bayID = currentActiveTool
        }
    }

    property bool isMaterialPresent: bayID == 1 ? bay1.spoolPresent :
                                                  bay2.spoolPresent

    onIsMaterialPresentChanged: {
        overrideInvalidMaterial = false
    }

    property bool isMaterialValid: true
    property bool overrideInvalidMaterial: false
    property int materialCode: bayID == 1 ? bay1.filamentMaterialCode :
                                            bay2.filamentMaterialCode
    property string materialName: bayID == 1 ? bay1.filamentMaterialName :
                                               bay2.filamentMaterialName
    property int errorCode
    signal processDone
    property int currentState: bot.process.stateType
    onCurrentStateChanged: {
        switch(currentState) {
        case ProcessStateType.Stopping:
        case ProcessStateType.Done:
            overrideInvalidMaterial = false
            if(bot.process.errorCode > 0) {
                errorCode = bot.process.errorCode
                state = "error"
            }
            else if(bot.process.type == ProcessType.Load) {
                // Cancelling Load/Unload ends with 'done' step
                // but the UI shouldn't go into load/unload
                // successful state, but to the default state.
                if(!materialChangeCancelled) {
                    state = "loaded_filament"
                }
                else {
                    // Moving to default state is handled in cnacel
                    // button onClicked action, we just reset the
                    // cancelled flag here.
                    materialChangeCancelled = false
                }
            }
            else if(bot.process.type == ProcessType.Unload) {
                // We cant' cancel out of unloading so we don't
                // need the UI state logic like in the 'Load'
                // process above.
                state = "unloaded_filament"
            }
            //The case when loading/unloading is stopped by user
            //in the middle of print process. Then the bot goes to
            //'Stopping' step and then to 'Paused' step, but to
            // differentiate successful stopping (i.e. stopping
            // extrusion) and cancelling, we monitor the
            // materialChangeCancelled flag. Since the bot goes to
            // paused state afterwards we also need to monitor
            // the flag there.
            else if(printPage.isPrintProcess) {
                if(materialChangeCancelled) {
                    state = "base state"
                    materialSwipeView.swipeToItem(0)
                    // If cancelled out of load/unload while in print process
                    // enable print drawer to set UI back to printing state.
                    setDrawerState(false)
                    activeDrawer = printPage.printingDrawer
                    setDrawerState(true)
                }
                else {
                    isLoadFilament ? state = "loaded_filament" :
                                     state = "unloaded_filament"
                }
                if(bot.process.errorCode > 0) {
                    errorCode = bot.process.errorCode
                    state = "error"
                }
            }
            break;
            //The case when loading/unloading completes normally by
            //itself, in the middle of print process. Then the bot doesn't
            //go to 'Stopping' step, but directly to 'Paused' step.
        case ProcessStateType.Paused:
            if(materialChangeCancelled) {
                materialChangeCancelled = false
            }
            else {
                isLoadFilament ? state = "loaded_filament" :
                                 state = "unloaded_filament"
            }
            break;
        default:
            break;
        }
    }

    Image {
        id: static_image
        width: 400
        height: 480
        anchors.verticalCenterOffset: -10
        anchors.verticalCenter: parent.verticalCenter
        source: ""
        cache: false
        opacity: (animated_image.opacity == 0) ?
                     1 : 0
    }

    AnimatedImage {
        id: animated_image
        width: 400
        height: 480
        anchors.verticalCenterOffset: -10
        anchors.verticalCenter: parent.verticalCenter
        source: bayID == 1 ?
                    "qrc:/img/place_spool_bay1.gif" :
                    "qrc:/img/place_spool_bay2.gif"
        cache: false
        // Since this is the base state, settting playing to true
        // makes the gif always keep playing even when this page is
        // not visible which makes the entire UI lag.
        playing: materialSwipeView.currentIndex == 1 &&
                 (loadUnloadForm.state == "base state" ||
                  loadUnloadForm.state == "feed_filament" ||
                  loadUnloadForm.state == "close_bay_door")
        opacity: 1
    }

    Item {
        id: contentItem
        x: 400
        y: -40
        width: 400
        height: 420
        anchors.left: parent.left
        anchors.leftMargin: 400

        Text {
            id: main_instruction_text
            width: 375
            color: "#cbcbcb"
            text: "OPEN BAY " + bayID
            font.capitalization: Font.AllUppercase
            anchors.top: parent.top
            anchors.topMargin: 100
            font.letterSpacing: 4
            wrapMode: Text.WordWrap
            font.family: "Antennae"
            font.weight: Font.Bold
            font.pixelSize: 20
            lineHeight: 1.3
        }

        ColumnLayout {
            id: instructionsList
            width: 300
            height: 80
            anchors.top: main_instruction_text.bottom
            anchors.topMargin: 18
            opacity: 1.0

            BulletedListItem {
                bulletNumber: "1"
                bulletText: "Open Bay " + bayID
            }

            BulletedListItem {
                bulletNumber: "2"
                bulletText: "Place a " +
                            (bayID == 1 ? "Model " : "Support ") +
                            "material spool in\nthe bay"
            }
        }

        Text {
            id: instruction_description_text
            width: 325
            color: "#cbcbcb"
            text: "\n\n\n"
            anchors.top: main_instruction_text.bottom
            anchors.topMargin: 30
            wrapMode: Text.WordWrap
            font.family: "Antennae"
            font.weight: Font.Light
            font.pixelSize: 18
            lineHeight: 1.35
        }

        RoundedButton {
            id: acknowledgeButton
            label_width: 180
            label: "CONTINUE"
            buttonWidth: 180
            buttonHeight: 50
            anchors.top: instruction_description_text.bottom
            anchors.topMargin: 20
            opacity: 1
        }

        RowLayout {
            id: temperatureDisplay
            anchors.top: main_instruction_text.bottom
            anchors.topMargin: 20
            width: children.width
            height: 35
            spacing: 10
            visible: false

            Text {
                id: extruder_current_temperature_text
                text: currentTemperature + "C"
                font.family: "Antennae"
                color: "#ffffff"
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pixelSize: 20
            }

            Rectangle {
                id: divider_rectangle
                width: 1
                height: 25
                color: "#ffffff"
            }

            Text {
                id: extruder_target_temperature_text
                text: targetTemperature + "C"
                font.family: "Antennae"
                color: "#ffffff"
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pixelSize: 20
            }
        }
    }

    states: [
        State {
            name: "feed_filament"
            when: (isMaterialPresent || overrideInvalidMaterial) &&
                  !isExternalLoad &&
                  bot.process.stateType == ProcessStateType.Preheating &&
                  (bot.process.type == ProcessType.Load ||
                   bot.process.type == ProcessType.Print)

            PropertyChanges {
                target: main_instruction_text
                text: {
                    if(overrideInvalidMaterial) {
                        "UNKNOWN MATERIAL"
                    }
                    else if(isMaterialValid) {
                        materialName + " DETECTED"
                    }
                }
            }

            PropertyChanges {
                target: instruction_description_text
                text: "Push the end of the material into the slot until you feel it being pulled in."
            }

            PropertyChanges {
                target: acknowledgeButton
                opacity: 1
                label: "CONTINUE"
            }

            PropertyChanges {
                target: animated_image
                opacity: 1
                source: bayID == 1 ?
                            "qrc:/img/insert_filament_bay1.gif" :
                            "qrc:/img/insert_filament_bay2.gif"
            }

            PropertyChanges {
                target: instructionsList
                opacity: 0
            }
        },
        State {
            name: "preheating"
            when: (filamentPresentSwitch || isExternalLoad) &&
                  bot.process.stateType == ProcessStateType.Preheating &&
                  (bot.process.type == ProcessType.Load ||
                   bot.process.type == ProcessType.Unload ||
                   bot.process.type == ProcessType.Print)

            PropertyChanges {
                target: main_instruction_text
                text: bayID == 1 ?
                          "EXTRUDER 1 IS\nHEATING UP" :
                          "EXTRUDER 2 IS\nHEATING UP"
                anchors.topMargin: 140
            }

            PropertyChanges {
                target: instruction_description_text
                text: ""
            }

            PropertyChanges {
                target: temperatureDisplay
                visible: true
            }

            PropertyChanges {
                target: extruder_current_temperature_text
                text: currentTemperature + "C"
                visible: true
            }

            PropertyChanges {
                target: extruder_target_temperature_text
                text: targetTemperature + "C"
                visible: true
            }

            PropertyChanges {
                target: animated_image
                opacity: 0
            }

            PropertyChanges {
                target: static_image
                source: bayID == 1 ?
                            "qrc:/img/extruder_1_heating.png" :
                            "qrc:/img/extruder_2_heating.png"
            }

            PropertyChanges {
                target: instructionsList
                opacity: 0
            }

            PropertyChanges {
                target: acknowledgeButton
                opacity: 0
            }
        },
        State {
            name: "extrusion"
            when: bot.process.stateType == ProcessStateType.Extrusion &&
                  (bot.process.type == ProcessType.Load ||
                   bot.process.type == ProcessType.Print)

            PropertyChanges {
                target: main_instruction_text
                text: "EXTRUSION CONFIRMATION"
                anchors.topMargin: 120
            }

            PropertyChanges {
                target: instruction_description_text
                text: "Look inside of the printer and wait until you see material begin to extrude."
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: acknowledgeButton
                label_size: 18
                label_width: 345
                buttonWidth: 345
                anchors.topMargin: 20
                opacity: 1
                label: "MATERIAL IS EXTRUDING"
            }

            PropertyChanges {
                target: animated_image
                opacity: 0
            }

            PropertyChanges {
                target: static_image
                source: bayID == 1 ?
                            "qrc:/img/confirm_extrusion_1.png" :
                            "qrc:/img/confirm_extrusion_2.png"
            }

            PropertyChanges {
                target: instructionsList
                opacity: 0
            }
        },
        State {
            name: "unloading_filament"
            when: bot.process.stateType == ProcessStateType.UnloadingFilament &&
                  (bot.process.type == ProcessType.Unload ||
                   bot.process.type == ProcessType.Print)

            PropertyChanges {
                target: main_instruction_text
                text: "UNLOADING"
                anchors.topMargin: 120
            }

            PropertyChanges {
                target: instruction_description_text
                text: "The filament is backing out of the extruder, please wait."
                anchors.topMargin: 30
            }

            PropertyChanges {
                target: animated_image
                opacity: 0
            }

            PropertyChanges {
                target: static_image
                source: "qrc:/img/clear_excess_material.png"
            }

            PropertyChanges {
                target: instructionsList
                opacity: 0
            }

            PropertyChanges {
                target: acknowledgeButton
                opacity: 0
            }
        },
        State {
            name: "loaded_filament"
            //this state doesn't have a when condiiton unlike others and
            //instead the switch case above is used to get into this state,
            //since we need the UI to be held at this screen
            //even after the process has completed, until the user presses 'done'.
            PropertyChanges {
                target: main_instruction_text
                text: "CLEAR EXCESS MATERIAL AFTER EXTRUDER COOLS DOWN"
            }

            PropertyChanges {
                target: instruction_description_text
                text: "Wait a few moments until the material has cooled and remove the excess from the build chamber. (Do not touch the nozzle while it is hot, Red light on extruder)"
                anchors.topMargin: 60
            }

            PropertyChanges {
                target: acknowledgeButton
                anchors.topMargin: 20
                buttonWidth: 175
                opacity: 1
                label_width: 175
                label: "CONTINUE"
            }

            PropertyChanges {
                target: animated_image
                opacity: 0
            }

            PropertyChanges {
                target: static_image
                source: bayID == 1 ?
                            "qrc:/img/confirm_extrusion_1.png" :
                            "qrc:/img/confirm_extrusion_2.png"
            }

            PropertyChanges {
                target: temperatureDisplay
                anchors.topMargin: 12
                visible: true
            }

            PropertyChanges {
                target: extruder_current_temperature_text
                text: bot.extruderACurrentTemp + "C"
                visible: true
            }

            PropertyChanges {
                target: extruder_target_temperature_text
                text: bot.extruderBCurrentTemp + "C"
                visible: true
            }

            PropertyChanges {
                target: instructionsList
                opacity: 0
            }
        },
        State {
            name: "unloaded_filament"
            //this state doesn't have a when condiiton unlike others and
            //instead the switch case above is used to get into this state,
            //since we need the UI to be held at this screen
            //even after the process has completed, until the user presses 'done'.
            PropertyChanges {
                target: main_instruction_text
                text: "REWIND SPOOL"
                anchors.topMargin: 120
            }

            PropertyChanges {
                target: instruction_description_text
                text: "Open material bay " +
                      bayID +
                      " and carefully rewind the material onto the spool. Secure the end of the filament in place and store in a cool dry space."
                anchors.topMargin: 30
            }

            PropertyChanges {
                target: acknowledgeButton
                buttonWidth: 100
                anchors.topMargin: 30
                opacity: 1
                label: "DONE"
            }

            PropertyChanges {
                target: animated_image
                opacity: 0
            }

            PropertyChanges {
                target: static_image
                source: "qrc:/img/unload_filament.png"
            }

            PropertyChanges {
                target: instructionsList
                opacity: 0
            }
        },
        State {
            name: "error"
            //this state doesn't have a when condiiton unlike others and
            //instead the switch case above is used to get into this state,
            //since we need the UI to be held at this screen
            //even after the process has completed, until the user presses 'done'.

            PropertyChanges {
                target: main_instruction_text
                width: 300
                text: switch(bot.process.type)
                      {
                      case ProcessType.Load:
                          "FILAMENT LOADING FAILED"
                          break;
                      case ProcessType.Unload:
                          "FILAMENT UNLOADING FAILED"
                          break;
                      }
            }

            PropertyChanges {
                target: instruction_description_text
                text: "Error " + errorCode
            }

            PropertyChanges {
                target: acknowledgeButton
                buttonWidth: 100
                anchors.topMargin: 50
                opacity: 1
                label: "DONE"
            }

            PropertyChanges {
                target: animated_image
                opacity: 0
            }

            PropertyChanges {
                target: static_image
                source: bayID == 1 ?
                            "qrc:/img/extruder_1_heating.png" :
                            "qrc:/img/extruder_2_heating.png"
            }

            PropertyChanges {
                target: instructionsList
                opacity: 0
            }
        },
        State {
            name: "close_bay_door"
            PropertyChanges {
                target: main_instruction_text
                text: "CLOSE BAY " + bayID
                anchors.topMargin: 165
            }

            PropertyChanges {
                target: instruction_description_text
                text: ""
                visible: true
                anchors.topMargin: 60
            }

            PropertyChanges {
                target: acknowledgeButton
                label_width: if(bayID == 1 && inFreStep) {
                                 375
                             } else {
                                 100
                             }
                opacity: 1
                anchors.topMargin: -50
                buttonWidth: {
                    if(bayID == 1 && inFreStep) {
                        375
                    } else {
                        100
                    }
                }
                label_size: {
                    if(bayID == 1 && inFreStep) {
                        14
                    } else {
                        18
                    }
                }
                label: {
                    if(bayID == 1 && inFreStep) {
                        "NEXT: Load Support Material"
                    } else {
                        "DONE"
                    }
                }
            }

            PropertyChanges {
                target: animated_image
                opacity: 1
                source: bayID == 1 ?
                            "qrc:/img/close_bay1.gif" :
                            "qrc:/img/close_bay2.gif"
            }

            PropertyChanges {
                target: temperatureDisplay
                visible: false
                anchors.topMargin: 15
            }

            PropertyChanges {
                target: instructionsList
                opacity: 0
            }
        }
    ]
}
