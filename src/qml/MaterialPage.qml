import QtQuick 2.4

MaterialPageForm {

    property bool isLoadFilament: false

    function setDrawerState(state)
    {
        topBar.imageDrawerArrow.visible = state
        materialPageDrawer.interactive = state
        if(state == true) {
            topBar.drawerDownClicked.connect(activeDrawer.open)
        }
        else {
            topBar.drawerDownClicked.disconnect(activeDrawer.open)
        }
    }

    bay1 {
        loadButton.button_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 1
            isLoadFilament = true
            bot.loadFilament(1)
            setDrawerState(true)
            materialSwipeView.swipeToItem(1)
        }

        unloadButton.button_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 1
            isLoadFilament = false
            bot.unloadFilament(1)
            setDrawerState(true)
            materialSwipeView.swipeToItem(1)
        }
    }

    bay2 {
        loadButton.button_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 2
            isLoadFilament = true
            bot.loadFilament(0)
            setDrawerState(true)
            materialSwipeView.swipeToItem(1)
        }

        unloadButton.button_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 2
            isLoadFilament = false
            bot.unloadFilament(0)
            setDrawerState(true)
            materialSwipeView.swipeToItem(1)
        }
    }

    cancel_mouseArea.onClicked: {
        bot.cancel()
        cancelLoadUnloadPopup.close()
        loadUnloadFilamentProcess.state = "base state"
        setDrawerState(false)
        materialSwipeView.swipeToItem(0)
    }

    continue_mouseArea.onClicked: cancelLoadUnloadPopup.close()

    materialPageDrawer.buttonCancelMaterialChange.onClicked: {
        materialPageDrawer.close()
        cancelLoadUnloadPopup.open()
    }

    materialPageDrawer.buttonResume.onClicked: {
        materialPageDrawer.close()
    }
}
