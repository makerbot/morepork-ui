import QtQuick 2.10
import FreStepEnum 1.0
import WifiStateEnum 1.0
import MachineTypeEnum 1.0

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
        enabled: {
            if(state != "load_material" &&
               state != "calibrate_extruders") {
                !isProcessRunning()
            }
            else {
                true
            }
        }

        onClicked: {
            // The primary interaction for moving thorugh the FRE is
            // through this button which has to be clicked atleast once.
            // The NPS survey shouldn't be asked for 3 months after setting
            // up a printer or after resetting a printer both cases where
            // the user will have to go through the FRE.
            updateNPSSurveyDueDate()

            if(state == "wifi_setup") {
                if(isNetworkConnectionAvailable) {
                    fre.gotoNextStep(currentFreStep)
                }
                else {
                    inFreStep = true
                    bot.toggleWifi(true)
                    bot.net.setWifiState(WifiState.Searching)
                    bot.scanWifi(true)
                    mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                    settingsPage.settingsSwipeView.swipeToItem(SettingsPage.SystemSettingsPage)
                    settingsPage.systemSettingsPage.systemSettingsSwipeView.swipeToItem(SystemSettingsPage.WifiPage)
                }
            } else if(state == "software_update") {
                inFreStep = true
                mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.SystemSettingsPage)
                settingsPage.systemSettingsPage.systemSettingsSwipeView.swipeToItem(SystemSettingsPage.FirmwareUpdatePage)
            } else if(state == "set_time_date") {
                inFreStep = true
                bot.getSystemTime()
                mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.SystemSettingsPage)
                settingsPage.systemSettingsPage.systemSettingsSwipeView.swipeToItem(SystemSettingsPage.TimePage)
                settingsPage.systemSettingsPage.timePage.timeSwipeView.swipeToItem(TimePage.SetTimeZone)
            } else if(state == "attach_extruders") {
                inFreStep = true
                mainSwipeView.swipeToItem(MoreporkUI.MaterialPage)
                materialPage.itemAttachExtruder.extruder = 1
                materialPage.itemAttachExtruder.state = "base state"
                materialPage.materialSwipeView.swipeToItem(MaterialPage.AttachExtruderPage)
            } else if(state == "level_build_plate") {
                inFreStep = true
                mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.BuildPlateSettingsPage)
                settingsPage.buildPlateSettingsPage.buildPlateSettingsSwipeView.swipeToItem(BuildPlateSettingsPage.AssistedLevelingPage)
                settingsPage.buildPlateSettingsPage.assistedLevel.state = "fre_start_screen"
            } else if(state == "calibrate_extruders") {
                inFreStep = true
                mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.ExtruderSettingsPage)
                settingsPage.extruderSettingsPage.extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.CalibrateExtrudersPage)
                settingsPage.extruderSettingsPage.toolheadCalibration.state = "calibrating"
                bot.calibrateToolheads(["x","y"])
            } else if(state == "material_case_setup") {
                inFreStep = true
                mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.ExtruderSettingsPage)
                settingsPage.extruderSettingsPage.extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.MaterialCaseSetup)
            } else if(state == "load_material") {
                inFreStep = true
                startFreMaterialLoad()
            } else if(state == "test_print") {
                inFreStep = true
                startTestPrint()
            } else if(state == "log_in") {
                inFreStep = true
                mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.SystemSettingsPage)
                settingsPage.systemSettingsPage.systemSettingsSwipeView.swipeToItem(SystemSettingsPage.AuthorizeAccountsPage)
                settingsPage.systemSettingsPage.authorizeAccountPage.authorizeAccountWithCodePage.beginAuthWithCode()
                settingsPage.systemSettingsPage.authorizeAccountPage.authorizeAccountSwipeView.swipeToItem(AuthorizeAccountPage.AuthorizeWithCode)
            } else if(state == "magma_setup_guide1") {
                state = "magma_setup_guide2"
            } else {
                // For all screens not listed above, the default behavior
                // is to go to the next step
                fre.gotoNextStep(currentFreStep)


            }
        }

        help {
            onClicked: {
                // Currently every help button in the FRE shows the same help
                helpPopup.state = "fre"
                helpPopup.open()
            }
        }
    }

    skipButton {
        onClicked: {
            if (state == "name_printer") {
                // Skipping this step is the default
                inFreStep = true
                mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.SystemSettingsPage)
                settingsPage.systemSettingsPage.systemSettingsSwipeView.swipeToItem(SystemSettingsPage.ChangePrinterNamePage)
                settingsPage.namePrinter.nameField.forceActiveFocus()
            } /*else if(state == "base state" || state == "welcome") {
                fre.setFreStep(FreStep.StartSetLanguage)
            } BW-5871 */
            else if(state == "magma_setup_guide1") {
                 fre.setFreStep(FreStep.Welcome)
            } else if(state == "magma_setup_guide2") {
                state = "magma_setup_guide1"
            } else {
                // Every page that does not have custom logic for this should
                // prompt to skip to the next step.
                skipFreStepPopup.open()
            }
        }
    }
}
