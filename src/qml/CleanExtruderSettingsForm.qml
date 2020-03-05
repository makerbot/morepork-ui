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
    height: 440
    smooth: false

    property alias defaultItem: itemCleanExtrudersSelectMaterial
    property alias cleanExtruderMaterialSelectorPage: cleanExtruderMaterialSelectorPage
    property alias cleanExtruderTempSelectorPage: cleanExtruderTempSelectorPage
    property alias cleanExtrudersSelectMaterialSwipeView: cleanExtrudersSelectMaterialSwipeView

    property variant nozzleCleaningTempList : [
        {label: "pla", temperature : 190},
        {label: "tough", temperature : 190},
        {label: "petg", temperature : 190},
        {label: "abs", temperature : 240},
        {label: "asa", temperature : 240},
        {label: "nylon", temperature : 190}
    ]

    SwipeView {
        id: cleanExtrudersSelectMaterialSwipeView
        currentIndex: 0
        smooth: false
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = cleanExtrudersSelectMaterialSwipeView.currentIndex
            cleanExtrudersSelectMaterialSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            if(prevIndex == itemToDisplayDefaultIndex) {
                return;
            }
            if(itemToDisplayDefaultIndex == 0) {
                if(bot.process.type == ProcessType.CalibrationProcess) {
                    // Use back button action specific to calibration process UI
                    setCurrentItem(settingsPage.settingsSwipeView.itemAt(6))
                } else {
                    // Use back button action specific to Nozzle cleaning process UI
                    setCurrentItem(advancedSettingsSwipeView.itemAt(9))
                }
            } else {
                setCurrentItem(cleanExtrudersSelectMaterialSwipeView.itemAt(itemToDisplayDefaultIndex))
            }
            cleanExtrudersSelectMaterialSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            cleanExtrudersSelectMaterialSwipeView.itemAt(prevIndex).visible = false
        }

        // cleanExtrudersSelectMaterialSwipeView.index = 0
        Item {
            id: itemCleanExtrudersSelectMaterial
            smooth: false
            visible: true

            CleanExtruderMaterialSelector {
                id: cleanExtruderMaterialSelectorPage

            }
        }

        // cleanExtrudersSelectMaterialSwipeView.index = 1
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
