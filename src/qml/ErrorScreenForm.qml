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
                text: qsTr("ERROR TITLE")
                anchors.top: parent.top
                anchors.topMargin: 65
                font.bold: true
                font.family: defaultFont.name
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
                text: qsTr("Error description")
                anchors.top: errorMessageTitle.bottom
                anchors.topMargin: 20
                font.family: defaultFont.name
                font.weight: Font.Light
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
                text: qsTr("PROCESS FAILED.\nCLOSE BUILD\nCHAMBER DOOR.")
            }

            PropertyChanges {
                target: errorMessageDescription
                text: qsTr("Close the build chamber door and\ntry again.")
            }

            PropertyChanges {
                target: button2
                visible: false
            }

            PropertyChanges {
                target: button1
                label_width: 200
                buttonWidth: 200
                label: qsTr("TRY AGAIN")
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
                text: qsTr("PROCESS FAILED.\nCLOSE THE\nTOP LID.")
            }

            PropertyChanges {
                target: errorMessageDescription
                text: qsTr("Put the lid back on the printer\nand try again.")
            }

            PropertyChanges {
                target: button2
                visible: false
            }

            PropertyChanges {
                target: button1
                label_width: 200
                buttonWidth: 200
                label: qsTr("TRY AGAIN")
            }
        },

        State {
            name: "print_door_open_error"
            extend: "door_open_error"

            PropertyChanges {
                target: errorMessageTitle
                text: {
                    if(bot.process.stateType == ProcessStateType.Pausing ||
                       bot.process.stateTyep == ProcessStateType.Paused) {
                        qsTr("PRINT PAUSED.\nCLOSE BUILD\nCHAMBER DOOR.")
                    } else if(bot.process.stateType == ProcessStateType.Failed) {
                        qsTr("PRINT FAILED.\nCLOSE BUILD\nCHAMBER DOOR.")
                    } else {
                        emptyString
                    }
                }
            }

            PropertyChanges {
                target: errorMessageDescription
                text: {
                    if(bot.process.stateType == ProcessStateType.Pausing ||
                       bot.process.stateTyep == ProcessStateType.Paused) {
                        qsTr("Close the build chamber door to\ncontinue printing.")
                    } else if(bot.process.stateType == ProcessStateType.Failed) {
                        qsTr("Close the build chamber door and\nrestart print.")
                    } else {
                        emptyString
                    }
                }
            }

            PropertyChanges {
                target: button1
                label_width: 260
                buttonWidth: 260
                label: {
                    if(bot.process.stateType == ProcessStateType.Pausing ||
                       bot.process.stateTyep == ProcessStateType.Paused) {
                        qsTr("RESUME PRINT")
                    } else if(bot.process.stateType == ProcessStateType.Failed) {
                        qsTr("CONTINUE")
                    } else {
                        emptyString
                    }
                }
            }
        },

        State {
            name: "print_lid_open_error"
            extend: "lid_open_error"

            PropertyChanges {
                target: errorMessageTitle
                text: {
                    if(bot.process.stateType == ProcessStateType.Pausing ||
                       bot.process.stateTyep == ProcessStateType.Paused) {
                        qsTr("PRINT PAUSED.\nCLOSE THE\nTOP LID.")
                    } else if(bot.process.stateType == ProcessStateType.Failed) {
                        qsTr("PRINT FAILED.\nCLOSE THE\nTOP LID.")
                    } else {
                        emptyString
                    }
                }
            }

            PropertyChanges {
                target: errorMessageDescription
                text: {
                    if(bot.process.stateType == ProcessStateType.Pausing ||
                       bot.process.stateTyep == ProcessStateType.Paused) {
                        qsTr("Put the lid back on the printer\nto continue printing.")
                    } else if(bot.process.stateType == ProcessStateType.Failed) {
                        qsTr("Put the lid back on the printer and\nrestart print.")
                    } else {
                        emptyString
                    }
                }
            }

            PropertyChanges {
                target: button1
                label_width: 260
                buttonWidth: 260
                label: {
                    if(bot.process.stateType == ProcessStateType.Pausing ||
                       bot.process.stateTyep == ProcessStateType.Paused) {
                        qsTr("RESUME PRINT")
                    } else if(bot.process.stateType == ProcessStateType.Failed) {
                        qsTr("CONTINUE")
                    } else {
                        emptyString
                    }
                }
            }
        },

        State {
            name: "calibration_lid_open_error"
            extend: "lid_open_error"

            PropertyChanges {
                target: errorMessageTitle
                text: qsTr("CALIBRATION FAILED.\nCLOSE THE\nTOP LID.")
            }

            PropertyChanges {
                target: errorMessageDescription
                text: qsTr("Put the lid back on the printer\nand retry calibrating")
            }

            PropertyChanges {
                target: button1
                label: qsTr("TRY AGAIN")
            }
        },

        State {
            name: "filament_jam_error"

            PropertyChanges {
                target: errorImage
                source: {
                    if(bot.process.extruderAJammed) {
                        switch(bot.extruderAType) {
                        case ExtruderType.MK14:
                        case ExtruderType.MK14_EXP:
                        case ExtruderType.MK14_COMP:
                        case ExtruderType.MK14_HOT_E:
                            "qrc:/img/error_filament_jam_1.png"
                            break;
                        case ExtruderType.MK14_HOT:
                            "qrc:/img/error_filament_jam_1XA.png"
                            break;
                        }
                    } else if(bot.process.extruderBJammed) {
                        switch(bot.extruderBType) {
                        case ExtruderType.MK14:
                            "qrc:/img/error_filament_jam_2.png"
                            break;
                        case ExtruderType.MK14_HOT:
                            "qrc:/img/error_filament_jam_2XA.png"
                            break;
                        }
                    } else {
                        "qrc:/img/broken.png"
                    }
                }
            }

            PropertyChanges {
                target: errorIcon
                visible: false
            }

            PropertyChanges {
                target: errorMessageTitle
                text: qsTr("MATERIAL JAM\nDETECTED")
                anchors.topMargin: 0
            }

            PropertyChanges {
                target: errorMessageDescription
                text: {
                    qsTr("%1 seems to be\njammed. Be sure the spool isn't\ntangled and try purging the extruder.\nIf it remains jammed, unload the\nmaterial and snip off the end of it.%2").arg(
                    (bot.process.extruderAJammed ?
                                    qsTr("Model Extruder 1") :
                                    qsTr("Support Extruder 2"))).
                    arg((materialPage.shouldUserAssistPurging(bot.process.errorSource+1) ?
                             (qsTr("\n%1 may require manual\nassistance for purging.").arg((((bot.process.errorSource+1) == 1) ?
                                                                                                materialPage.bay1 :
                                                                                                materialPage.bay2).printMaterialName)) :
                         (emptyString)))
                }
            }

            PropertyChanges {
                target: button1
                buttonWidth: 340
                label_width: 300
                label: {
                    qsTr("PURGE EXTRUDER %1").arg((bot.process.extruderAJammed ?
                                                       qsTr("1") : qsTr("2")))
                }
            }

            PropertyChanges {
                target: button2
                visible: true
                buttonWidth: 340
                label_width: 320
                label: {
                    qsTr("UNLOAD EXTRUDER %1").arg((bot.process.extruderAJammed ?
                                                        qsTr("1") : qsTr("2")))
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
                    qsTr("PRINT PAUSING\nOUT OF %1\nMATERIAL").arg(
                        (bot.process.filamentBayAOOF ?
                             qsTr("MODEL") : qsTr("SUPPORT")))
                }
                anchors.topMargin: 0
            }

            PropertyChanges {
                target: errorMessageDescription
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
            }

            PropertyChanges {
                target: button1
                buttonWidth: 280
                label_width: 280
                label: {
                    qsTr("LOAD MATERIAL")
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
                source: bot.process.extruderAOOF ?
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
                    qsTr("PRINT PAUSING\nOUT OF %1\nMATERIAL").arg(
                                bot.process.extruderAOOF ?
                                    qsTr("MODEL") : qsTr("SUPPORT"))
                }
                anchors.topMargin: 0
            }

            PropertyChanges {
                target: errorMessageDescription
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
            }

            PropertyChanges {
                target: button1
                label_width: 200
                buttonWidth: 200
                label: {
                    qsTr("CONTINUE")
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
                source: bot.process.extruderAOOF ?
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
                    qsTr("REMOVE EMPTY\nSPOOL")
                }
                anchors.topMargin: 50
            }

            PropertyChanges {
                target: errorMessageDescription
                text: {
                    qsTr("Open material bay %1 and remove the\nempty material spool.").arg(
                            bot.process.extruderAOOF ? qsTr("1") : qsTr("2")) +
                    qsTr(" Then place a\nMakerBot %1 spool in the bay\nto load material.").arg(
                        bot.process.extruderAOOF ?
                             printPage.print_model_material_name :
                             printPage.print_support_material_name)
                }
            }

            PropertyChanges {
                target: button1
                label_width: 280
                buttonWidth: 280
                label: {
                    qsTr("LOAD MATERIAL")
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
                    qsTr("PRINT PAUSED.\nEXTRUDER %1\nDISCONNECTED.").arg(
                        bot.process.errorSource + 1);
                }
                anchors.topMargin: 0
            }

            PropertyChanges {
                target: errorMessageDescription
                text: qsTr("Ensure the extruder is attached and\npress the button below to continue.")
            }

            PropertyChanges {
                target: button1
                label_width: 340
                buttonWidth: 340
                label: {
                    qsTr("ATTACH EXTRUDER %1").arg(bot.process.errorSource + 1)
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
                text: qsTr("ERROR")
                anchors.topMargin: 50
            }

            PropertyChanges {
                target: errorMessageDescription
                text: {
                    qsTr("Error %1\nVisit MakerBot.com/support\nfor more info.").arg(lastReportedErrorCode)
                }
            }

            PropertyChanges {
                target: button1
                label_width: 200
                buttonWidth: 200
                label: qsTr("CONTINUE")
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
                text: qsTr("CALIBRATION\nERROR")
            }

            PropertyChanges {
                target: errorMessageDescription
                text: qsTr("There was a problem calibrating the\nprinter. Check the extruders for excess\nmaterial. If this happens again, please\ncontact MakerBot support. Error %1").arg(lastReportedErrorCode)
            }

            PropertyChanges {
                target: button1
                label: qsTr("TRY AGAIN")
            }

            PropertyChanges {
                target: errorMessageContainer
                anchors.verticalCenterOffset: -20
            }
        },

        State {
            name: "heater_not_reaching_temp"
            extend: "generic_error"

            PropertyChanges {
                target: errorMessageTitle
                text: qsTr("HEATING ERROR")
            }

            PropertyChanges {
                target: errorMessageDescription
                text: qsTr("There seems to be a problem with\nthe heaters. If this happens again,\nplease contact MakerBot support.\nError %1").arg(lastReportedErrorCode)
            }

            PropertyChanges {
                target: button1
                label: qsTr("CONTINUE")
            }

            PropertyChanges {
                target: errorMessageContainer
                anchors.verticalCenterOffset: -10
            }
        },

        State {
            name: "heater_over_temp"
            extend: "generic_error"

            PropertyChanges {
                target: errorMessageTitle
                text: qsTr("HEATER\nTEMPERATURE\nERROR")
            }

            PropertyChanges {
                target: errorMessageDescription
                text: qsTr("There seems to be a problem with\nthe heaters. If this happens again,\nplease contact MakerBot support.\nError %1").arg(lastReportedErrorCode)
            }

            PropertyChanges {
                target: button1
                label: qsTr("CONTINUE")
            }

            PropertyChanges {
                target: errorMessageContainer
                anchors.verticalCenterOffset: -30
            }
        },

        State {
            name: "toolhead_disconnect"
            extend: "generic_error"

            PropertyChanges {
                target: errorMessageTitle
                text: qsTr("CARRIAGE\nCOMMUNICATION\nERROR")
            }

            PropertyChanges {
                target: errorMessageDescription
                text: qsTr("The printer’s carriage is reporting\ncommunication drop-outs. Try\nrestarting the printer. If this happens\nagain, please contact MakerBot\nsupport. Error %1").arg(lastReportedErrorCode)
            }

            PropertyChanges {
                target: button1
                label: qsTr("CONTINUE")
            }

            PropertyChanges {
                target: errorMessageContainer
                anchors.verticalCenterOffset: -40
            }
        },
        State {
            name: "chamber_fan_failure"

            PropertyChanges {
                target: errorIcon
                visible: false
            }

            PropertyChanges {
                target: errorImage
                source: "qrc:/img/error_chamber_fan_failure.png"
            }

            PropertyChanges {
                target: errorMessageTitle
                text: qsTr("PRINT FAILED.\nFAN ERROR.")
            }

            PropertyChanges {
                target: errorMessageDescription
                text: qsTr("Please clear the chamber and make\n" +
                      "sure no filament is caught in the\n" +
                      "chamber heater fans.")
            }

            PropertyChanges {
                target: button1
                label: qsTr("CONTINUE")
            }

            PropertyChanges {
                target: button2
                visible: false
            }
        },

        State {
            name: "incompatible_slice"
            extend: "generic_error"

            PropertyChanges {
                target: errorMessageTitle
                text: qsTr("INCOMPATIBLE\nPRINT FILE")
            }

            PropertyChanges {
                target: errorMessageDescription
                text: qsTr("This .Makerbot was prepared for\na different type of printer. Please\nexport it again for this printer type.\nError %1").arg(lastReportedErrorCode)
            }

            PropertyChanges {
                target: button1
                label: qsTr("OK")
            }

            PropertyChanges {
                target: errorMessageContainer
                anchors.verticalCenterOffset: -15
            }
        },

        State {
            name: "tool_mismatch"
            extend: "generic_error"

            PropertyChanges {
                target: errorMessageTitle
                text: qsTr("EXTRUDER MISMATCH")
            }

            PropertyChanges {
                target: errorMessageDescription
                text: qsTr("This .Makerbot was prepared for a\ndifferent set of extruders.\n\n" +
                           "Extruders Attached -\n%1\nExtruders Required -\n%2\n\nPlease " +
                           "export it again for the\nattached extruders. (Error %3)").
                arg(formatExtruderNames(bot.process.currentTools)).
                arg(formatExtruderNames(bot.process.fileTools)).
                arg(lastReportedErrorCode)
            }

            PropertyChanges {
                target: button1
                label: qsTr("OK")
            }

            PropertyChanges {
                target: errorMessageContainer
                anchors.verticalCenterOffset: -50
            }
        }
    ]
}
