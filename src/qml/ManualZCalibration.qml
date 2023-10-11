import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

ManualZCalibrationForm {
    property bool secondPass: false
    property bool onPrintPage: false
    property int adjustment: 0
    property bool noBack: false

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
        onPrintPage = true
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

    function back() {
        if (state == "measure") {
                state = "remove_support"
        } else if(state == "z_cal_qr_code") {
            state = "z_cal_start"
        } else if(state == "remove_support") {
            state = "end_print"
        } else if( state == "cal_issue") {
            // if we were just on the print page we want to go back to the print process
            // but if we are in the normal process we want to cancel
            if(noBack) {
                cancelManualZCalPopup.open()
            }
            else {
                state = "end_print"
            }
        } else if(state == "end_print") {
            // Error going back will exit the process?
            cancelManualZCalPopup.open()
        } else if (state == "z_calibration") {
            state = "measure"
        } else if(state !== "updating_information") {
            state = "z_cal_start"
            resetManualCalValues()
            isInManualCalibration = false
            secondPass = false
            noBack = false
            onPrintPage = false
            extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.BasePage)
        }
    }

    z_cal_button.onClicked: {
        if(state == "z_cal_start") {
            state = "z_cal_qr_code"
        }
        else if(state == "z_cal_qr_code" || state == "adjustments_complete") {
            noBack = false
            // Print
            startTestPrint()
        } else if (state == "remove_support") {
            state = "measure"
        } else if (state == "measure") {
            state = "z_calibration"
        } else if (state == "z_calibration") {
            state = "updating_information"
            noBack = true
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
            extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.BasePage)
            extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.CalibrateExtrudersPage)
            returnToManualCal = true

            // Button action in 'base state'
            bot.calibrateToolheads(["x","y"])
            state = "z_cal_start"
            resetManualCalValues()
            secondPass = false
            noBack = false
        } else if (state == "success") {
            // exit
            state = "z_cal_start"
            resetManualCalValues()
            isInManualCalibration = false
            secondPass = false
            noBack = false
            extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.BasePage)
        } else if(state == "end_print") {
            if(printPageStatus) {
                state = "remove_support"
            } else {
                state = "z_cal_start"
                secondPass = false
            }
        } else {
            state = "z_cal_qr_code"
        }

    }

    retry_button.onClicked: {
        if(state == "cal_issue") {
            state = "z_cal_start"
            resetManualCalValues()
            noBack = false
            secondPass = false
        } else if(state == "end_print") {
            state = "cal_issue"
        }
    }

}
