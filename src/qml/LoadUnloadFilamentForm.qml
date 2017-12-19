import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    id: loadUnloadForm
    width: 800
    height: 420
    property alias button_mouseArea: button_mouseArea
    property alias button_rectangle: button_rectangle
    property alias button_text: button_text
    property int currentTemperature: bayID == 1 ? bot.extruderACurrentTemp : bot.extruderBCurrentTemp
    property int targetTempertaure: bayID == 1 ? bot.extruderATargetTemp : bot.extruderBTargetTemp
    property bool filamentBaySwitchActive: false
    property int bayID: 1
    signal processDone
    property int currentState: bot.process.stateType
    onCurrentStateChanged: {
        switch(currentState)
        {
        case ProcessStateType.Stopping:
            state = "loaded_filament"
            break;
        case ProcessStateType.UnloadingFilament:
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
                font.pixelSize: 16
            }

            Rectangle {
                id: button_rectangle
                y: 255
                width: 350
                height: 45
                color: "#00000000"
                radius: 10
                border.width: 2
                border.color: "#ffffff"
                visible: false

                Text {
                    id: button_text
                    width: 300
                    text: "Text"
                    visible: false
                    font.family: "Antennae"
                    color: "#ffffff"
                    font.letterSpacing: 3
                    font.weight: Font.Bold
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                MouseArea {
                    id: button_mouseArea
                    anchors.fill: parent
                    visible: false
                }
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
                height: 60
                visible: true
                text: "Push the door closed until you feel it click sealing the material bay."
            }

            PropertyChanges {
                target: button_rectangle
                visible: true
            }

            PropertyChanges {
                target: button_text
                x: 30
                y: 11
                text: "THE DOOR IS CLOSED"
                visible: true
            }

            PropertyChanges {
                target: button_mouseArea
                visible: true
            }

            PropertyChanges {
                target: image
                source: "qrc:/img/close_bay_door.png"
            }
        },
        State {
            name: "preheating"
            when: bot.process.stateType == ProcessStateType.Preheating &&
                  bot.process.type == ProcessType.Load

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
                  bot.process.type == ProcessType.Load

            PropertyChanges {
                target: main_instruction_text
                text: "EXTRUSION CONFIRMATION"
            }

            PropertyChanges {
                target: instruction_description_text
                height: 60
                visible: true
                text: "Look inside of the printer and wait until you see material begin to extrude."
            }

            PropertyChanges {
                target: button_rectangle
                width: 225
                height: 75
                visible: true
            }

            PropertyChanges {
                target: button_text
                x: 17
                y: 13
                width: 192
                height: 49
                text: "MATERIAL IS EXTRUDING"
                visible: true
            }

            PropertyChanges {
                target: button_mouseArea
                visible: true
            }

            PropertyChanges {
                target: image
                source: "qrc:/img/confirm_extrusion.png"
            }
        },
        State {
            name: "loaded_filament"
            /*when: bot.process.stateType == ProcessStateType.Stopping &&
                  bot.process.type == ProcessType.Load
            */
            PropertyChanges {
                target: main_instruction_text
                text: "CLEAR EXCESS MATERIAL"
            }

            PropertyChanges {
                target: instruction_description_text
                height: 60
                visible: true
                text: "Wait a few moments until the material has cooled and remove the excess from the build chamber.                             (Do not touch the nozzle while it is hot, Red light on extruder)"
            }

            PropertyChanges {
                target: button_rectangle
                x: 0
                y: 297
                width: 100
                height: 50
                radius: 10
                visible: true
            }

            PropertyChanges {
                target: button_text
                x: 13
                y: 14
                width: 75
                height: 22
                text: "DONE"
                visible: true
            }

            PropertyChanges {
                target: button_mouseArea
                visible: true
            }

            PropertyChanges {
                target: image
                source: "qrc:/img/clear_excess_material.png"
            }
        },
        State {
            name: "unloaded_filament"
            //when: bot.process.stateType == ProcessStateType.UnloadingFilament && bot.process.type == ProcessType.Unload
            PropertyChanges {
                target: main_instruction_text
                text: "REWIND SPOOL"
            }

            PropertyChanges {
                target: instruction_description_text
                y: 1
                height: 60
                visible: true
                text: "Open material bay " + bayID + " and carefully rewind the material onto the spool. Secure the end of the filament in place and store in a cool dry space."
                anchors.topMargin: 170
            }

            PropertyChanges {
                target: button_rectangle
                x: 0
                y: 297
                width: 100
                height: 50
                radius: 10
                visible: true
            }

            PropertyChanges {
                target: button_text
                x: 13
                y: 14
                width: 75
                height: 22
                text: "DONE"
                visible: true
            }

            PropertyChanges {
                target: button_mouseArea
                visible: true
            }

            PropertyChanges {
                target: image
                source: "qrc:/img/unload_filament.png"
            }
        }
    ]
}
