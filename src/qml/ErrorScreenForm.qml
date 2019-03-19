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

    // Qt JS engine updates the dependency graph
    // for all components in the DOM even when they
    // aren't rendered at all, which causes resued
    // components to maintain their state everywhere,
    // which can in theory slow things down and also
    // make them hold residual states uneccessarily.
    // isActive flag is used because of this.
    property bool isActive: false
    property alias button1: button1
    property alias button2: button2
    property int processType: bot.process.type
    property int errorType: bot.process.errorType
    property int errorCode: bot.process.errorCode

    // Simple process and error latching mechanism
    // since some processes end immediately upon
    // erroring, then clear the error code and just
    // go away as if nothing happened and some do not.
    // This ensures consistent behavior for error
    // handling all processes. Also this will have to
    // modified if we get a series of non-zero error
    // codes before a process ends as this will only
    // hold the last reported one in that case.
    property int lastReportedProcessType
    property int lastReportedErrorType
    property int lastReportedErrorCode

    onProcessTypeChanged: {
        if(isActive && processType > 0) {
            lastReportedProcessType = processType
            // Clear out errors when the
            // process itself changes.
            acknowledgeError()
        }
    }

    onErrorCodeChanged: {
        if(isActive && errorCode > 0) {
            lastReportedErrorCode = errorCode
        }
    }

    onErrorTypeChanged: {
        if(isActive && errorType > 0) {
            lastReportedErrorType = errorType
            switch(lastReportedErrorType) {
            case ErrorType.LidNotPlaced:
                if (lastReportedProcessType == ProcessType.Print) {
                    state = "print_lid_open_error"
                } else if(lastReportedProcessType == ProcessType.CalibrationProcess) {
                    state = "calibration_lid_open_error"
                }
                break;
            case ErrorType.DoorNotClosed:
                if (lastReportedProcessType == ProcessType.Print) {
                    state = "door_open_error"
                }
                break;
            case ErrorType.FilamentJam:
                if(lastReportedProcessType == ProcessType.Print) {
                    state = "filament_jam_error"
                }
                break;
            case ErrorType.DrawerOutOfFilament:
                if(lastReportedProcessType == ProcessType.Print) {
                    state = "filament_bay_oof_error"
                }
                break;
            case ErrorType.ExtruderOutOfFilament:
                if(lastReportedProcessType == ProcessType.Print) {
                    state = "extruder_oof_error_state1"
                }
                break;
            case ErrorType.NoToolConnected:
                state = "no_tool_connected"
                break;
            case ErrorType.BadHESCalibrationFail:
                if(lastReportedProcessType == ProcessType.CalibrationProcess) {
                    state = "calibration_failed"
                } else if(lastReportedProcessType == ProcessType.AssistedLeveling) {
                    // Add screen
                }
                break;
            case ErrorType.HeaterNotReachingTemp:
                state = "heater_not_reaching_temp"
                break;
            case ErrorType.HeaterOverTemp:
                state = "heater_over_temp"
                break;
            case ErrorType.NotConnected:
                state = "toolhead_disconnect"
                break;
            case ErrorType.OtherError:
                state = "generic_error"
                break;
            default:
                state = "base state"
                break;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
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
                label_width: 200
                label_size: 22
                buttonWidth: 200
                buttonHeight: 50
            }

            RoundedButton {
                id: button2
                anchors.top: button1.bottom
                anchors.topMargin: 20
                label: "BUTTON 2"
                label_width: 200
                label_size: 22
                buttonWidth: 200
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
                label_width: 250
                buttonWidth: 250
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
                text: "PROCESS FAILED.\nCLOSE THE\nTOP LID."
            }

            PropertyChanges {
                target: errorMessageDescription
                text: "Put the lid back on the printer\nand try again."
            }

            PropertyChanges {
                target: button2
                visible: false
            }

            PropertyChanges {
                target: button1
                label_width: 200
                buttonWidth: 200
                label: "TRY AGAIN"
            }
        },
        State {
            name: "print_lid_open_error"
            extend: "lid_open_error"

            PropertyChanges {
                target: errorMessageTitle
                text: "PRINT PAUSED.\nCLOSE THE\nTOP LID."
            }

            PropertyChanges {
                target: errorMessageDescription
                text: "Put the lid back on the printer\nto continue printing."
            }

            PropertyChanges {
                target: button1
                label_width: 260
                buttonWidth: 260
                label: "RESUME PRINT"
            }
        },

        State {
            name: "calibration_lid_open_error"
            extend: "lid_open_error"

            PropertyChanges {
                target: errorMessageTitle
                text: "CALIBRATION FAILED.\nCLOSE THE\nTOP LID."
            }

            PropertyChanges {
                target: errorMessageDescription
                text: "Put the lid back on the printer\nand retry calibrating"
            }

            PropertyChanges {
                target: button1
                label: "TRY AGAIN"
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
        },

        State {
            name: "no_tool_connected"

            PropertyChanges {
                target: errorIcon
                visible: false
            }

            PropertyChanges {
                target: errorImage
                source: bot.process.errorSource?
                            "qrc:/img/error_filament_jam_2.png" :
                            "qrc:/img/error_filament_jam_1.png"
            }

            PropertyChanges {
                target: errorMessageContainer
                anchors.verticalCenterOffset: 40
            }

            PropertyChanges {
                target: errorMessageTitle
                text: {
                    "PRINT PAUSED.\nEXTRUDER " +
                    (bot.process.errorSource + 1) +
                     "\nDISCONNECTED."
                }
                anchors.topMargin: 0
            }

            PropertyChanges {
                target: errorMessageDescription
                text: "Ensure the extruder is attached and\npress the button below to continue."
            }

            PropertyChanges {
                target: button1
                label_width: 340
                buttonWidth: 340
                label: {
                    "ATTACH EXTRUDER " + (bot.process.errorSource + 1)
                }
            }

            PropertyChanges {
                target: button2
                visible: false
            }
        },

        State {
            name: "generic_error"

            PropertyChanges {
                target: errorImage
                anchors.verticalCenterOffset: -25
                anchors.leftMargin: 100
                source: "qrc:/img/error.png"
            }

            PropertyChanges {
                target: errorIcon
                visible: false
            }

            PropertyChanges {
                target: errorIcon
                visible: false
            }

            PropertyChanges {
                target: errorMessageTitle
                text: "ERROR"
                anchors.topMargin: 50
            }

            PropertyChanges {
                target: errorMessageDescription
                text: {
                    "Error " + errorCode +
                    "\nVisit MakerBot.com/support\nfor more info."
                }
            }

            PropertyChanges {
                target: button1
                label_width: 200
                buttonWidth: 200
                label: "CONTINUE"
            }

            PropertyChanges {
                target: button2
                visible: false
            }

            PropertyChanges {
                target: errorMessageContainer
                anchors.leftMargin: 120
            }
        },

        State {
            name: "calibration_failed"
            extend: "generic_error"

            PropertyChanges {
                target: errorMessageTitle
                text: "CALIBRATION\nERROR"
            }

            PropertyChanges {
                target: errorMessageDescription
                text: "There was a problem calibrating the\nprinter. Check the extruders for excess\nmaterial. If this happens again, please\ncontact MakerBot support. Error " + lastReportedErrorCode
            }

            PropertyChanges {
                target: button1
                label: "TRY AGAIN"
            }
        },

        State {
            name: "heater_not_reaching_temp"
            extend: "generic_error"

            PropertyChanges {
                target: errorMessageTitle
                text: "HEATING ERROR"
            }

            PropertyChanges {
                target: errorMessageDescription
                text: "There seems to be a problem with\nthe heaters. If this happens again,\nplease contact MakerBot support.\nError " + lastReportedErrorCode
            }

            PropertyChanges {
                target: button1
                label: "CONTINUE"
            }
        },

        State {
            name: "heater_over_temp"
            extend: "generic_error"

            PropertyChanges {
                target: errorMessageTitle
                text: "HEATER\nTEMPERATURE\nERROR"
            }

            PropertyChanges {
                target: errorMessageDescription
                text: "There seems to be a problem with\nthe heaters. If this happens again,\nplease contact MakerBot support.\nError " + lastReportedErrorCode
            }

            PropertyChanges {
                target: button1
                label: "CONTINUE"
            }
        },

        State {
            name: "toolhead_disconnect"
            extend: "generic_error"

            PropertyChanges {
                target: errorMessageTitle
                text: "CARRIAGE\nCOMMUNICATION\nERROR"
            }

            PropertyChanges {
                target: errorMessageDescription
                text: "The printer’s carriage is reporting\ncommunication drop-outs. Try\nrestarting the printer. If this happens\nagain, please contact MakerBot\nsupport. Error " + lastReportedErrorCode
            }

            PropertyChanges {
                target: button1
                label: "CONTINUE"
            }
        }
    ]
}
