import QtQuick 2.10
import FreStepEnum 1.0

FrePageForm {
    function startTestPrint() {
        printPage.printFromUI = true
        storage.updateCurrentThing(true)
        printPage.getPrintFileDetails(storage.currentThing)
        mainSwipeView.swipeToItem(1)
        printPage.printSwipeView.swipeToItem(2)
    }

    function startFreMaterialLoad() {
        mainSwipeView.swipeToItem(5)
        materialPage.startLoadUnloadFromUI = true
        materialPage.isLoadFilament = true
        materialPage.enableMaterialDrawer()
        bot.loadFilament(0, false, false)
        materialPage.materialSwipeView.swipeToItem(1)
    }

    continueButton {
        button_mouseArea.onClicked: {
            if(state == "wifi_setup") {
                if(bot.net.interface == "ethernet" ||
                   bot.net.interface == "wifi") {
                    fre.gotoNextStep(currentFreStep)
                }
                else {
                    inFreStep = true
                    bot.toggleWifi(true)
                    mainSwipeView.swipeToItem(3)
                    settingsPage.settingsSwipeView.swipeToItem(5)
                }
            } else if(state == "software_update") {
                inFreStep = true
                mainSwipeView.swipeToItem(3)
                settingsPage.settingsSwipeView.swipeToItem(3)
            } else if(state == "name_printer") {
                inFreStep = true
                mainSwipeView.swipeToItem(3)
                settingsPage.settingsSwipeView.swipeToItem(10)
                settingsPage.namePrinter.nameField.forceActiveFocus()
            } else if(state == "log_in") {
                inFreStep = true
                mainSwipeView.swipeToItem(3)
                settingsPage.settingsSwipeView.swipeToItem(7)
            } else if(state == "attach_extruders") {
                inFreStep = true
                if(!bot.extruderAPresent || !bot.extruderBPresent) {
                    mainSwipeView.swipeToItem(2)
                    extruderPage.itemAttachExtruder.extruder = 1
                    extruderPage.extruderSwipeView.swipeToItem(1)
                } else {
                    mainSwipeView.swipeToItem(3)
                    settingsPage.settingsSwipeView.swipeToItem(4)
//                    fre.gotoNextStep(currentFreStep)
                }
            } else if(state == "load_material") {
                inFreStep = true
                startFreMaterialLoad()
            } else if(state == "test_print") {
                inFreStep = true
                startTestPrint()
            } else if(state == "successfully_setup") {
                fre.setFreStep(FreStep.FreComplete)
            } else {
                // At base state screen
                fre.gotoNextStep(currentFreStep)
            }
        }
    }
}
