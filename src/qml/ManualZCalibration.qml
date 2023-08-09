import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

ManualZCalibrationForm {


    //property variant calValues: []

    Timer {
        id: waitForConfigs
        interval: 2500
        onTriggered: {
            state = "success"
        }
    }

    function getTestPrint() {

    }
    function startTestPrint() {
        getTestPrint()
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
        var avg = (num/calValues.length)

        console.log("Average" + avg)

        // Find offset


        // Set configs

        waitForConfigs.start()
    }

    function checkForIssues() {
        var low_range_val = 0.14
        var high_range_val = 0.26
        var calValues = getValues()
        for (var i = 0; i < calValues.length; i++) {
            if(calValues[i] < low_range_val || calValues[i]  > high_range_val) {
                return true
            }
        }
        return false
    }

    function back() {
        if (state == "measure") {
                state = "remove_support"
        } else if(state == "remove_support") {
            // Error going back will exit the process?
        } else if (state == "z_calibration") {
            state = "measure"
        } else if (state == "updating_information") {
            // would this work
            state = "z_calibration"
        } else {
            state = "z_cal_start"
            extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.BasePage)
        }
    }

    z_cal_button.onClicked: {
        if(state == "z_cal_start") {
            // Do print here
            // Todo erica remove testing
            state = "remove_support"
            //^^^
        } else if (state == "remove_support") {
            state = "measure"
        } else if (state == "measure") {
            state = "z_calibration"
        } else if (state == "z_calibration") {
            if(checkForIssues()) {
                // have a bad value do not pass go
                manual_calibration_issue_popup.open()
            } else {
                state = "updating_information"
                setNewToolheadConfigurations()
                // save values etc.
            }
        } else if (state == "success") {
            // exit
            state = "z_cal_start"
            extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.BasePage)
        } else {
            state = "remove_support"
        }

    }

}
