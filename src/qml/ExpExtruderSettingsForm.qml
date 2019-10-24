import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 800
    height: 440
    smooth: false

    property alias defaultItem: itemSelectMaterial
    property alias materialSelectorPage: materialSelectorPage
    property alias tempSelectorPage: tempSelectorPage
    property alias selectMaterialSwipeView: selectMaterialSwipeView

    property variant expMaterialsList : [
        {label: "pla", load : 220, unload : 220},
        {label: "tough", load : 220, unload : 220},
        {label: "petg", load : 230, unload : 230},
        {label: "abs", load : 245, unload : 245},
        {label: "asa", load : 245, unload : 245},
        {label: "nylon", load : 220, unload : 220}
    ]

    function startLoadUnloadExpExtruder(temperature) {
        startLoadUnloadFromUI = true
        enableMaterialDrawer()
        loadUnloadFilamentProcess.isExternalLoadUnload = true
        loadUnloadFilamentProcess.lastHeatingTemperature = temperature
        if(isLoadFilament) {
            // loadFilament(int tool_index, bool external, bool whilePrinitng, QList<int> temperature_list)
            if(printPage.isPrintProcess &&
               bot.process.stateType == ProcessStateType.Paused) {
                bot.loadFilament(0, false, true, [temperature, 0])
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
            loadUnloadFilamentProcess.state = "preheating"
        }
        selectMaterialSwipeView.swipeToItem(0)
        materialSwipeView.swipeToItem(2)
    }

    SwipeView {
        id: selectMaterialSwipeView
        currentIndex: 0
        smooth: false
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = selectMaterialSwipeView.currentIndex
            selectMaterialSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            setCurrentItem(selectMaterialSwipeView.itemAt(itemToDisplayDefaultIndex))
            if(prevIndex == itemToDisplayDefaultIndex) {
                return;
            }
            selectMaterialSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            selectMaterialSwipeView.itemAt(prevIndex).visible = false
        }

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
