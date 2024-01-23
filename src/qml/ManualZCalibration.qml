import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

ManualZCalibrationForm {
    property bool secondPass: false
    property int adjustment: 0
    property bool allowReturn: false

    // If we are printing and we cancel the print, we wait for the print
    // to fully cancel 
    property bool waitingForCancel: false
    property bool cancelWaitDone: waitingForCancel && (
        bot.process.type != ProcessType.Print ||
        bot.process.stateType == ProcessStateType.Cancelled ||
        bot.process.stateType == ProcessStateType.Complete ||
        bot.process.stateType == ProcessStateType.Failed)
    onCancelWaitDoneChanged: {
        if (cancelWaitDone) completeCancelWait();
    }
    function completeCancelWait() {
        waitingForCancel = false;
        printPage.acknowledgePrint()
        printPage.clearErrors()
        mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
        settingsSwipeView.swipeToItem(SettingsPage.ExtruderSettingsPage)
        extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.ManualZCalibrationPage)
    }

    Timer {
        id: waitForConfigs
        interval: 2500
        onTriggered: {
            state = "success"
        }
    }

    Timer {
        id: waitForCoarseAdjustment
        interval: 2500
        onTriggered: {
            if(secondPass) {
                state = "cal_issue"
            } else {
                state = "adjustments_complete"
                secondPass = true
            }
            adjustment = 0
        }
    }

    function getTestPrint() {
        // We could use the spool journal to determine the loaded material
        // but sticking with this way that we use everywhere else currently.
        var model_mat = materialPage.bay1.filamentMaterial
        var support_mat = materialPage.bay2.filamentMaterial
        var test_print_dir_string = bot.extruderATypeStr + "/"
        var test_print_name_string = model_mat + "_" + support_mat
        storage.getCalibrationPrint(test_print_dir_string, test_print_name_string)
    }

    function startTestPrint() {
        printPage.printFromUI = true
        printPage.startPrintSource = PrintPage.FromLocal
        getTestPrint()
        printPage.getPrintFileDetails(storage.currentThing)
        resetSettingsSwipeViewPages()
        mainSwipeView.swipeToItem(MoreporkUI.PrintPage)
        printPage.printSwipeView.swipeToItem(PrintPage.StartPrintConfirm)
    }

    function getAverage() {
        var num = 0
        var values = [calValueItem1.value, calValueItem2.value,
                calValueItem3.value, calValueItem4.value]
        // Average the values
        for (var i = 0; i < values.length; i++) {
            num += values[i]
        }
        return (num/values.length)
    }

    function setNewToolheadConfigurations() {
        var t_after = 0.20
        var s = -0.515
        // Get Bz before value from sensor
        var bz_before = bot.offsetBZ

        // Get Average
        var t_before = getAverage()

        // Find Offset
        var bz_after = ((t_after - t_before) / s) + bz_before

        // Set configs
        bot.setManualCalibrationOffset(bz_after)
        waitForConfigs.start()
    }

    function setCoarseAdjustments() {
        // Get Bz before value from sensor
        var bz_before = bot.offsetBZ

        // Set Coarse Adjustments
        var bz_new_offset = bz_before + (adjustment == -1 ? (-0.1) : (0.1))

        // Set Adjustment
        bot.setManualCalibrationOffset(bz_new_offset)
        waitForCoarseAdjustment.start()
    }

    function checkForIssues() {
        var low_range_val = 0.16
        var high_range_val = 0.26

        // Get Average
        var avg = getAverage()

        // Check
        if(avg < low_range_val) {
            adjustment = -1
            return true
        }
        else if(avg > high_range_val) {
            adjustment = 1
            return true
        }

        // Return False if good
        return false
    }

    function resetManualCalValues() {
        calValueItem1.value = 0.20
        calValueItem2.value = 0.20
        calValueItem3.value = 0.20
        calValueItem4.value = 0.20
    }

    // Reset or Restart the Manual Z Cal Process
    // bool exit determines if we are leaving
    // the process entirely
    function resetProcess(exit) {
        state = "z_cal_start"
        resetManualCalValues()
        secondPass = false
        if(exit) {
            isInManualCalibration = false
            extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.BasePage)
        }
    }

    function back() {
        if (state == "measure") {
                state = "remove_support"
        } else if(state == "z_cal_qr_code") {
            state = "z_cal_start"
        } else if(state == "remove_support") {
            state = "return_print_page"
        } else if( state == "cal_issue") {
            // If we were just on the print page we want to go back to the print process
            // but if we are in the normal process we want to cancel
            if(allowReturn) {
                state = "return_print_page"
            }
            else {
                cancelManualZCalPopup.open()
            }
        } else if(state == "return_print_page" ||
                  state == "adjustments_complete") {
            // Going back will prompt to Exit the Process
            cancelManualZCalPopup.open()
        } else if (state == "z_calibration") {
            state = "measure"
        } else if(state == "insert_build_plate") {
            state = "adjustments_complete"
        } else if(state !== "updating_information") {
            resetProcess(true)
        }
    }

    z_cal_button.onClicked: {
        if(state == "z_cal_start") {
            state = "z_cal_qr_code"
        }
        else if(state == "adjustments_complete") {
            state = "insert_build_plate"
        }
        else if(state == "z_cal_qr_code" ||
                state == "insert_build_plate") {
            allowReturn = true
            // Print
            startTestPrint()
        } else if (state == "remove_support") {
            state = "measure"
        } else if (state == "measure") {
            state = "z_calibration"
        } else if (state == "z_calibration") {
            state = "updating_information"
            allowReturn = false
            if(checkForIssues()) {
                // Do Coarse Adjustments
                setCoarseAdjustments()
                resetManualCalValues()
            } else {
                // Configure Toolheads
                setNewToolheadConfigurations()
            }

        } else if (state == "cal_issue") {
            // Start Auto Cal/Clean extruders
            calibrationProceduresSwipeView.swipeToItem(CalibrationProceduresPage.AutomaticCalibrationPage)
            returnToManualCal = true

            // Button action in 'base state'
            bot.calibrateToolheads(["x","y"])
            resetProcess(false)
        } else if (state == "success") {
            // Exit
            resetProcess(true)
        } else if(state == "return_print_page") {
            if(printSuccess) {
                state = "remove_support"
            } else {
                resetProcess(false)
            }
        } else {
            state = "z_cal_qr_code"
        }
    }

    retry_button.onClicked: {
        if(state == "cal_issue") {
            resetProcess(false)
        } else if(state == "return_print_page") {
            state = "cal_issue"
        }
    }
}
