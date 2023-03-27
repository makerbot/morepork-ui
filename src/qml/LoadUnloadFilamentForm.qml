import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0
import ErrorTypeEnum 1.0
import ExtruderTypeEnum 1.0
import MachineTypeEnum 1.0

LoggingItem {
    itemName: "LoadUnloadFilament"
    id: loadUnloadForm
    width: 800
    height: 420

    property alias snipMaterial: snipMaterial
    property alias acknowledgeButton: contentRightItem.buttonPrimary
    property alias retryButton: contentRightItem.buttonSecondary1
    property bool snipMaterialAlertAcknowledged: false
    property bool bayFilamentSwitch: false
    property bool extruderFilamentSwitch: false
    property int retryTemperature: 0
    property string retryMaterial: "None"
    property int bayID: 0
    property bool isExpExtruder: bayID == 1 ? bay1.usingExperimentalExtruder : false
    property int currentActiveTool: bot.process.currentToolIndex + 1
    // Hold onto the current bay ID even after the process completes
    onCurrentActiveToolChanged: {
        if(currentActiveTool > 0) {
            bayID = currentActiveTool
            // Immediately check spool validity if a tool
            // starts loading. We also check when we get
            // spool validity check notification and also
            // when spool a spool is detected and details
            // fetched.
            isMaterialMismatch = false
            isMaterialValid = false
            if(bot.process.type == ProcessType.Load) {
                if(materialValidityCheck()) {
                    if(materialWarningPopup.opened) {
                        materialWarningPopup.close()
                    }
                    // When loading only check for moisture alert when
                    // the material is valid and we aren't purging
                    // (i.e. the spool is already in place on the filament
                    // bay)
                    if(!extruderFilamentSwitch) {
                        maybeShowMoistureWarningPopup(bayID)
                    }
                }
            } else if(bot.process.type == ProcessType.Unload) {
                // Always check for moisture alert when unloading.
                maybeShowMoistureWarningPopup(bayID)
            }
        }
    }

    property bool isMaterialValid: false
    property bool isUnknownMaterial: false

    property bool isSpoolDetailsReady: bayID == 1 ?
                                       bay1.spoolDetailsReady :
                                       bay2.spoolDetailsReady

    onIsSpoolDetailsReadyChanged: {
        if(bot.process.type == ProcessType.Load) {
            if(isSpoolDetailsReady) {
                if(materialValidityCheck()) {
                    bot.acknowledgeMaterial(true)
                    // Check for moisture alert anytime a valid
                    // material is placed on the bay when loading.
                    maybeShowMoistureWarningPopup(bayID)
                } else {
                    isMaterialValid = false
                }
            }
            else {
                isMaterialValid = false
                materialWarningPopup.close()
            }
        }
    }

    // Also add spool checksum to this whenever thats
    // ready.
    function materialValidityCheck() {
        var bay = ((bayID == 1) ? bay1 : bay2)
        if(bay.isMaterialValid) {
            isMaterialValid = true
            checkForABSR(bayID)
            return true
        }
        else if(bay.isUnknownMaterial) {
            isUnknownMaterial = true
            return false
        }
        else {
            isMaterialMismatch = true
            return false
        }
    }

    property bool usingExpExtruder: {
        bayID == 1 ? bay1.usingExperimentalExtruder :
                     bay2.usingExperimentalExtruder
    }
    property string materialName: bayID == 1 ? bay1.filamentMaterialName :
                                               bay2.filamentMaterialName

    function delayedEnableRetryButton() {
        // Immediately starting the load/unload process
        // after it completes, presumably while kaiten is
        // still not fully finished cleaning up, causes it
        // to not start properly, so disabling the retry
        // button and then enabling after a few seconds is
        // a quick hacky fix for this before launch.
        contentRightItem.buttonSecondary1.enabled = false
        enableRetryButton.start()
    }

    property int errorCode
    property bool doingAutoUnload: false
    signal processDone
    property int currentState: bot.process.stateType
    property int errorType: bot.process.errorType

    onErrorTypeChanged: {
        if (errorType === ErrorType.DrawerOutOfFilament &&
                currentState === ProcessStateType.UnloadingFilament) {
            doingAutoUnload = true
        }
    }
    onCurrentStateChanged: {
        if (currentState != ProcessStateType.UnloadingFilament) {
            doingAutoUnload = false
        }
        switch(currentState) {
        case ProcessStateType.Stopping:
        case ProcessStateType.Done:
            snipMaterialAlertAcknowledged = false
            delayedEnableRetryButton()
            // (sorry) Update 2023 (from Shirley) sorry about the janky error checking here ;) 
            if(bot.process.errorCode > 0 && bot.process.errorCode != 83) {
                errorCode = bot.process.errorCode
                state = "error"
            }
            else if(bot.process.type == ProcessType.Load) {
                // Cancelling Load/Unload ends with 'done' step
                // but the UI shouldn't go into load/unload
                // successful state, but to the default state.
                if(!materialChangeCancelled) {
                    state = "loaded_filament"
                }
                else {
                    // Moving to default state is handled in cancel
                    // button onClicked action, we just reset the
                    // cancelled flag here.
                    materialChangeCancelled = false
                }
            }
            else if(bot.process.type == ProcessType.Unload) {
                // Cancelling Load/Unload ends with 'done' step
                // but the UI shouldn't go into load/unload
                // successful state, but to the default state.
                if(!materialChangeCancelled) {
                    state = "unloaded_filament"
                }
                else {
                    // Moving to default state is handled in cancel
                    // button onClicked action, we just reset the
                    // cancelled flag here.
                    materialChangeCancelled = false
                }
            }
            //The case when loading/unloading is stopped by user
            //in the middle of print process. Then the bot goes to
            //'Stopping' step and then to 'Paused' step, but to
            // differentiate successful stopping (i.e. stopping
            // extrusion) and cancelling, we monitor the
            // materialChangeCancelled flag. Since the bot goes to
            // paused state afterwards we also need to monitor
            // the flag there.
            else if(printPage.isPrintProcess) {
                delayedEnableRetryButton()
                if(materialChangeCancelled) {
                    state = "base state"
                    materialSwipeView.swipeToItem(MaterialPage.BasePage)
                    // If cancelled out of load/unload while in print process
                    // enable print drawer to set UI back to printing state.
                    setDrawerState(false)
                    activeDrawer = printPage.printingDrawer
                    setDrawerState(true)
                    if(inFreStep &&
                       bot.process.type == ProcessType.Print) {
                        mainSwipeView.swipeToItem(MoreporkUI.PrintPage)
                    }
                }
                else {
                    isLoadFilament ? state = "loaded_filament" :
                                     state = "unloaded_filament"
                }
                if(bot.process.errorCode > 0 && bot.process.errorCode != 83) {
                    errorCode = bot.process.errorCode
                    state = "error"
                }
            }
            break;
            //The case when loading/unloading completes normally by
            //itself, in the middle of print process. Then the bot doesn't
            //go to 'Stopping' step, but directly to 'Paused' step.
        case ProcessStateType.Paused:
            if(materialChangeCancelled) {
                materialChangeCancelled = false
            }
            else {
                isLoadFilament ? state = "loaded_filament" :
                                 state = "unloaded_filament"
            }
            break;
        default:
            break;
        }
    }

    Timer {
        id: enableRetryButton
        interval: 3000
        onTriggered: {
            contentRightItem.buttonSecondary1.enabled = true
        }
    }
    SnipMaterialScreen {
        id: snipMaterial
        z: 1
        anchors.verticalCenterOffset: -20
        visible: !snipMaterialAlertAcknowledged && !isExpExtruder && !bayFilamentSwitch
    }

    ExpExtruderInstructionsScreen {
        id: expExtruderInstructions
        z: 1
        visible: false
    }

    UserAssistedLoadInstructions {
        id: userAssistedLoadInstructions
        z: 1
        visible: false
    }

    ContentLeftSide {
        id: contentLeftItem
        smooth: false
        animatedImage.visible: true
    }

    ContentRightSide {
        id: contentRightItem

        textHeader {
            text: qsTr("OPEN BAY %1").arg(bayID)
            visible: true
        }

        numberedSteps {
            steps: [
                qsTr("Press side latch to unlock and\nopen bay %1").arg(bayID),
                qsTr("Place a %1 material spool in\nthe bay").arg(
                                    bayID == 1 ? qsTr("Model") : qsTr("Support")),
                qsTr("Push the end of the material into\nthe slot until you feel it being\npulled in.")
            ]
        }

        textBody {
            text: "\n\n\n"
        }
        buttonPrimary {
            text: qsTr("CONTINUE")
        }
        buttonSecondary1 {
            text: qsTr("RETRY")   
        }

        temperatureStatus {
            showExtruder: (bayID == 1) ? TemperatureStatus.Extruder.Model : TemperatureStatus.Extruder.Support
        }

    }

    states: [
        State {
            name: "feed_filament"
            when: isMaterialValid && !isExpExtruder && !bayFilamentSwitch &&
                  bot.process.stateType == ProcessStateType.Preheating &&
                  (bot.process.type == ProcessType.Load ||
                   bot.process.type == ProcessType.Print)

            PropertyChanges {
                target: snipMaterial
                visible: !snipMaterialAlertAcknowledged && !isExpExtruder
            }

            PropertyChanges {
                target: expExtruderInstructions
                visible: false
            }

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: shouldUserAssistDrawerLoading(bayID)
            }

            PropertyChanges {
                target: contentRightItem.textHeader
                text: {
                    if (bot.hasFilamentBay) {
                        qsTr("%1 DETECTED").arg(materialName)
                    } else {
                        qsTr("LOADING FILAMENT")
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: qsTr("Push the end of the material into the slot until you feel it being pulled in.")
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                visible: false
                text: qsTr("CONTINUE")
            }

            PropertyChanges {
                target: contentRightItem.buttonSecondary1
                visible: false
            }

            PropertyChanges {
                target: contentLeftItem.image
                visible: true
                source: bayID == 1 ?
                            "qrc:/img/insert_filament_bay1.gif" :
                            "qrc:/img/insert_filament_bay2.gif"
            }
            PropertyChanges {
                target: contentLeftItem.animatedImage
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.numberedSteps
                visible: true
            }

            PropertyChanges {
                target: contentLeftItem.loadingIcon
                visible: false
            }
            PropertyChanges {
                target: contentRightItem.textBody1
                visible: false
            }
        },
        State {
            name: "pushing_filament"
            when: (bayFilamentSwitch && !extruderFilamentSwitch) &&
                   bot.process.stateType == ProcessStateType.Preheating &&
                   (bot.process.type == ProcessType.Load ||
                   bot.process.type == ProcessType.Unload ||
                   bot.process.type == ProcessType.Print)

            PropertyChanges {
                target: snipMaterial
                visible: !snipMaterialAlertAcknowledged && !isExpExtruder
            }

            PropertyChanges {
                target: expExtruderInstructions
                visible: false
            }

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: shouldUserAssistDrawerLoading(bayID)
            }

            PropertyChanges {
                target: contentRightItem.textHeader
                text: qsTr("MATERIAL LOADING")
                anchors.topMargin: 160
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: qsTr("Helper motors are pushing material\nup to the extruder. This can take up to\n30 seconds.")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.temperatureStatus
                visible: false
            }

            PropertyChanges {
                target: contentLeftItem.animatedImage
                visible: false
            }

            PropertyChanges {
                target: contentLeftItem.image
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.numberedSteps
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.buttonSecondary1
                visible: false
            }

            PropertyChanges {
                target: contentLeftItem.loadingIcon
                loading: true
                visible: true
            }
            PropertyChanges {
                target: contentRightItem.textBody1
                visible: false
            }
        },
        State {
            name: "preheating"
            when: (extruderFilamentSwitch || isExpExtruder) &&
                  bot.process.stateType == ProcessStateType.Preheating &&
                  (bot.process.type == ProcessType.Load ||
                   bot.process.type == ProcessType.Unload ||
                   bot.process.type == ProcessType.Print)

            PropertyChanges {
                target: snipMaterial
                visible: false
            }

            PropertyChanges {
                target: expExtruderInstructions
                visible: {
                    // Dont show this screen when either of the
                    // switches are triggered which means the user
                    // has already chosen their loading style.
                    // Show this creen only during a load process
                    // and only when external loading i.e. using
                    // exp. extruder.
                    // Show this when the extruder is close to the
                    // target temperature. The target temp. non
                    // check is required to accomodate the kaiten
                    // notification delay and ignore the condition
                    // (currentTemperature + 30 >= 0).

                    !bayFilamentSwitch &&
                    !extruderFilamentSwitch &&
                    (bot.process.type == ProcessType.Print ||
                     bot.process.type == ProcessType.Load) &&
                    isExpExtruder &&
                    targetTemperature > 0 &&
                    ((currentTemperature + 30) >= targetTemperature)
                }
            }

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.textHeader
                text: qsTr("HEATING")
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: ""
            }

            PropertyChanges {
                target: contentRightItem.temperatureStatus
                visible: true
            }

            PropertyChanges {
                target: contentLeftItem.animatedImage
                visible: false
            }

            PropertyChanges {
                target: contentLeftItem.image
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.numberedSteps
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.buttonSecondary1
                visible: false
            }

            PropertyChanges {
                target: contentLeftItem.loadingIcon
                loading: true
                visible: true
            }
            PropertyChanges {
                target: contentRightItem.textBody1
                visible: false
            }
        },
        State {
            name: "extrusion"
            when: bot.process.stateType == ProcessStateType.Extrusion &&
                  (bot.process.type == ProcessType.Load ||
                   bot.process.type == ProcessType.Print)

            PropertyChanges {
                target: snipMaterial
                visible: false
            }

            PropertyChanges {
                target: expExtruderInstructions
                visible: false
            }

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.textHeader
                text: qsTr("EXTRUSION CONFIRMATION")
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: {
                    qsTr("Look inside of the printer and wait until you see material begin to extrude.") +
                           ((shouldUserAssistPurging(bayID) ?
                             qsTr("\n\n%1 may require assistance to extrude. ").arg(materialName) +
                             qsTr("If you don't see the filament extruding, gently push it in at the filament bay slot.") :
                                ""))
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                visible: true
                text: qsTr("CONFIRM\nMATERIAL EXTRUSION")
            }

            PropertyChanges {
                target: contentRightItem.buttonSecondary1
                visible: false
            }

            PropertyChanges {
                target: contentLeftItem.animatedImage
                visible: false
            }

            PropertyChanges {
                target: contentLeftItem.image
                source: bayID == 1 ?
                            "qrc:/img/confirm_extrusion_1.png" :
                            "qrc:/img/confirm_extrusion_2.png"
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.numberedSteps
                visible: false
            }

            PropertyChanges {
                target: contentLeftItem.loadingIcon
                visible: false
            }
            PropertyChanges {
                target: contentRightItem.textBody1
                visible: false
            }
        },
        State {
            name: "unloading_filament"
            when: (bot.process.stateType == ProcessStateType.UnloadingFilament ||
                   bot.process.stateType == ProcessStateType.CleaningUp) &&
                  (bot.process.type == ProcessType.Unload ||
                   bot.process.type == ProcessType.Load ||
                   bot.process.type == ProcessType.Print)

            PropertyChanges {
                target: snipMaterial
                visible: false
            }

            PropertyChanges {
                target: expExtruderInstructions
                visible: false
            }

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.textHeader
                text: {
                    doingAutoUnload ?  qsTr("OUT OF FILAMENT") : qsTr("MATERIAL\nUNLOADING")
                }
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: {
                    doingAutoUnload ?
                        qsTr("Please wait while the remaining material backs out of the printer.") :
                        qsTr("The material is backing out of the extruder, please wait.")
                }
                visible: true
            }

            PropertyChanges {
                target: contentLeftItem.animatedImage
                visible: false
            }

            PropertyChanges {
                target: contentLeftItem.image
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.numberedSteps
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.buttonSecondary1
                visible: false
            }

            PropertyChanges {
                target: contentLeftItem.loadingIcon
                loading: true
                visible: true
            }
            PropertyChanges {
                target: contentRightItem.textBody1
                visible: false
            }
        },
        State {
            name: "loaded_filament"
            //this state doesn't have a when condiiton unlike others and
            //instead the switch case above is used to get into this state,
            //since we need the UI to be held at this screen
            //even after the process has completed, until the user presses 'done'.

            PropertyChanges {
                target: snipMaterial
                visible: false
            }

            PropertyChanges {
                target: expExtruderInstructions
                visible: false
            }

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.textHeader
                text: qsTr("CLEAR EXCESS MATERIAL AFTER EXTRUDER COOLS DOWN")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: qsTr("Wait a few moments until the material has cooled. Close the build chamber and material drawer.")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                visible: true
                text: {
                    if(inFreStep) {
                        if(bot.process.type == ProcessType.Print) {
                            qsTr("DONE")
                        }
                        else if(bot.process.type == ProcessType.None) {
                            if(bayID == 1) {
                                qsTr("NEXT: LOAD SUPPORT MATERIAL")
                            } else if(bayID == 2) {
                                qsTr("DONE")
                            }
                        }
                    }
                    else {
                        qsTr("DONE")
                    }
                }
            }

            PropertyChanges {
                target: contentRightItem.buttonSecondary1
                text: {
                    if(inFreStep) {
                        if(bot.process.type == ProcessType.Print) {
                            qsTr("RETRY PURGING")
                        }
                        else if(bot.process.type == ProcessType.None) {
                            qsTr("RETRY LOADING")
                        }
                    }
                    else {
                        qsTr("RETRY LOADING")
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: contentLeftItem.animatedImage
                visible: true
                source: bayID == 1 ?
                            "qrc:/img/close_bay1.gif" :
                            "qrc:/img/close_bay2.gif"
            }

            PropertyChanges {
                target: contentLeftItem.image
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.temperatureStatus
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.numberedSteps
                visible: false
            }

            PropertyChanges {
                target: contentLeftItem.loadingIcon
                visible: false
            }
            PropertyChanges {
                target: contentRightItem.textBody1
                visible: false
            }
        },
        State {
            name: "unloaded_filament"
            //this state doesn't have a when condiiton unlike others and
            //instead the switch case above is used to get into this state,
            //since we need the UI to be held at this screen
            //even after the process has completed, until the user presses 'done'.

            PropertyChanges {
                target: snipMaterial
                visible: false
            }

            PropertyChanges {
                target: expExtruderInstructions
                visible: false
            }

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.textHeader
                text: qsTr("REWIND SPOOL")
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: {
                    if(bot.machineType == MachineType.Magma) {
                        qsTr("Open the latch to access the material case. Carefully rewind the material onto the spool and seal in bag.")
                    }else {
                        qsTr("Open material bay %1 and carefully rewind the material onto the spool. Secure the end of the material inside the smart spool bag and seal. Close the bay door.").arg(bayID)
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.textBody1
                visible: (bot.machineType == MachineType.Magma)
                text: qsTr("Close the latch to prevent moisture intake.")
                font.weight: Font.Normal
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                visible: true
                text: qsTr("DONE")
            }

            PropertyChanges {
                target: contentRightItem.buttonSecondary1
                text: {
                    if(inFreStep) {
                        if(bot.process.type == ProcessType.Print) {
                            qsTr("RETRY UNLOADING")
                        }
                        else if(bot.process.type == ProcessType.None) {
                            qsTr("RETRY UNLOADING")
                        }
                    }
                    else {
                        qsTr("RETRY UNLOADING")
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: contentLeftItem.animatedImage
                visible: bot.machineType != MachineType.Magma
                source: bayID == 1 ?
                            "qrc:/img/rewind_spool_1.gif" :
                            "qrc:/img/rewind_spool_2.gif"
            }

            PropertyChanges {
                target: contentLeftItem.image
                source: bayID == 1 ?
                            "qrc:/img/methodxl_rewind_spool_1.png" :
                            "qrc:/img/methodxl_rewind_spool_2.png"
                visible: bot.machineType == MachineType.Magma
            }

            PropertyChanges {
                target: contentRightItem.numberedSteps
                visible: false
            }

            PropertyChanges {
                target: contentLeftItem.loadingIcon
                visible: false
            }
            PropertyChanges {
                target: contentRightItem.textBody1
                visible: false
            }
        },
        State {
            name: "error"
            //this state doesn't have a when condiiton unlike others and
            //instead the switch case above is used to get into this state,
            //since we need the UI to be held at this screen
            //even after the process has completed, until the user presses 'done'.

            PropertyChanges {
                target: snipMaterial
                visible: false
            }

            PropertyChanges {
                target: expExtruderInstructions
                visible: false
            }

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: false
            }

            PropertyChanges {
                target: contentRightItem.textHeader
                text: {
                    switch(bot.process.type) {
                      case ProcessType.Load:
                          qsTr("FILAMENT LOADING FAILED")
                          break;
                      case ProcessType.Unload:
                          qsTr("FILAMENT UNLOADING FAILED")
                          break;
                      default:
                          defaultString
                          break;
                    }
                }
            }

            PropertyChanges {
                target: contentRightItem.textBody
                text: qsTr("Error %1").arg(errorCode)
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.buttonPrimary
                visible: true
                text: qsTr("DONE")
            }

            PropertyChanges {
                target: contentRightItem.buttonSecondary1
                text: {
                    if(inFreStep) {
                        if(bot.process.type == ProcessType.Print) {
                            isLoadFilament ? "RETRY LOADING" : "RETRY UNLOADING"
                        }
                        else if(bot.process.type == ProcessType.None) {
                            isLoadFilament ? "RETRY LOADING" : "RETRY UNLOADING"
                        }
                    }
                    else {
                        isLoadFilament ? "RETRY LOADING" : "RETRY UNLOADING"
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: contentLeftItem.animatedImage
                visible: false
            }

            PropertyChanges {
                target: contentLeftItem.image
                source: bayID == 1 ?
                            "qrc:/img/extruder_1_heating.png" :
                            "qrc:/img/extruder_2_heating.png"
                visible: true
            }

            PropertyChanges {
                target: contentRightItem.numberedSteps
                visible: false
            }

            PropertyChanges {
                target: contentLeftItem.loadingIcon
                visible: false
            }
            PropertyChanges {
                target: contentRightItem.textBody1
                visible: false
            }
        }
    ]
}
