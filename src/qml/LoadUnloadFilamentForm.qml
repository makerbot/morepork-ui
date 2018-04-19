import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    id: loadUnloadForm
    width: 800
    height: 420

    property alias acknowledgeButton: acknowledgeButton
    property int currentTemperature: bayID == 1 ? bot.extruderACurrentTemp : bot.extruderBCurrentTemp
    property int targetTempertaure: bayID == 1 ? bot.extruderATargetTemp : bot.extruderBTargetTemp
    property bool filamentBaySwitchActive: false
    property int bayID: 1
    property int errorCode
    signal processDone
    property int currentState: bot.process.stateType
    onCurrentStateChanged: {
        switch(currentState)
        {
        case ProcessStateType.Stopping:
        case ProcessStateType.Done:
            if(bot.process.errorCode > 0) {
                errorCode = bot.process.errorCode
                state = "error"
            }
            else if(bot.process.type == ProcessType.Load) {
                state = "loaded_filament"
            }
            else if(bot.process.type == ProcessType.Unload) {
                state = "unloaded_filament"
            }
            //The case when loading/unloading is stopped by user
            //in the middle of print process. Then the bot goes to
            //'Stopping' step and then to 'Paused' step
            else if(printPage.isPrintProcess) {
                isLoadFilament ?
                    state = "loaded_filament" :
                    state = "unloaded_filament"
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
            isLoadFilament ?
                state = "loaded_filament" :
                state = "unloaded_filament"
            break;
        default:
            break;
        }
    }

    Image {
        id: image
        width: sourceSize.width
        height: sourceSize.height
        source: "qrc:/img/insert_model_material.png"

        Item {
            id: item2
            width: 400
            height: 420
            anchors.left: parent.left
            anchors.leftMargin: 400

            Text {
                id: main_instruction_text
                width: 262
                height: 24
                color: "#cbcbcb"
                text: bayID == 1 ? "INSERT MODEL MATERIAL SPOOL" : "INSERT SUPPORT MATERIAL SPOOL"
                anchors.top: parent.top
                anchors.topMargin: 110
                font.letterSpacing: 4
                wrapMode: Text.WordWrap
                font.family: "Antennae"
                font.weight: Font.Bold
                font.pixelSize: 20
                lineHeight: 1.35
            }

            Text {
                id: instruction_description_text
                width: 325
                height: 105
                color: "#cbcbcb"
                text: "Open material bay " + bayID + " and insert the MakerBot Smart Spool. Feed the end of the material into the slot until you feel it being pulled in."
                anchors.top: parent.top
                anchors.topMargin: 180
                wrapMode: Text.WordWrap
                font.family: "Antennae"
                font.weight: Font.Light
                font.pixelSize: 18
                lineHeight: 1.35
            }

            RoundedButton {
                id: acknowledgeButton
                buttonWidth: 350
                buttonHeight: 45
                anchors.top: parent.top
                anchors.topMargin: 280
                visible: false
            }

            RowLayout {
                id: rowLayout
                y: 173
                width: 150
                height: 35
                visible: false

                Text {
                    id: extruder_current_tempertaure_text
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
                    text: targetTempertaure + "C"
                    font.family: "Antennae"
                    color: "#ffffff"
                    font.letterSpacing: 3
                    font.weight: Font.Light
                    font.pixelSize: 20
                }
            }
        }
    }
    states: [
        State {
            name: "feed_filament"
            when: filamentBaySwitchActive == true &&
                  bot.process.stateType == ProcessStateType.Preheating &&
                  bot.process.type == ProcessType.Load

            PropertyChanges {
                target: main_instruction_text
                text: "CLOSE THE BAY DOOR"
            }

            PropertyChanges {
                target: instruction_description_text
                text: "Push the door closed until you feel it click sealing the material bay."
            }

            PropertyChanges {
                target: acknowledgeButton
                visible: true
                label: "THE DOOR IS CLOSED"
            }

            PropertyChanges {
                target: image
                source: "qrc:/img/close_bay_door.png"
            }
        },
        State {
            name: "preheating"
            when: bot.process.stateType == ProcessStateType.Preheating &&
                  (bot.process.type == ProcessType.Load ||
                   bot.process.type == ProcessType.Unload ||
                   bot.process.type == ProcessType.Print)

            PropertyChanges {
                target: main_instruction_text
                text: bayID == 1 ? "EXTRUDER 1 IS HEATING UP" : "EXTRUDER 2 IS HEATING UP"
            }

            PropertyChanges {
                target: instruction_description_text
                text: ""
            }

            PropertyChanges {
                target: rowLayout
                visible: true
            }

            PropertyChanges {
                target: image
                source: "qrc:/img/extruder_heating.png"
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
            }

            PropertyChanges {
                target: instruction_description_text
                text: "Look inside of the printer and wait until you see material begin to extrude."
            }

            PropertyChanges {
                target: acknowledgeButton
                buttonWidth: 225
                buttonHeight: 75
                anchors.topMargin: 280
                visible: true
                label: "MATERIAL IS EXTRUDING"
            }

            PropertyChanges {
                target: image
                source: "qrc:/img/confirm_extrusion.png"
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
            }

            PropertyChanges {
                target: instruction_description_text
                text: "The filament is backing out of the extruder, please wait."
                anchors.topMargin: 165
            }

            PropertyChanges {
                target: image
                source: "qrc:/img/clear_excess_material.png"
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
                text: "CLEAR EXCESS MATERIAL"
            }

            PropertyChanges {
                target: instruction_description_text
                text: "Wait a few moments until the material has cooled and remove the excess from the build chamber.                             (Do not touch the nozzle while it is hot, Red light on extruder)"
            }

            PropertyChanges {
                target: acknowledgeButton
                anchors.topMargin: 330
                buttonWidth: 100
                buttonHeight: 50
                visible: true
                label: "DONE"
            }

            PropertyChanges {
                target: image
                source: "qrc:/img/clear_excess_material.png"
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
            }

            PropertyChanges {
                target: instruction_description_text
                text: "Open material bay " + bayID + " and carefully rewind the material onto the spool. Secure the end of the filament in place and store in a cool dry space."
                anchors.topMargin: 165
            }

            PropertyChanges {
                target: acknowledgeButton
                buttonWidth: 100
                buttonHeight: 50
                anchors.topMargin: 300
                visible: true
                label: "DONE"
            }

            PropertyChanges {
                target: image
                source: "qrc:/img/unload_filament.png"
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
                buttonHeight: 50
                anchors.topMargin: 265
                visible: true
                label: "DONE"
            }

            PropertyChanges {
                target: image
                source: "qrc:/img/extruder_heating.png"
            }
        }
    ]
}
