import QtQuick 2.4

MaterialPageForm {

    property bool isLoadFilament: false

    function toggleDrawer()
    {
        topBar.imageDrawerArrow.visible = !topBar.imageDrawerArrow.visible
        materialPageDrawer.interactive = !materialPageDrawer.interactive
    }

    bay1 {
        load_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 1
            isLoadFilament = true
            bot.loadFilament(1)
            toggleDrawer()
            materialSwipeView.swipeToItem(1)
        }
        unload_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 1
            isLoadFilament = false
            bot.unloadFilament(1)
            toggleDrawer()
            materialSwipeView.swipeToItem(1)
        }
    }

    bay2 {
        load_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 2
            isLoadFilament = true
            bot.loadFilament(0)
            toggleDrawer()
            materialSwipeView.swipeToItem(1)
        }
        unload_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 2
            isLoadFilament = false
            bot.unloadFilament(0)
            toggleDrawer()
            materialSwipeView.swipeToItem(1)
        }
    }

    cancel_mouseArea.onClicked: {
        bot.cancel()
        cancelLoadUnloadPopup.close()
        toggleDrawer()
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
