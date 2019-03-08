import QtQuick 2.10
import FreStepEnum 1.0
import WifiStateEnum 1.0

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
        disable_button: {
            if(state == "load_material" ||
               state == "calibrate_extruders") {
                isProcessRunning()
            }
            else {
                false
            }
        }

        button_mouseArea.onClicked: {
            if(state == "wifi_setup") {
                if(bot.net.interface == "ethernet" ||
                   bot.net.interface == "wifi") {
                    if(isfirmwareUpdateAvailable) {
                        fre.gotoNextStep(currentFreStep)
                    }
                    else {
                        fre.setFreStep(FreStep.NamePrinter)
                    }
                }
                else {
                    inFreStep = true
                    bot.toggleWifi(true)
                    bot.net.setWifiState(WifiState.Searching)
                    bot.scanWifi(true)
                    mainSwipeView.swipeToItem(3)
                    settingsPage.settingsSwipeView.swipeToItem(3)
                }
            } else if(state == "software_update") {
                inFreStep = true
                mainSwipeView.swipeToItem(3)
                settingsPage.settingsSwipeView.swipeToItem(5)
            } else if(state == "name_printer") {
                inFreStep = true
                mainSwipeView.swipeToItem(3)
                settingsPage.settingsSwipeView.swipeToItem(2)
                settingsPage.namePrinter.nameField.forceActiveFocus()
            } else if(state == "set_time_date") {
                inFreStep = true
                bot.getSystemTime()
                mainSwipeView.swipeToItem(3)
                settingsPage.settingsSwipeView.swipeToItem(7)
            } else if(state == "log_in") {
                inFreStep = true
                mainSwipeView.swipeToItem(3)
                settingsPage.settingsSwipeView.swipeToItem(4)
                settingsPage.signInPage.signInSwipeView.swipeToItem(1)
                settingsPage.signInPage.usernameTextField.forceActiveFocus()
            } else if(state == "attach_extruders") {
                inFreStep = true
                mainSwipeView.swipeToItem(2)
                extruderPage.itemAttachExtruder.extruder = 1
                extruderPage.extruderSwipeView.swipeToItem(1)
            } else if(state == "level_build_plate") {
                inFreStep = true
                mainSwipeView.swipeToItem(6)
                advancedPage.advancedSettingsSwipeView.swipeToItem(3)
            } else if(state == "calibrate_extruders") {
                inFreStep = true
                mainSwipeView.swipeToItem(3)
                settingsPage.settingsSwipeView.swipeToItem(6)
            } else if(state == "load_material") {
                inFreStep = true
                startFreMaterialLoad()
            } else if(state == "test_print") {
                inFreStep = true
                startTestPrint()
            } else if(state == "setup_complete") {
                fre.setFreStep(FreStep.FreComplete)
            } else {
                // At base state screen
                if(bot.net.interface != "ethernet" &&
                   bot.net.interface != "wifi") {
                    // Goto Wifi Setup step
                    fre.gotoNextStep(currentFreStep)
                }
                else if(isfirmwareUpdateAvailable) {
                    fre.setFreStep(FreStep.SoftwareUpdate)
                }
                else {
                    fre.setFreStep(FreStep.NamePrinter)
                }
            }
        }
    }
}
