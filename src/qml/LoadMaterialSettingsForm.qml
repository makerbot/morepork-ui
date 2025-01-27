import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessStateTypeEnum 1.0

Item {
    width: 800
    height: 440
    smooth: false

    property alias materialSelectorPage: materialSelectorPage
    property alias tempSelectorPage: tempSelectorPage
    property alias selectMaterialSwipeView: selectMaterialSwipeView

    function startLoadUnloadForMaterial(tool_idx, material) {
        if(isLoadFilament) {
            load(tool_idx, false, 0, material)
        } else {
            unload(tool_idx, true, 0, material)
        }
    }

    function startLoadUnloadCustomTemperature(tool_idx, temperature) {
        // Final check to prevent a non-labs tool to heat up to high temperatures.
        // Without this check the user could swap a labs tool with a normal tool
        // when on the custom temperature selection screen and hit the load button.
        if(!isUsingExpExtruder(tool_idx+1)) {
            selectMaterialSwipeView.swipeToItem(LoadMaterialSettings.SelectMaterialPage)
            materialSwipeView.swipeToItem(MaterialPage.BasePage)
            return;
        }
        if(isLoadFilament) {
            load(tool_idx, false, temperature)
        } else {
            unload(tool_idx, true, temperature)
        }
        selectMaterialSwipeView.swipeToItem(LoadMaterialSettings.SelectMaterialPage)
    }

    enum SwipeIndex {
        SelectMaterialPage,
        SelectTemperaturePage
    }

    LoggingStackLayout {
        id: selectMaterialSwipeView
        logName: "selectMaterialSwipeView"
        currentIndex: 0

        // LoadMaterialSettings.SelectMaterialPage
        Item {
            id: itemSelectMaterial
            property var backSwiper: materialSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: true

            LoadMaterialSelector {
                id: materialSelectorPage
            }
        }

        // LoadMaterialSettings.SelectTemperaturePage
        Item {
            id: itemSelectCustomTemperature
            property var backSwiper: selectMaterialSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            CustomTempSelector {
                id: tempSelectorPage
            }
        }
    }
}
