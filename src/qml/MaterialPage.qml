import QtQuick 2.4

MaterialPageForm {

    property bool isLoadFilament: false

    function enableMaterialDrawer() {
        if(!printPage.isPrintProcess) {
            activeDrawer = materialPage.materialPageDrawer
            setDrawerState(true)
        }
    }

    bay1 {
        loadButton.button_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 1
            isLoadFilament = true
            enableMaterialDrawer()
            bot.loadFilament(0)
            materialSwipeView.swipeToItem(1)
        }

        unloadButton.button_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 1
            isLoadFilament = false
            enableMaterialDrawer()
            bot.unloadFilament(0)
            materialSwipeView.swipeToItem(1)
        }
    }

    bay2 {
        loadButton.button_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 2
            isLoadFilament = true
            enableMaterialDrawer()
            bot.loadFilament(1)
            materialSwipeView.swipeToItem(1)
        }

        unloadButton.button_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 2
            isLoadFilament = false
            enableMaterialDrawer()
            bot.unloadFilament(1)
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
    cancel_mouseArea.onPressed: {
        cancel_rectangle.color = "#0f0f0f"
    }

    cancel_mouseArea.onReleased: {
        cancel_rectangle.color = "#00000000"
    }

    continue_mouseArea.onClicked: cancelLoadUnloadPopup.close()

    continue_mouseArea.onPressed: {
        continue_rectangle.color = "#0f0f0f"
    }

    continue_mouseArea.onReleased: {
        continue_rectangle.color = "#00000000"
    }

    materialPageDrawer.buttonCancelMaterialChange.onClicked: {
        materialPageDrawer.close()
        cancelLoadUnloadPopup.open()
    }

    materialPageDrawer.buttonResume.onClicked: {
        materialPageDrawer.close()
    }
}
