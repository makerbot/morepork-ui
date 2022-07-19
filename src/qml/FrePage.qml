import QtQuick 2.10
import FreStepEnum 1.0
import WifiStateEnum 1.0

FrePageForm {
    function getTestPrint() {
        // We could use the spool journal to determine the loaded material
        // but sticking with this way that we use everywhere else currently.
        var model_mat = materialPage.bay1.filamentMaterial
        var support_mat = materialPage.bay2.filamentMaterial
        var test_print_name_string = model_mat + "_" + support_mat
        var test_print_dir_string = bot.extruderATypeStr + "/" +
                                    bot.extruderBTypeStr + "/"
        storage.getTestPrint(test_print_dir_string, test_print_name_string)
    }

    function startTestPrint() {
        printPage.printFromUI = true
        printPage.startPrintSource = PrintPage.FromLocal
        getTestPrint()
        printPage.getPrintFileDetails(storage.currentThing)
        mainSwipeView.swipeToItem(MoreporkUI.PrintPage)
        printPage.printSwipeView.swipeToItem(PrintPage.StartPrintConfirm)
    }

    function startFreMaterialLoad() {
        mainSwipeView.swipeToItem(MoreporkUI.MaterialPage)
        materialPage.startLoadUnloadFromUI = true
        materialPage.isLoadFilament = true
        materialPage.enableMaterialDrawer()
        bot.loadFilament(0, false, false)
        materialPage.materialSwipeView.swipeToItem(MaterialPage.LoadUnloadPage)
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
                if(isNetworkConnectionAvailable) {
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
                    mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                    settingsPage.settingsSwipeView.swipeToItem(SettingsPage.WifiPage)
                }
            } else if(state == "software_update") {
                inFreStep = true
                mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.FirmwareUpdatePage)
            } else if(state == "name_printer") {
                inFreStep = true
                mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.ChangePrinterNamePage)
                settingsPage.namePrinter.nameField.forceActiveFocus()
            } else if(state == "set_time_date") {
                inFreStep = true
                bot.getSystemTime()
                mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.TimePage)
            } else if(state == "attach_extruders") {
                inFreStep = true
                mainSwipeView.swipeToItem(MoreporkUI.ExtruderPage)
                extruderPage.itemAttachExtruder.extruder = 1
                extruderPage.itemAttachExtruder.state = "base state"
                extruderPage.extruderSwipeView.swipeToItem(ExtruderPage.AttachExtruderPage)
            } else if(state == "level_build_plate") {
                inFreStep = true
                mainSwipeView.swipeToItem(MoreporkUI.AdvancedPage)
                advancedPage.advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.AssistedLevelingPage)
            } else if(state == "calibrate_extruders") {
                inFreStep = true
                mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.CalibrateExtrudersPage)
            } else if(state == "load_material") {
                inFreStep = true
                startFreMaterialLoad()
            } else if(state == "test_print") {
                inFreStep = true
                startTestPrint()
            } else if(state == "log_in") {
                // login has a separate flow within the fre screen.
            } else if(state == "setup_complete") {
                fre.setFreStep(FreStep.FreComplete)
            } else {
                // At base state screen
                if(!isNetworkConnectionAvailable) {
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
