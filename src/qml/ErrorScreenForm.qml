import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import ErrorTypeEnum 1.0

Item {
    width: 800
    height: 440
    smooth: false

    property alias button1: button1
    property alias button2: button2
    property int errorCode: bot.process.errorType

    onErrorCodeChanged: {
        switch(errorCode) {
        case ErrorType.LidNotPlaced:
            if(bot.process.type == ProcessType.Print) {
                state = "lid_open_error"
            }
            break;
        case ErrorType.DoorNotClosed:
            if(bot.process.type == ProcessType.Print) {
                state = "door_open_error"
            }
            break;
        case ErrorType.FilamentJam:
            if(bot.process.type == ProcessType.Print) {
                state = "filament_jam_error"
            }
            break;
        case ErrorType.DrawerOutOfFilament:
            if(bot.process.type == ProcessType.Print) {
                state = "filament_bay_oof_error"
            }
            break;
        case ErrorType.ExtruderOutOfFilament:
            if(bot.process.type == ProcessType.Print) {
                state = "extruder_oof_error_state1"
            }
            break;
        default:
            state = "base state"
            break;
        }
    }

    Item {
        id: mainItem
        anchors.fill: parent

        Image {
            id: errorImage
            width: sourceSize.width
            height: sourceSize.height
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/img/error_close_door.png"
        }

        Item {
            id: errorMessageContainer
            width: 350
            height: 350
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: errorImage.right
            anchors.leftMargin: 0

            Image {
                id: errorIcon
                width: 35
                height: 35
                anchors.top: parent.top
                anchors.topMargin: 10
                source: "qrc:/img/alert.png"
            }

            Text {
                id: errorMessageTitle
                text: "ERROR TITLE"
                anchors.top: parent.top
                anchors.topMargin: 65
                font.bold: true
                font.family: "Antennae"
                font.weight: Font.Bold
                font.pixelSize: 26
                font.letterSpacing: 2
                lineHeight: 1.1
                color: "#ffffff"
                smooth: false
                antialiasing: false
            }

            Text {
                id: errorMessageDescription
                text: "Error description"
                anchors.top: errorMessageTitle.bottom
                anchors.topMargin: 20
                font.family: "Antennae"
                font.pixelSize: 18
                lineHeight: 1.2
                color: "#e8e8e8"
                smooth: false
                antialiasing: false
            }

            RoundedButton {
                id: button1
                anchors.top: errorMessageDescription.bottom
                anchors.topMargin: 20
                label: "BUTTON 1"
                label_width: 250
                label_size: 22
                buttonWidth: 260
                buttonHeight: 50
            }

            RoundedButton {
                id: button2
                anchors.top: button1.bottom
                anchors.topMargin: 20
                label: "BUTTON 2"
                label_width: 200
                label_size: 22
                buttonWidth: 260
                buttonHeight: 50
            }
        }
    }
    states: [
        State {
            name: "door_open_error"

            PropertyChanges {
                target: errorIcon
                visible: true
            }

            PropertyChanges {
                target: errorImage
                source: "qrc:/img/error_close_door.png"
            }

            PropertyChanges {
                target: errorMessageTitle
                text: "PRINT PAUSED.\nCLOSE BUILD\nCHAMBER DOOR."
            }

            PropertyChanges {
                target: errorMessageDescription
                text: "Close the build chamber door to\ncontinue printing."
            }

            PropertyChanges {
                target: button2
                visible: false
            }

            PropertyChanges {
                target: button1
                label: "RESUME PRINT"
            }
        },

        State {
            name: "lid_open_error"

            PropertyChanges {
                target: errorIcon
                visible: true
            }

            PropertyChanges {
                target: errorImage
                source: "qrc:/img/error_close_lid.png"
            }

            PropertyChanges {
                target: errorMessageTitle
                text: "PRINT PAUSED.\nCLOSE THE\nTOP LID."
            }

            PropertyChanges {
                target: errorMessageDescription
                text: "Put the lid back on the printer\nto continue printing."
            }

            PropertyChanges {
                target: button2
                visible: false
            }

            PropertyChanges {
                target: button1
                label: "RESUME PRINT"
            }
        },
        State {
            name: "filament_jam_error"

            PropertyChanges {
                target: errorImage
                source: bot.extruderAJammed ?
                            "qrc:/img/error_filament_jam_1.png" :
                            "qrc:/img/error_filament_jam_2.png"
            }

            PropertyChanges {
                target: errorIcon
                visible: false
            }

            PropertyChanges {
                target: errorMessageTitle
                text: "MATERIAL JAM\nDETECTED"
                anchors.topMargin: 0
            }

            PropertyChanges {
                target: errorMessageDescription
                text: (bot.extruderAJammed ?
                           "Model Extruder 1" :
                           "Support Extruder 2") +
                      " seems to be\njammed. Be sure the spool isn't\ntangled and try purging the extruder.\nIf it remains jammed, unload the\nmaterial and snip off the end of it."
            }

            PropertyChanges {
                target: button1
                buttonWidth: 340
                label_width: 300
                label: {
                    "PURGE EXTRUDER " +
                       (bot.extruderAJammed ? "1" : "2")
                }
            }

            PropertyChanges {
                target: button2
                visible: true
                buttonWidth: 340
                label_width: 320
                label: {
                    "UNLOAD EXTRUDER " +
                    (bot.extruderAJammed ? "1" : "2")
                }
            }
        },
        State {
            name: "filament_bay_oof_error"

            PropertyChanges {
                target: errorImage
                source: bot.process.filamentBayAOOF ?
                            "qrc:/img/error_oof_bay1.png" :
                            "qrc:/img/error_oof_bay2.png"
            }

            PropertyChanges {
                target: errorIcon
                visible: false
            }

            PropertyChanges {
                target: errorMessageTitle
                text: {
                    "PRINT PAUSING\nOUT OF " +
                    (bot.process.filamentBayAOOF ?
                         "MODEL" :
                         "SUPPORT") +
                    "\nMATERIAL"
                }
                anchors.topMargin: 0
            }

            PropertyChanges {
                target: errorMessageDescription
                text: {
                    "The printer has run out of " +
                        (bot.process.filamentBayAOOF ?
                             printPage.print_model_material.toUpperCase() :
                             printPage.print_support_material.toUpperCase()) +
                        ". Open\nmaterial bay " +
                        (bot.process.filamentBayAOOF ? "1" : "2") +
                        " and carefully pull out\nany material still in the guide tube,\nthen remove the empty material spool.\nThis may take up to 60 seconds."
                }
            }

            PropertyChanges {
                target: button1
                buttonWidth: 280
                label_width: 280
                label: {
                    "LOAD MATERIAL"
                }
            }

            PropertyChanges {
                target: button2
                visible: false
            }
        },

        State {
            name: "extruder_oof_error_state1"
            PropertyChanges {
                target: errorImage
                source: bot.extruderAOOF ?
                            "qrc:/img/error_oof_extruder1.png" :
                            "qrc:/img/error_oof_extruder2.png"
            }

            PropertyChanges {
                target: errorIcon
                visible: false
            }

            PropertyChanges {
                target: errorMessageTitle
                text: {
                    "PRINT PAUSING\nOUT OF " +
                    (bot.extruderAOOF ?
                                "MODEL" :
                                "SUPPORT") +
                     "\nMATERIAL"
                }
                anchors.topMargin: 0
            }

            PropertyChanges {
                target: errorMessageDescription
                text: {
                    "Remove the lid and swivel clip then\ngently pull out the remaining " +
                    (bot.extruderAOOF ?
                          "model" :
                          "support") +
                    "\nmaterial from " +
                    (bot.extruderAOOF ?
                          "Model Extruder 1." :
                          "Support Extruder 2.") +
                    " This\nprocess can take up to 60 seconds."
                }
            }

            PropertyChanges {
                target: button1
                label_width: 200
                buttonWidth: 200
                label: {
                    "CONTINUE"
                }
            }

            PropertyChanges {
                target: button2
                visible: false
            }
        },

        State {
            name: "extruder_oof_error_state2"
            PropertyChanges {
                target: errorImage
                source: bot.extruderAOOF ?
                            "qrc:/img/error_oof_bay1.png" :
                            "qrc:/img/error_oof_bay1.png"
            }

            PropertyChanges {
                target: errorIcon
                visible: false
            }

            PropertyChanges {
                target: errorMessageTitle
                text: {
                    "REMOVE EMPTY\nSPOOL"
                }
                anchors.topMargin: 50
            }

            PropertyChanges {
                target: errorMessageDescription
                text: {
                    "Open material bay " +
                     (bot.extruderAOOF ?
                                "1" : "2") +
                      " and remove the\nempty material spool."
                }
            }

            PropertyChanges {
                target: button1
                label_width: 280
                buttonWidth: 280
                label: {
                    "LOAD MATERIAL"
                }
            }

            PropertyChanges {
                target: button2
                visible: false
            }
        }
    ]
}
