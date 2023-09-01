import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

ManualZCalibrationForm {
    property bool secondPass: false
    property int adjustment: 0

    Timer {
        id: waitForConfigs
        interval: 2500
        onTriggered: {
            state = "success"
        }
    }

    Timer {
        id: waitForCourseAdjustment
        interval: 2500
        onTriggered: {
            state = "adjustments_complete"
            adjustment = 0
        }
    }

    function getTestPrint() {
        // We could use the spool journal to determine the loaded material
        // but sticking with this way that we use everywhere else currently.
        /*var model_mat = materialPage.bay1.filamentMaterial
        var support_mat = materialPage.bay2.filamentMaterial
        var test_print_name_string = model_mat + "_" + support_mat
        var test_print_dir_string = bot.extruderATypeStr + "/" +
                                    bot.extruderBTypeStr + "/"*/
        var test_print_dir_string = "test"
        var test_print_name_string = "abs-wss1_wss1"
        /*var test_print_name_string = "abs-wss1_wss1"
        var test_print_dir_string = bot.extruderATypeStr + "/" +
                bot.extruderBTypeStr + "/"*/
       // storage.getCalibrationPrint
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

    function getValues() {
        return [calValueItem1.value, calValueItem2.value,
                calValueItem3.value, calValueItem4.value]
    }

    function setNewToolheadConfigurations() {
        var num = 0
        var calValues = getValues()
        // Average the values
        for (var i = 0; i < calValues.length; i++) {
            num += calValues[i]
        }
        var t_before = (num/calValues.length)

        console.info("Average = " + t_before)

        // Get Bz before value from sensor
        var bz_before = bot.offsetBZ
        console.info("BZ offset: " + bz_before)
        var t_after = 0.20
        var s = -0.515

        // Find offset
        var bz_after = ((t_after - t_before) / s) + bz_before
        console.info("Bz After = " + bz_after)

        // Set configs
        bot.setManualCalibrationOffset(bz_after)
        waitForConfigs.start()
    }

    function setCourseAdjustements() {
        // Get Bz before value from sensor
        var bz_before = bot.offsetBZ
        console.info("BZ offset: " + bz_before)

        // Set Course Adjustements
        var bz_new = bz_before + (adjustment == -1 ? (-0.1) : (0.1))
        console.info("BZ adjustment: " + bz_new)


        // Set configs
        bot.setManualCalibrationOffset(bz_new)
        waitForCourseAdjustment.start()
    }

    function checkForIssues() {
        var low_range_val = 0.14
        var high_range_val = 0.26
        var calValues = getValues()
        for (var i = 0; i < calValues.length; i++) {
            if(calValues[i] < low_range_val) {
                adjustment = -1
                return true
            }
            else if(calValues[i]  > high_range_val) {
                adjustment = 1
                return true
            }
        }
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
        } else if(state == "remove_support" ||
                  state == "cal_issue") {
            // Error going back will exit the process?
            cancelManualZCalPopup.open()
        } else if (state == "z_calibration") {
            state = "measure"
        } else if (state == "updating_information") {
            // Do nothing?
            //cancelManualZCalPopup.open()
            // would this work
            //state = "z_calibration"
        } else {
            state = "z_cal_start"
            resetManualCalValues()
            isInManualCalibration = false
            secondPass = false
            extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.BasePage)
        }
    }

    z_cal_button.onClicked: {
        if(state == "z_cal_start" || state == "adjustments_complete") {
            // Do print here
            startTestPrint()
            // Todo erica remove testing
            //state = "remove_support"
            //^^^
        } else if (state == "remove_support") {
            state = "measure"
        } else if (state == "measure") {
            state = "z_calibration"
        } else if (state == "z_calibration") {
            if(checkForIssues()) {
                if(secondPass) {
                    // have a bad value do not pass go
                    state = "cal_issue"
                }
                else {
                    state = "updating_information"
                    // do course adjustments
                    setCourseAdjustements()
                    resetManualCalValues()
                    secondPass = true
                }
            } else {
                state = "updating_information"
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
        } else if (state == "success") {
            // exit
            state = "z_cal_start"
            resetManualCalValues()
            isInManualCalibration = false
            secondPass = false
            extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.BasePage)
        } else {

            startTestPrint()
            //state = "remove_support"
        }

    }

    retry_button.onClicked: {
        if(state == "cal_issue") {
            state = "z_cal_start"
            resetManualCalValues()
            secondPass = false
        }
    }

}
