// This component is used in two places in the UI for selecting
// custom cleaning temperature for the labs extruder
// 1.) Standalone Nozzle Cleaning Process
// 2.) Interim nozzle cleaning steps in Calibration process
import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    width: 800
    height: 408
    smooth: false

    property alias cleanExtruderMaterialSelectorPage: cleanExtruderMaterialSelectorPage
    property alias cleanExtruderTempSelectorPage: cleanExtruderTempSelectorPage
    property alias cleanExtrudersSelectMaterialSwipeView: cleanExtrudersSelectMaterialSwipeView

    property variant nozzleCleaningTempList : [
        {label: "pla", temperature : 190},
        {label: "tough", temperature : 190},
        {label: "petg", temperature : 190},
        {label: "abs", temperature : 240},
        {label: "abs-r", temperature : 260},
        {label: "abs-cf", temperature : 270},
        {label: "asa", temperature : 240},
        {label: "nylon", temperature : 190}
    ]

    enum SwipeIndex {
        MaterialSelector,
        TemperatureSelector
    }

    LoggingStackLayout {
        id: cleanExtrudersSelectMaterialSwipeView
        logName: "cleanExtrudersSelectMaterialSwipeView"
        currentIndex: CleanExtruderSettings.MaterialSelector

        function customSetCurrentItem(swipeToIndex) {
            if(swipeToIndex == CleanExtruderSettings.MaterialSelector) {
                if(bot.process.type == ProcessType.CalibrationProcess) {
                    // Use back button action specific to calibration process UI
                    setCurrentItem(extruderSettingsSwipeView.itemAt(ExtruderSettingsPage.AutomaticCalibrationPage))
                } else {
                    // Use back button action specific to Nozzle cleaning process UI
                    setCurrentItem(extruderSettingsSwipeView.itemAt(ExtruderSettingsPage.CleanExtrudersPage))
                }
                return true
            }
        }

        // CleanExtruderSettings.MaterialSelector
        Item {
            id: itemCleanExtrudersSelectMaterial
            smooth: false
            visible: true

            CleanExtruderMaterialSelector {
                id: cleanExtruderMaterialSelectorPage

            }
        }

        // CleanExtruderSettings.TemperatureSelector
        Item {
            id: itemCleanExtrudersSelectCustomTemperature
            property var backSwiper: cleanExtrudersSelectMaterialSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            CleanExtruderTempSelector {
                id: cleanExtruderTempSelectorPage

            }
        }
    }
}
