import QtQuick 2.4

MaterialPageForm {

    property bool isLoadFilament: false

    bay1 {
        load_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 1
            isLoadFilament = true
            bot.loadFilament(1)
            materialSwipeView.swipeToItem(1)
        }
        unload_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 1
            isLoadFilament = false
            bot.unloadFilament(1)
            materialSwipeView.swipeToItem(1)
        }
    }

    bay2 {
        load_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 2
            isLoadFilament = true
            bot.loadFilament(0)
            materialSwipeView.swipeToItem(2)
        }
        unload_mouseArea.onClicked: {
            loadUnloadFilamentProcess.bayID = 2
            isLoadFilament = false
            bot.unloadFilament(0)
            materialSwipeView.swipeToItem(2)
        }
    }

    cancel_mouseArea.onClicked: {
        bot.cancel()
        cancelLoadUnloadPopup.close()
        materialSwipeView.swipeToItem(0)
    }

    continue_mouseArea.onClicked: cancelLoadUnloadPopup.close()
}
