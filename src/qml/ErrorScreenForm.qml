import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import ErrorTypeEnum 1.0
import ExtruderTypeEnum 1.0
import MachineTypeEnum 1.0

LoggingItem {
    itemName: "ErrorScreen"

    // Qt JS engine updates the dependency graph
    // for all components in the DOM even when they
    // aren't rendered at all, which causes resued
    // components to maintain their state everywhere,
    // which can in theory slow things down and also
    // make them hold residual states uneccessarily.
    // isActive flag is used because of this.
    property bool isActive: false
    property alias button1: contentRightSide.buttonPrimary
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
                    state = "extruder_oof_error"
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
            case ErrorType.HomingError:
                state = "homing_error"
                break;
            case ErrorType.NoBuildPlateError:
                state = "no_build_plate_error"
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
        id: contentLeftSide
        visible: true
    }

    ContentRightSide {
        id: contentRightSide
        visible: true
    }

    states: [
        State {
            name: "door_open_error"

            PropertyChanges {
                target: contentLeftSide
                image {
                    source: ("qrc:/img/%1.png").arg(getImageForPrinter("error_close_door"))
                    visible: true
                }
            }

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: qsTr("PROCESS FAILED.") + "\n\n" + qsTr("CLOSE BUILD CHAMBER DOOR.")
                    visible: true
                }
                textBody {
                    text: qsTr("Close the build chamber door and try again.")
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("TRY AGAIN")
                    visible: true
                }
            }
        },

        State {
            name: "lid_open_error"

            PropertyChanges {
                target: contentLeftSide
                image {
                    source: ("qrc:/img/%1.png").arg(getImageForPrinter("error_close_lid"))
                    visible: true
                }
            }

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: qsTr("PROCESS FAILED.") + "\n\n" + qsTr("CLOSE THE TOP LID.")
                    visible: true
                }
                textBody {
                    text: qsTr("Put the lid back on the printer and try again.")
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("TRY AGAIN")
                    visible: true
                }
            }
        },

        State {
            name: "print_door_open_error"
            extend: "door_open_error"

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: {
                        if(bot.process.stateType == ProcessStateType.Pausing ||
                           bot.process.stateType == ProcessStateType.Paused) {
                            qsTr("PRINT PAUSED") + "\n\n" + qsTr("CLOSE PRINTER DOOR")
                        } else if(bot.process.stateType == ProcessStateType.Failed) {
                            qsTr("PRINT FAILED") + "\n\n" + qsTr("CLOSE PRINTER DOOR")
                        } else {
                            emptyString
                        }
                    }
                    visible: true
                }
                textBody {
                    text: {
                        if(bot.process.stateType == ProcessStateType.Pausing ||
                           bot.process.stateType == ProcessStateType.Paused) {
                            qsTr("Close the printer door to resume.")
                        } else if(bot.process.stateType == ProcessStateType.Failed) {
                            qsTr("Close the printer door and restart print.")
                        } else {
                            emptyString
                        }
                    }
                    visible: true
                }
                buttonPrimary {
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
            }
        },

        State {
            name: "print_lid_open_error"
            extend: "lid_open_error"

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: {
                        if(bot.process.stateType == ProcessStateType.Pausing ||
                           bot.process.stateType == ProcessStateType.Paused) {
                            qsTr("PRINT PAUSED") + "\n\n" + qsTr("CLOSE TOP LID")
                        } else if(bot.process.stateType == ProcessStateType.Failed) {
                            qsTr("PRINT FAILED") + "\n\n" + qsTr("CLOSE TOP LID")
                        } else {
                            emptyString
                        }
                    }
                    visible: true
                }
                textBody {
                    text: {
                        if(bot.process.stateType == ProcessStateType.Pausing ||
                           bot.process.stateType == ProcessStateType.Paused) {
                            qsTr("Close the top lid to resume.")
                        } else if(bot.process.stateType == ProcessStateType.Failed) {
                            qsTr("Put the lid back on the printer and restart print.")
                        } else {
                            emptyString
                        }
                    }
                    visible: true
                }
                buttonPrimary {
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
            }
        },

        State {
            name: "calibration_lid_open_error"
            extend: "lid_open_error"

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: qsTr("CALIBRATION FAILED") + "\n\n" + qsTr("CLOSE THE TOP LID")
                    visible: true
                }
                textBody {
                    text: qsTr("Put the lid back on the printer and retry calibrating")
                    visible: true
                }
            }
        },

        State {
            name: "filament_jam_error"

            PropertyChanges {
                target: contentLeftSide
                image {
                    source: {
                        if(bot.process.extruderAJammed) {
                            "qrc:/img/error_filament_jam_1.png"
                        } else if(bot.process.extruderBJammed) {
                            "qrc:/img/error_filament_jam_2.png"
                        } else {
                            "qrc:/img/broken.png"
                        }
                    }
                    visible: true
                }
            }

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: qsTr("PRINT PAUSED") + "\n\n" + qsTr("EXTRUDER %1 JAM DETECTED").arg(
                              (bot.process.extruderAJammed ? ("1") : ("2")))
                    visible: true
                }
                textBody {
                    text: qsTr("Ensure the spool isn't tangled and try purging the extruder. " +
                               "If the issue recurs, unload and reload the material.")
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("CLEAR EXTRUDER")
                    visible: true
                }
            }
        },
        State {
            name: "filament_bay_oof_error"

            PropertyChanges {
                target: contentLeftSide
                image {
                    source: bot.process.filamentBayAOOF ?
                                "qrc:/img/error_oof_bay1.png" :
                                "qrc:/img/error_oof_bay2.png"
                    visible: true
                }
            }

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: {
                        qsTr("PRINT PAUSED") + "<br><br>" +
                        qsTr("MATERIAL %1 OUT OF FILAMENT").arg(
                                           (bot.process.filamentBayAOOF ?
                                             ("1") : ("2")))
                    }
                    visible: true
                }
                textBody {
                    text: qsTr("Open the material bay and remove the empty spool, " +
                               "as well as any excess material.")
                    visible: true
                }
                textBody1 {
                    text: qsTr("Place a MakerBot %1 spool in the bay to load material.").arg(
                                    bot.process.filamentBayAOOF ?
                                         printPage.print_model_material_name :
                                         printPage.print_support_material_name)
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("LOAD MATERIAL %1").arg(
                              (bot.process.filamentBayAOOF ?
                                   ("1") : ("2")))
                    visible: true
                }
            }
        },

        State {
            name: "extruder_oof_error"

            PropertyChanges {
                target: contentLeftSide
                image {
                    source: bot.process.extruderAOOF ?
                                "qrc:/img/error_oof_extruder1.png" :
                                "qrc:/img/error_oof_extruder2.png"
                    visible: true
                }
            }

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: {
                        qsTr("PRINT PAUSED") + "<br><br>" +
                        qsTr("MATERIAL %1 OUT OF FILAMENT").arg(
                                           (bot.process.extruderAOOF ?
                                             ("1") : ("2")))
                    }
                    visible: true
                }
                textBody {
                    text: qsTr("Open the top lid and remove material clip to pull " +
                               "the remaining material out of the extruder.")
                    visible: true
                }
                buttonPrimary {
                    // The load button is disabled while the extruder unloads.
                    // Kaiten goes through preheating_unloading and unloading_filament
                    // steps before getting to paused step. The button is only enabled
                    // in the paused step.
                    text: qsTr("LOAD MATERIAL %1").arg(
                                bot.process.extruderAOOF ?
                                     ("1") : ("2"))
                    visible: true
                }
            }
        },

        State {
            name: "no_tool_connected"

            PropertyChanges {
                target: contentLeftSide
                image {
                    source: bot.process.errorSource?
                                "qrc:/img/error_tool_2.png" :
                                "qrc:/img/error_tool_1.png"
                    visible: true
                }
            }

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: {
                        qsTr("PRINT PAUSED") + "\n\n" + qsTr("EXTRUDER %1 DISCONNECTED").arg(
                            bot.process.errorSource + 1);
                    }
                    visible: true
                }
                textBody {
                    text: qsTr("Ensure the extruder is attached and press the button below to continue.")
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("ATTACH EXTRUDER %1").arg(bot.process.errorSource + 1)
                    visible: true
                }
            }
        },

        State {
            name: "generic_error"

            PropertyChanges {
                target: contentLeftSide

                processStatusIcon {
                    processStatus: ProcessStatusIcon.Failed
                    visible: true
                }
            }

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: qsTr("PROCESS FAILED") + "\n\n" + qsTr("ERROR %1").arg(lastReportedErrorCode)
                    visible: true
                }
                textBody {
                    text: qsTr("Please visit the support page to learn more information " +
                               "about this error and contact our support team.")
                    visible: true
                }
                textBody1 {
                    text: "support.makerbot.com"
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("EXIT")
                    visible: true
                }
            }
        },

        State {
            name: "calibration_failed"
            extend: "generic_error"

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: qsTr("CALIBRATION ERROR")
                    visible: true
                }
                textBody {
                    text: qsTr("There was a problem calibrating the printer. Check the extruders " +
                               "for excess material. If this happens again, please contact MakerBot " +
                               "support. Error %1").arg(lastReportedErrorCode)
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("TRY AGAIN")
                    visible: true
                }
            }
        },

        State {
            name: "heater_not_reaching_temp"
            extend: "generic_error"

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: qsTr("HEATING ERROR")
                    visible: true
                }
                textBody {
                    text: qsTr("There seems to be a problem with the heaters. Please make sure that " +
                               "the top lid is securely seated. If this happens again, please " +
                               "contact MakerBot support. Error %1").arg(lastReportedErrorCode)
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("CONTINUE")
                    visible: true
                }
            }
        },

        State {
            name: "heater_over_temp"
            extend: "generic_error"

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: qsTr("HEATER TEMPERATURE ERROR")
                    visible: true
                }
                textBody {
                    text: qsTr("There seems to be a problem with the heaters. If this happens " +
                               "again, please contact MakerBot support. Error %1").arg(lastReportedErrorCode)
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("CONTINUE")
                    visible: true
                }
            }
        },

        State {
            name: "toolhead_disconnect"
            extend: "generic_error"

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: qsTr("PROCESS FAILED") + "\n\n" + qsTr("CARRIAGE COMMUNICATION ERROR")
                    visible: true
                }
                textBody {
                    text: qsTr("The printer’s carriage is reporting communication drop-outs. " +
                               "Try restarting the printer. If this happens again, please contact support.")
                    visible: true
                }
            }
        },

        State {
            name: "chamber_fan_failure"

            PropertyChanges {
                target: contentLeftSide

                image {
                    source: "qrc:/img/error_chamber_fan_failure.png"
                    visible: true
                }
            }

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: qsTr("PRINT FAILED") + "\n\n" + qsTr("FAN ERROR")
                    visible: true
                }
                textBody {
                    text: qsTr("Please clear the chamber and make sure no filament " +
                               "is caught in the chamber heater fans.")
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("CONTINUE")
                    visible: true
                }
            }
        },

        State {
            name: "incompatible_slice"
            extend: "generic_error"

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: qsTr("INCOMPATIBLE PRINT FILE")
                    visible: true
                }
                textBody {
                    text: qsTr("This .Makerbot was prepared for a different type of printer. " +
                               "Please export it again for this printer type. Error %1").arg(lastReportedErrorCode)
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("OK")
                    visible: true
                }
            }
        },

        State {
            name: "tool_mismatch"
            extend: "generic_error"

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: qsTr("EXTRUDER MISMATCH")
                    visible: true
                }
                textBody {
                    text: qsTr("This .Makerbot was prepared for a different set of extruders.") + "\n\n" +
                          qsTr("Extruders Attached -") +
                          "\n%1\n".arg(formatExtruderNames(bot.process.currentTools)) +
                          qsTr("Extruders Required -") +
                          "\n%1\n\n".arg(formatExtruderNames(bot.process.fileTools)) +
                          qsTr("Please export it again for the attached extruders. (Error %1)")
                              .arg(lastReportedErrorCode)
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("OK")
                    visible: true
                }
            }
        },
        State {
            name: "homing_error"
            extend: "generic_error"

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: qsTr("PRINT FAILED") + "\n\n" + qsTr("HOMING ERROR")
                    visible: true
                }
                textBody {
                    text: qsTr("Confirm the build plate is installed correctly and clear any debris.")
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("EXIT")
                    visible: true
                }
            }
        },
        State {
            name: "no_build_plate_error"
            extend: "generic_error"

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    text: qsTr("PRINT FAILED") + "\n\n" + qsTr("NO BUILD PLATE DETECTED")
                    visible: true
                }
                textBody {
                    text: qsTr("Please ensure your build plate is properly attached.")
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("EXIT")
                    visible: true
                }
            }
        }

    ]
}
