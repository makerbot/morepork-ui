import QtQuick 2.4

MaterialPageForm {

    property bool isLoadFilament: false

    function setDrawerState(state)
    {
        topBar.imageDrawerArrow.visible = state
        materialPageDrawer.interactive = state
    }

    bay1 {
        load_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 1
            isLoadFilament = true
            bot.loadFilament(1)
            setDrawerState(true)
            materialSwipeView.swipeToItem(1)
        }
        unload_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 1
            isLoadFilament = false
            bot.unloadFilament(1)
            setDrawerState(true)
            loadUnloadFilamentProcess.state = "preheating"
            materialSwipeView.swipeToItem(1)
        }
    }

    bay2 {
        load_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 2
            isLoadFilament = true
            bot.loadFilament(0)
            setDrawerState(true)
            materialSwipeView.swipeToItem(1)
        }
        unload_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 2
            isLoadFilament = false
            bot.unloadFilament(0)
            setDrawerState(true)
            loadUnloadFilamentProcess.state = "preheating"
            materialSwipeView.swipeToItem(1)
        }
    }

    cancel_mouseArea.onClicked: {
        bot.cancel()
        cancelLoadUnloadPopup.close()
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
