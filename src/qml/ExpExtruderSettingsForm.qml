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

    property variant expMaterialsList : [
        {label: "pla",      load : 220, unload : 180},
        {label: "tough",    load : 220, unload : 180},
        {label: "petg",     load : 230, unload : 200},
        {label: "abs",      load : 245, unload : 245},
        {label: "asa",      load : 245, unload : 245},
        {label: "nylon",    load : 220, unload : 180},
        {label: "pc-abs",   load : 245, unload : 245},
        {label: "pc-abs-fr",load : 245, unload : 245},
        {label: "nylon-cf", load : 250, unload : 250},
        {label: "nylon-12-cf",load : 250, unload : 250}
    ]

    property variant hTExpMaterialsList : [
        {label: "pekk", load : 350, unload : 350}
    ]

    function startLoadUnloadExpExtruder(temperature) {
        if(!isUsingExpExtruder(1)) {
            selectMaterialSwipeView.swipeToItem(ExpExtruderSettings.SelectMaterialPage)
            materialSwipeView.swipeToItem(MaterialPage.BasePage)
            return;
        }
        startLoadUnloadFromUI = true
        enableMaterialDrawer()
        loadUnloadFilamentProcess.isExternalLoadUnload = true
        loadUnloadFilamentProcess.lastHeatingTemperature = temperature
        if(isLoadFilament) {
            // loadFilament(int tool_index, bool external, bool whilePrinitng, QList<int> temperature_list)
            if(printPage.isPrintProcess &&
               bot.process.stateType == ProcessStateType.Paused) {
                // When using experimental extruder, loading
                // mid-print should use external loading.
                bot.loadFilament(0, true, true, [temperature, 0])
            }
            else {
                bot.loadFilament(0, false, false, [temperature,0])
            }
        } else {
            // unloadFilament(int tool_index, bool external, bool whilePrinitng, QList<int> temperature_list)
            if(printPage.isPrintProcess &&
               bot.process.stateType == ProcessStateType.Paused) {
                bot.unloadFilament(0, true, true, [temperature,0])
            }
            else {
                bot.unloadFilament(0, true, false, [temperature,0])
            }
        }
        loadUnloadFilamentProcess.state = "preheating"
        selectMaterialSwipeView.swipeToItem(ExpExtruderSettings.SelectMaterialPage)
        materialSwipeView.swipeToItem(MaterialPage.LoadUnloadPage)
    }

    enum SwipeIndex {
        SelectMaterialPage,
        SelectTemperaturePage
    }

    LoggingSwipeView {
        id: selectMaterialSwipeView
        currentIndex: 0

        // selectMaterialSwipeView.index = 0
        Item {
            id: itemSelectMaterial
            property var backSwiper: materialSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: true

            ExpExtruderMaterialSelector {
                id: materialSelectorPage

            }
        }

        // selectMaterialSwipeView.index = 1
        Item {
            id: itemSelectCustomTemperature
            property var backSwiper: selectMaterialSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            ExpExtruderTempSelector {
                id: tempSelectorPage

            }
        }
    }
}
