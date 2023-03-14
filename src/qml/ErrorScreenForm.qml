import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import ErrorTypeEnum 1.0
import ExtruderTypeEnum 1.0

LoggingItem {
    itemName: "ErrorScreen"
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
    property bool isActive: true
    property alias button1: contentRightItem.buttonPrimary
    property alias button2: contentRightItem.buttonSecondary1
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
                    state = "print_door_open_error"
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
            case ErrorType.ChamberFanFailure:
                if(lastReportedProcessType == ProcessType.Print) {
                    state = "chamber_fan_failure"
                }
                break;
            case ErrorType.ToolMismatch:
                if(lastReportedProcessType == ProcessType.Print) {
                    state = "tool_mismatch"
                }
                break;
            case ErrorType.IncompatibleSlice:
                if(lastReportedProcessType == ProcessType.Print) {
                    state = "incompatible_slice"
                }
                break;
            case ErrorType.NoFilamentAtExtruder:
            case ErrorType.OtherError:
                state = "generic_error"
                break;
            default:
                state = "base state"
                break;
            }
        }
    }

    ContentLeftSide {
        id: contentLeftItem
        visible: true

        image {
            source: "qrc:/img/error_close_door.png"
            visible:  true
        }
    }

    ContentRightSide {
        id: contentRightItem
        visible: true

        textHeader {
            text: qsTr("ERROR TITLE")
            style: TextHeadline.Base
            visible: true
        }

        textBody {
            text: qsTr("Error description")
            visible: true
        }

        buttonPrimary {
            text: "BUTTON 1"
            visible: true
        }

        buttonSecondary1 {
            text: "BUTTON 2"
            visible: true
        }


    }

    states: [
        State {
            name: "door_open_error"

            PropertyChanges {
                target: contentLeftItem.image
                source: "qrc:/img/error_close_door.png"
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textHeader
                text: qsTr("PROCESS FAILED.\nCLOSE BUILD\nCHAMBER DOOR.")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: qsTr("Close the build chamber door and\ntry again.")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonSecondary1
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                text: qsTr("TRY AGAIN")
                visible: true
            }
        },

        State {
            name: "lid_open_error"

            PropertyChanges {
                target: contentLeftItem.image
                source: "qrc:/img/error_close_lid.png"
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textHeader
                text: qsTr("PROCESS FAILED.\nCLOSE THE\nTOP LID.")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: qsTr("Put the lid back on the printer\nand try again.")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonSecondary1
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                text: qsTr("TRY AGAIN")
                visible: true
            }
        },

        State {
            name: "print_door_open_error"
            extend: "door_open_error"

            PropertyChanges {
                target: contentRightItem.textHeader
                text: {
                    if(bot.process.stateType == ProcessStateType.Pausing ||
                       bot.process.stateType == ProcessStateType.Paused) {
                        qsTr("PRINT PAUSED.\nCLOSE BUILD\nCHAMBER DOOR.")
                    } else if(bot.process.stateType == ProcessStateType.Failed) {
                        qsTr("PRINT FAILED.\nCLOSE BUILD\nCHAMBER DOOR.")
                    } else {
                        emptyString
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: {
                    if(bot.process.stateType == ProcessStateType.Pausing ||
                       bot.process.stateType == ProcessStateType.Paused) {
                        qsTr("Close the build chamber door to\ncontinue printing.")
                    } else if(bot.process.stateType == ProcessStateType.Failed) {
                        qsTr("Close the build chamber door and\nrestart print.")
                    } else {
                        emptyString
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                text: {
                    if(bot.process.stateType == ProcessStateType.Pausing ||
                       bot.process.stateType == ProcessStateType.Paused) {
                        qsTr("RESUME PRINT")
                    } else if(bot.process.stateType == ProcessStateType.Failed) {
                        qsTr("CONTINUE")
                    } else {
                        emptyString
                    }
                }
                visible: true
            }
        },

        State {
            name: "print_lid_open_error"
            extend: "lid_open_error"

            PropertyChanges {
                target: contentRightItem.textHeader
                text: {
                    if(bot.process.stateType == ProcessStateType.Pausing ||
                       bot.process.stateType == ProcessStateType.Paused) {
                        qsTr("PRINT PAUSED.\nCLOSE THE\nTOP LID.")
                    } else if(bot.process.stateType == ProcessStateType.Failed) {
                        qsTr("PRINT FAILED.\nCLOSE THE\nTOP LID.")
                    } else {
                        emptyString
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: {
                    if(bot.process.stateType == ProcessStateType.Pausing ||
                       bot.process.stateType == ProcessStateType.Paused) {
                        qsTr("Put the lid back on the printer\nto continue printing.")
                    } else if(bot.process.stateType == ProcessStateType.Failed) {
                        qsTr("Put the lid back on the printer and\nrestart print.")
                    } else {
                        emptyString
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                text: {
                    if(bot.process.stateType == ProcessStateType.Pausing ||
                       bot.process.stateType == ProcessStateType.Paused) {
                        qsTr("RESUME PRINT")
                    } else if(bot.process.stateType == ProcessStateType.Failed) {
                        qsTr("CONTINUE")
                    } else {
                        emptyString
                    }
                }
                visible: true
            }
        },

        State {
            name: "calibration_lid_open_error"
            extend: "lid_open_error"

            PropertyChanges {
                target: contentRightItem.textHeader
                text: qsTr("CALIBRATION FAILED.\nCLOSE THE\nTOP LID.")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: qsTr("Put the lid back on the printer\nand retry calibrating")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                text: qsTr("TRY AGAIN")
                visible: true
            }
        },

        State {
            name: "filament_jam_error"

            PropertyChanges {
                target: contentLeftItem.image
                source: {
                    if(bot.process.extruderAJammed) {
                        "qrc:/img/error_extruder_filament_jam_1.png"
                    } else if(bot.process.extruderBJammed) {
                        "qrc:/img/error_extruder_filament_jam_2.png"
                    } else {
                        "qrc:/img/broken.png"
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textHeader
                text: qsTr("PRINT PAUSED\n\nEXTRUDER %1 JAM\nDETECTED").arg((bot.process.extruderAJammed ?
                                                                 qsTr("1") : qsTr("2")))
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: {
                    "Ensure the spool isn't tangled and try purging the extruder.If the issue recurs, unload and reload the material"
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                text: {
                    qsTr("PURGE MATERIAL %1").arg((bot.process.extruderAJammed ?
                                                       qsTr("1") : qsTr("2")))
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonSecondary1
                visible: true
                text: {
                    qsTr("UNLOAD MATERIAL %1").arg((bot.process.extruderAJammed ?
                                                        qsTr("1") : qsTr("2")))
                }
            }

            PropertyChanges {
                target: contentRightItem
                x: 400
                y: 0
                width: 400
                height: 440
            }
        },
        State {
            name: "filament_bay_oof_error"

            PropertyChanges {
                target: contentLeftItem.image
                source: bot.process.filamentBayAOOF ?
                            "qrc:/img/error_oof_bay1.png" :
                            "qrc:/img/error_oof_bay2.png"
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textHeader
                text: {
                    qsTr("PRINT PAUSING\nOUT OF %1\nMATERIAL").arg(
                        (bot.process.filamentBayAOOF ?
                             qsTr("MODEL") : qsTr("SUPPORT")))
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: {
                    qsTr("The printer has run out of %1").arg(
                        bot.process.filamentBayAOOF ?
                             printPage.print_model_material_name :
                             printPage.print_support_material_name) +
                    qsTr(". Open\nmaterial bay %1 and carefully pull out\nany material still in the guide tube,\nthen remove the empty material spool.\nThis may take up to 60 seconds.\n").arg(
                        bot.process.filamentBayAOOF ? qsTr("1") : qsTr("2")) +
                    qsTr("Then place a MakerBot %1 spool\nin the bay to load material.").arg(
                        bot.process.filamentBayAOOF ?
                             printPage.print_model_material_name :
                             printPage.print_support_material_name)
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                text: {
                    qsTr("LOAD MATERIAL")
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonSecondary1
                visible: false
            }
        },

        State {
            name: "extruder_oof_error_state1"
            PropertyChanges {
                target: contentLeftItem.image
                source: bot.process.extruderAOOF ?
                            "qrc:/img/error_oof_extruder1.png" :
                            "qrc:/img/error_oof_extruder2.png"
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textHeader
                text: {
                    qsTr("PRINT PAUSING\nOUT OF %1\nMATERIAL").arg(
                                bot.process.extruderAOOF ?
                                    qsTr("MODEL") : qsTr("SUPPORT"))
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: {
                    qsTr("Remove the lid and swivel clip then\ngently pull out the remaining %1\nmaterial from %2.").arg(
                        bot.process.extruderAOOF ?
                              qsTr("model") :
                              qsTr("support")).arg(
                        bot.process.extruderAOOF ?
                              qsTr("Model Extruder 1") :
                              qsTr("Support Extruder 2")) +
                    qsTr(" This\nprocess can take up to 60 seconds.")
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                text: {
                    qsTr("CONTINUE")
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonSecondary1
                visible: false
            }
        },

        State {
            name: "extruder_oof_error_state2"
            PropertyChanges {
                target: contentLeftItem.image
                source: bot.process.extruderAOOF ?
                            "qrc:/img/error_oof_bay1.png" :
                            "qrc:/img/error_oof_bay1.png"
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textHeader
                text: {
                    qsTr("REMOVE EMPTY\nSPOOL")
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: {
                    qsTr("Open material bay %1 and remove the\nempty material spool.").arg(
                            bot.process.extruderAOOF ? qsTr("1") : qsTr("2")) +
                    qsTr(" Then place a\nMakerBot %1 spool in the bay\nto load material.").arg(
                        bot.process.extruderAOOF ?
                             printPage.print_model_material_name :
                             printPage.print_support_material_name)
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                text: {
                    qsTr("LOAD MATERIAL")
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonSecondary1
                visible: false
            }
        },

        State {
            name: "no_tool_connected"

            PropertyChanges {
                target: contentLeftItem.image
                source: bot.process.errorSource?
                            "qrc:/img/error_filament_jam_2.png" :
                            "qrc:/img/error_filament_jam_1.png"
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textHeader
                text: {
                    qsTr("PRINT PAUSED.\nEXTRUDER %1\nDISCONNECTED.").arg(
                        bot.process.errorSource + 1);
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: qsTr("Ensure the extruder is attached and\npress the button below to continue.")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                text: {
                    qsTr("ATTACH EXTRUDER %1").arg(bot.process.errorSource + 1)
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonSecondary1
                visible: false
            }
        },

        State {
            name: "generic_error"

            PropertyChanges {
                target: contentLeftItem.image
                anchors.verticalCenterOffset: -25
                anchors.leftMargin: 100
                source: "qrc:/img/error.png"
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textHeader
                text: qsTr("ERROR")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: {
                    qsTr("Error %1\nVisit MakerBot.com/support\nfor more info.").arg(lastReportedErrorCode)
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                text: qsTr("CONTINUE")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonSecondary1
                visible: false
            }
        },

        State {
            name: "calibration_failed"
            extend: "generic_error"

            PropertyChanges {
                target: contentRightItem.textHeader
                text: qsTr("CALIBRATION\nERROR")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: qsTr("There was a problem calibrating the\nprinter. Check the extruders for excess\nmaterial. If this happens again, please\ncontact MakerBot support. Error %1").arg(lastReportedErrorCode)
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                text: qsTr("TRY AGAIN")
                visible: true
            }
        },

        State {
            name: "heater_not_reaching_temp"
            extend: "generic_error"

            PropertyChanges {
                target: contentRightItem.textHeader
                text: qsTr("HEATING ERROR")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: qsTr("There seems to be a problem with\nthe heaters. If this happens again,\nplease contact MakerBot support.\nError %1").arg(lastReportedErrorCode)
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                text: qsTr("CONTINUE")
                visible: true
            }
        },

        State {
            name: "heater_over_temp"
            extend: "generic_error"

            PropertyChanges {
                target: contentRightItem.textHeader
                text: qsTr("HEATER\nTEMPERATURE\nERROR")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: qsTr("There seems to be a problem with\nthe heaters. If this happens again,\nplease contact MakerBot support.\nError %1").arg(lastReportedErrorCode)
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                text: qsTr("CONTINUE")
                visible: true
            }
        },

        State {
            name: "toolhead_disconnect"
            extend: "generic_error"

            PropertyChanges {
                target: contentRightItem.textHeader
                text: qsTr("CARRIAGE\nCOMMUNICATION\nERROR")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: qsTr("The printer’s carriage is reporting\ncommunication drop-outs. Try\nrestarting the printer. If this happens\nagain, please contact MakerBot\nsupport. Error %1").arg(lastReportedErrorCode)
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                text: qsTr("CONTINUE")
                visible: true
            }
        },
        State {
            name: "chamber_fan_failure"

            PropertyChanges {
                target: contentLeftItem.image
                source: "qrc:/img/error_chamber_fan_failure.png"
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textHeader
                text: qsTr("PRINT FAILED.\nFAN ERROR.")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: qsTr("Please clear the chamber and make\n" +
                      "sure no filament is caught in the\n" +
                      "chamber heater fans.")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                text: qsTr("CONTINUE")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonSecondary1
                visible: false
            }
        },

        State {
            name: "incompatible_slice"
            extend: "generic_error"

            PropertyChanges {
                target: contentRightItem.textHeader
                text: qsTr("INCOMPATIBLE\nPRINT FILE")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: qsTr("This .Makerbot was prepared for\na different type of printer. Please\nexport it again for this printer type.\nError %1").arg(lastReportedErrorCode)
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                text: qsTr("OK")
                visible: true
            }

        },

        State {
            name: "tool_mismatch"
            extend: "generic_error"

            PropertyChanges {
                target: contentRightItem.textHeader
                text: qsTr("EXTRUDER MISMATCH")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: qsTr("This .Makerbot was prepared for a\ndifferent set of extruders.\n\n" +
                           "Extruders Attached -\n%1\nExtruders Required -\n%2\n\nPlease " +
                           "export it again for the\nattached extruders. (Error %3)").
                arg(formatExtruderNames(bot.process.currentTools)).
                arg(formatExtruderNames(bot.process.fileTools)).
                arg(lastReportedErrorCode)
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                text: qsTr("OK")
                visible: true
            }

        }
    ]
}
