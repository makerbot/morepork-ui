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

    function startLoadForMaterial(tool_idx, external, material) {
        load(tool_idx, external, [0,0], material)
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
        var external = isLoadFilament ? false : true
        if(isLoadFilament) {
            load(tool_idx, external, temperature)
        } else {
            unload(tool_idx, external, temperature)
        }
        selectMaterialSwipeView.swipeToItem(LoadMaterialSettings.SelectMaterialPage)
    }

    enum SwipeIndex {
        SelectMaterialPage,
        SelectTemperaturePage
    }

    LoggingSwipeView {
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
