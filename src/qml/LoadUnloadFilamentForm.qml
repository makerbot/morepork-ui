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

    property alias acknowledgeButton: contentRightSide.buttonPrimary
    property alias retryButton: contentRightSide.buttonSecondary1
    property bool bayFilamentSwitch: false
    property bool extruderFilamentSwitch: false
    property bool isSupportExtruder: false
    property bool feedFromTop: false
    property bool feedFromAux: false
    property int retryTemperature: 0
    property string retryMaterial: "None"
    property bool retryExternal: false
    property int bayID: 0
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
            // The materialValidityCheck updates a flag (isMaterialValid)
            // that is used in the loading flow so it should be called when
            // standalone loading and also when mid-print loading.
            if(bot.process.type == ProcessType.Load ||
               (bot.process.type == ProcessType.Print &&
                bot.process.stepStr == "preheating_loading")) {
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
            notExtruding = false
            notEngaging = false
        } else {
            feedFromTop = false
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
                    console.info("ack here")
                    bot.acknowledgeMaterial()
                    // Check for moisture alert anytime a valid
                    // material is placed on the bay when loading.
                    maybeShowMoistureWarningPopup(bayID)
                } else {
                    isMaterialValid = false
                }
            }
            else {
                state = "place_material"
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
        if(state != "loaded_filament" || state != "unloaded_filament") {
            return
        }
        // Immediately starting the load/unload process
        // after it completes, presumably while kaiten is
        // still not fully finished cleaning up, causes it
        // to not start properly, so disabling the retry
        // button and then enabling after a few seconds is
        // a quick hacky fix for this before launch.
        contentRightSide.buttonSecondary1.enabled = false
        enableRetryButton.start()
    }

    property int errorCode
    property bool doingAutoUnload: false
    signal processDone()
    property int currentState: bot.process.stateType
    property int errorType: bot.process.errorType
    property bool notExtruding: false
    property bool notEngaging: false
    // Flag to take the user through the new spool setup screens on XL (place
    // desiccant, cut filament tip, place material) when loading filament mid-print
    // where kaiten starts right away with the preheating step but we need the user
    // to go through the new spool setup screens. This flag is used only for XL and
    // on M/MX the presence of NFC tag flag moves the loading flow to the preheating
    // screen.
    property bool completedNewSpoolSetup: false

    onErrorTypeChanged: {
        if (errorType === ErrorType.DrawerOutOfFilament &&
                currentState === ProcessStateType.UnloadingFilament) {
            doingAutoUnload = true
        }
    }
    onCurrentStateChanged: {
        if (!materialChangeActive) return;
        if (currentState != ProcessStateType.UnloadingFilament) {
            doingAutoUnload = false
        }
        switch(currentState) {
        case ProcessStateType.WaitingForFilament:
            // Landing screen depending on whether we're loading on
            // Method/X or XL or purging.
            if(extruderFilamentSwitch) {
                state = "preheating"
            } else if(bot.hasFilamentBay) {
                state = "cut_filament_tip"
            } else {
                state = "place_desiccant"
            }
            break;
        case ProcessStateType.Preheating:
            // For mid-print loading kaiten starts with the preheating step
            // so moving the user deliberately through the initial stpes
            // instaed of dumping them to the preheating screen immediately.
            // This is only valid when in the preheating screen and the the
            // filament switches (bay for M/MX and extruder for XL) are not
            // triggered. When/If they are triggered other states will take
            // over based on their when condition.
            if(bot.process.type == ProcessType.Print) {
                if(bot.hasFilamentBay) {
                    state = "cut_filament_tip"
                } else {
                    // At the beginning of a mid-print loading unconditonally mark
                    // that the new spool setup process hasn't been completed. This
                    // flag will be set as the user follows the screens and gets to
                    // to the place material screen or when the printer gets to the
                    // "preheating" UI state screen which can only happen when the
                    // the extruder switch is triggered and kaiten gets to the
                    // 'preheating' step.
                    completedNewSpoolSetup = false
                    state = "place_desiccant"
                }
            }
            break;
        case ProcessStateType.AwaitingEngagement:
        case ProcessStateType.Extrusion:
            if (!bot.hasFilamentBay) {
                feedFromAux = false
                state = "awaiting_engagement"
            } else if (!bayFilamentSwitch) {
                feedFromAux = true
                state = "awaiting_engagement"
            } else if (shouldUserAssistPurging(bayID)) {
                // User assisted purging currently asks the user to load from
                // the top on the first pass
                feedFromTop = true
                feedFromAux = false
                state = "awaiting_engagement"
            } else {
                state = "extrusion"
            }
            break;
        case ProcessStateType.Paused:
        case ProcessStateType.Done:
            if (bot.process.errorCode > 0 && bot.process.errorCode != 83) {
                errorCode = bot.process.errorCode
                state = "error"
            } else if (isLoadFilament) {
                if (notExtruding) {
                    state = "error_not_extruding"
                } else if (notEngaging) {
                    state = "error_not_engaging"
                } else if (!bot.materialLoaded[bayID - 1]) {
                    // We _should_ only get here if the user let the loading
                    // time out but we never detected engagement.
                    state = "error_not_engaging"
                } else {
                    state = "loaded_filament"
                }
            } else {
                state = "unloaded_filament"
            }
            delayedEnableRetryButton();
            break;
        default:
            break;
        }
    }

    Timer {
        id: enableRetryButton
        interval: 3000
        onTriggered: {
            contentRightSide.buttonSecondary1.enabled = true
        }
    }

    LabsExtruderLoadingInstructions {
        id: labsExtruderLoadingInstructions
        z: 1
        visible: {
            // 1.) Do not show this screen on printers without
            //     filament bay as extruder loading is the only
            //     option.
            // 2.) Show this when using the Labs extruder.
            // 3.) Show this when in the waiting for filament
            //     kaiten step.
            // 4.) Do not show this screen when either of the
            //     filament switches are triggered. That means
            //     the user has already chosen their loading style.
            //     Users can very well load from the drawer bay if
            //     they are using approved materials on Labs extruder
            //     on Method. Technically kaiten cannot be in this
            //     waiting for filament step if any of the filament
            //     switches are triggered and will move to preheating
            //     but this check is still here to accomodate
            //     the kaiten delay to go to preheating step when
            //     trying to purge filament (i.e. extruder switch
            //     already triggered)
            // 5.) Show this creen only during a load/print process
            //     (not during unload)

            bot.machineType != MachineType.Magma &&
            usingExpExtruder &&
            bot.process.stateType == ProcessStateType.WaitingForFilament &&
            !bayFilamentSwitch &&
            !extruderFilamentSwitch &&
            (bot.process.type == ProcessType.Load ||
             bot.process.type == ProcessType.Print)
        }
    }

    UserAssistedLoadInstructions {
        id: userAssistedLoadInstructions
        z: 1
        visible: false
    }

    ContentLeftSide {
        id: contentLeftSide
        visible: true
    }

    ContentRightSide {
        id: contentRightSide
        visible: true
    }

    states: [
        // COMMON STEP - cut_filament_tip
        State {
            name: "cut_filament_tip"

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    visible: false
                }
                animatedImage {
                    source: "qrc:/img/cut_filament_tip.gif"
                    visible: true
                }
                processStatusIcon {
                    visible: false
                }
            }

            PropertyChanges {
                target: contentRightSide
                textHeader {
                    style: TextHeadline.Base
                    text: qsTr("REMOVE BENT MATERIAL")
                    visible: true
                }
                textBody {
                    text: qsTr("Cut the filament below the point at which " +
                               "any material has been bent or damaged.") + "<br><br>" +
                          qsTr("Cleanly cut any bent material at a 45 degree " +
                               "angle before inserting into the guide tube.") + "<br><br>" +
                          qsTr("Click the help icon for additional guidance on " +
                               "best practices for cutting material.")
                    visible: true
                }
                buttonPrimary {
                    style: (bot.machineType == MachineType.Magma)?
                           ButtonRectanglePrimary.ButtonWithHelp :
                           ButtonRectanglePrimary.Button
                    text: qsTr("NEXT")
                    visible: true
                }
            }
        },

        // WITHOUT FILAMENT BAY ONLY STEP - place_desiccant
        State {
            name: "place_desiccant"

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    visible: false
                }
                animatedImage {
                    source: ("qrc:/img/methodxl_place_desiccant_%1.gif").arg(bayID)
                    visible: true
                }
                processStatusIcon {
                    visible: false
                }
            }

            PropertyChanges {
                target: contentRightSide
                textHeader {
                    style: TextHeadline.Base
                    text: qsTr("DESICCANT FOR MATERIAL %1").arg(bayID)
                    visible: true
                }
                textBody {
                    text: qsTr("Insert the two desiccant bags into the slots " +
                                  "on the %1 side of the material case.")
                              .arg(bayID == 1 ? qsTr("left") : qsTr("right")) +
                              "<br><br>" + qsTr("Click the help icon for " +
                                  "additional considerations around desiccant.")
                    visible: true
                }
                buttonPrimary {
                    style: ButtonRectanglePrimary.ButtonWithHelp
                    text: qsTr("NEXT")
                    visible: true
                }
            }
        },

        // COMMON STEP - place_material
        State {
            name: "place_material"

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    visible: false
                }
                animatedImage {
                    source: ("qrc:/img/%1.gif").arg(getImageForPrinter("place_spool_%1".arg(bayID)))
                    visible: true
                }
                processStatusIcon {
                    visible: false
                }
            }

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    style: TextHeadline.Base
                    text: {
                        if (bot.hasFilamentBay) {
                            qsTr("NO MATERIAL DETECTED")
                        } else {
                            qsTr("PLACE MATERIAL %1").arg(bayID)
                        }
                    }
                    visible: true
                }
                textBody {
                    visible: false
                }
                numberedSteps {
                    steps: {
                        if (bot.hasFilamentBay) {
                            [qsTr("Press side latch to unlock and open bay %1").arg(bayID),
                             qsTr("Place a %1 material spool in the bay").arg(
                                            isSupportExtruder ? qsTr("Support") : qsTr("Model")),
                             qsTr("Insert the material into the slot until you feel it being pulled in.")]
                        } else {
                            [qsTr("Ensure the spool is oriented correctly with cap on right side."),
                             qsTr("Place the spool onto the rollers of Bay %1, making sure the " +
                                  "spool is aligned with the funnel.").arg(bayID)]
                        }
                    }
                    activeSteps: {
                        if (bot.hasFilamentbay) {
                            [true, true, false]
                        } else {
                            [true, true]
                        }
                    }
                    visible: true
                }
                buttonPrimary {
                    style: ButtonRectanglePrimary.ButtonWithHelp
                    text: qsTr("NEXT")
                    visible: !bot.hasFilamentBay
                }
            }
        },

        // WITHOUT FILAMENT BAY ONLY STEP - no_nfc_reader_feed_filament
        State {
            name: "no_nfc_reader_feed_filament"

            // Screen for mid-print loading before the extruder switch is triggered. Note that
            // we only get to this after the flag completedNewSpoolSetup becomes true which happens
            // after following the new spool setup screens (place desiccant, cut tip, place material)

            // Another way to get into this state is during normal loading or mid-print loading when the
            // user triggers the extruder switch but due to shaky hands untriggers it. At this point Kaiten
            // would have begun preheating once the extruder switch was triggered and the UI moved to the
            // "preheating" state, but as the switch is untriggered the UI now doesn't have a state to go
            // back to prompt re-inserting filament which is what this when condition handles. Note that
            // this is only relevant for Method XL.
            when: !bot.hasFilamentBay &&
                  (bot.process.type == ProcessType.Load ||
                   (bot.process.type == ProcessType.Print && completedNewSpoolSetup)) &&
                  bot.process.stateType == ProcessStateType.Preheating &&
                  !extruderFilamentSwitch

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    visible: false
                }
                animatedImage {
                    source: ("qrc:/img/%1.gif").arg(getImageForPrinter(("feed_material_%1").arg(bayID)))
                    visible: true
                }
                processStatusIcon {
                    visible: false
                }
            }

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    style: TextHeadline.Base
                    text: qsTr("FEED INTO PORT %1").arg(bayID)
                    visible: true
                }
                textHeaderWaitingForUser {
                    text: qsTr("WAITING FOR MATERIAL")
                    waitingForUser: true
                    visible: true
                }
                textBody {
                    text: qsTr("Feed material through the funnel until you " +
                          "feel it engage with the extruder.") + "<br><br>" +
                          qsTr("If you encounter any issues, click the help " +
                          "icon for additional guidance.")
                    visible: true
                }
                numberedSteps {
                    visible: false
                }
                buttonPrimary {
                    style: ButtonRectanglePrimary.ButtonDisabledHelpEnabled
                    text: qsTr("NEXT")
                    visible: true
                }
            }
        },

        // WITH FILAMENT BAY ONLY STEP - nfc_detected_feed_filament
        State {
            name: "nfc_detected_feed_filament"
            when: bot.hasFilamentBay &&
                  isMaterialValid && !usingExpExtruder && !bayFilamentSwitch &&
                  ((bot.process.stateType == ProcessStateType.WaitingForFilament && // For normal loading
                    bot.process.type == ProcessType.Load) ||
                   (bot.process.stateType == ProcessStateType.Preheating && // For mid-print loading
                    bot.process.type == ProcessType.Print))

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: shouldUserAssistDrawerLoading(bayID)
            }

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    visible: false
                }
                animatedImage {
                    source: ("qrc:/img/%1.gif").arg(getImageForPrinter(("feed_material_%1").arg(bayID)))
                    visible: true
                }
                processStatusIcon{
                    visible: false
                }
            }

            PropertyChanges {
                target: contentRightSide
                textHeader {
                    style: TextHeadline.Base
                    text: qsTr("%1 DETECTED").arg(materialName) + "<br><br>" +
                          qsTr("LOAD MATERIAL INTO BAY %1").arg(bayID)
                    visible: true
                }
                textBody {
                    visible: false
                }
                numberedSteps {
                    steps: {
                        [qsTr("Press side latch to unlock and open bay %1").arg(bayID),
                         qsTr("Place a %1 material spool in the bay").arg(
                                        bayID == 1 ? qsTr("Model") : qsTr("Support")),
                         qsTr("Insert the material into the slot until you feel it being pulled in.")]
                    }
                    activeSteps: {
                        [false, false, true]
                    }
                    visible: true
                }
                buttonPrimary {
                    visible: false
                }
            }
        },

        // WITH FILAMENT BAY ONLY STEP - pushing_filament_up_with_motors
        State {
            name: "pushing_filament_up_with_motors"
            when: bot.hasFilamentBay &&
                  (bayFilamentSwitch && !extruderFilamentSwitch) &&
                   bot.process.stateType == ProcessStateType.Preheating &&
                   (bot.process.type == ProcessType.Load ||
                   bot.process.type == ProcessType.Unload ||
                   bot.process.type == ProcessType.Print)

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: shouldUserAssistDrawerLoading(bayID)
            }

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    visible: false
                }
                animatedImage {
                    visible: false
                }
                processStatusIcon {
                    processStatus: ProcessStatusIcon.Loading
                    visible: true
                }
            }

            PropertyChanges {
                target: contentRightSide
                textHeader {
                    style: TextHeadline.Large
                    text: qsTr("MATERIAL LOADING")
                    visible: true
                }
                textBody {
                    text: qsTr("Motors are pushing the material up to the extruder.") +
                          "<br><br>" + qsTr("This can take up to 30 seconds.")
                    visible: true
                }
                numberedSteps {
                    visible: false
                }
                buttonPrimary {
                    visible: false
                }
            }
        },

        // COMMON STEP - preheating
        State {
            name: "preheating"
            when: (extruderFilamentSwitch || usingExpExtruder) &&
                  bot.process.stateType == ProcessStateType.Preheating &&
                  (bot.process.type == ProcessType.Load ||
                   bot.process.type == ProcessType.Unload ||
                   bot.process.type == ProcessType.Print)

            PropertyChanges {
                target: loadUnloadForm
                // If kaiten reports preheating step and the extruder switch is
                // triggered then mark that the new spool setup process has been
                // completed. This is required because if the user untriggers the
                // filament at this point the UI will go back to the feed filament
                // screen and not the new spool setup screen. This is only relevant
                // for XL.
                completedNewSpoolSetup: true
            }

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    visible: false
                }
                animatedImage {
                    visible: false
                }
                processStatusIcon {
                    processStatus: ProcessStatusIcon.Loading
                    visible: true
                }
            }

            PropertyChanges {
                target: contentRightSide
                textHeader {
                    style: TextHeadline.Large
                    text: qsTr("HEATING")
                    visible: true
                }
                temperatureStatus {
                    showComponent: {
                        (bayID == 1) ?
                           TemperatureStatus.ModelExtruder :
                           TemperatureStatus.SupportExtruder
                    }
                    visible: true
                }
                textBody {
                    visible: false
                }
                numberedSteps {
                    visible: false
                }
                buttonPrimary {
                    visible: false
                }
            }
        },

        // MOSTLY COMMON STEP - awaiting_engagement
        // (Included whenever we are not assisting filament)
        State {
            name: "awaiting_engagement"

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    source: feedFromTop? "qrc:/img/feed_from_top.png" :
                        "qrc:/img/labs_extruder_instructions.png"
                    visible: feedFromTop || feedFromAux
                }
                animatedImage {
                    source: ("qrc:/img/%1.gif").arg(getImageForPrinter(("feed_material_%1").arg(bayID)))
                    visible: !feedFromTop && !feedFromAux
                }
                processStatusIcon {
                    visible: false
                }
            }

            PropertyChanges {
                target: contentRightSide
                textHeader {
                    text: qsTr("LOAD MATERIAL")
                    visible: true
                }
                textBody {
                    text: qsTr("Feed the material into the extruder until you feel the motor engage.")
                    visible: true
                }
                buttonPrimary {
                    style: ButtonRectanglePrimary.Button
                    text: qsTr("NEXT")
                    visible: true
                    enabled: bot.process.stateType == ProcessStateType.Extrusion
                }
                buttonSecondary1 {
                    delayedEnableTimeSec: 30
                    style: ButtonRectanglePrimary.DelayedEnable
                    text: qsTr("NOT ENGAGING")
                    visible: true
                }
                temperatureStatus {
                    visible: false
                }
                numberedSteps {
                    visible: false
                }
            }
        },

        // COMMON STEP - extrusion
        State {
            name: "extrusion"

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    source: ("qrc:/img/extrusion_%1.png").arg(bayID)
                    visible: true
                }
                animatedImage {
                    visible: false
                }
                processStatusIcon {
                    visible: false
                }
            }

            PropertyChanges {
                target: contentRightSide
                textHeader {
                    text: qsTr("EXTRUSION CONFIRMATION")
                    visible: true
                }
                textBody {
                    text: qsTr("Look inside of the printer and wait until you see material begin to extrude.")
                    visible: true
                }
                buttonPrimary {
                    style: ButtonRectanglePrimary.Button
                    text: qsTr("CONFIRM")
                    visible: true
                }
                buttonSecondary1 {
                    delayedEnableTimeSec: 30
                    style: ButtonRectanglePrimary.DelayedEnable
                    text: qsTr("NOT EXTRUDING")
                    visible: true
                }
                temperatureStatus {
                    visible: false
                }
                numberedSteps {
                    visible: false
                }
            }
        },

        // COMMON STEP - unloading_filament
        State {
            name: "unloading_filament"
            when: (bot.process.stateType == ProcessStateType.UnloadingFilament ||
                   bot.process.stateType == ProcessStateType.CleaningUp) &&
                  (bot.process.type == ProcessType.Unload ||
                   bot.process.type == ProcessType.Load ||
                   bot.process.type == ProcessType.Print)

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    visible: false
                }
                animatedImage {
                    visible: false
                }
                processStatusIcon {
                    processStatus: ProcessStatusIcon.Loading
                    visible: true
                }
            }

            PropertyChanges {
                target: contentRightSide
                textHeader {
                    style: TextHeadline.Large
                    text: {
                        doingAutoUnload ?
                           qsTr("OUT OF FILAMENT") :
                           qsTr("MATERIAL UNLOADING")
                    }
                    visible: true
                }
                textBody {
                    text: {
                        doingAutoUnload ?
                           qsTr("Please wait while the remaining material backs out of the printer.") :
                           qsTr("The material is backing out of the extruder, please wait.")
                    }
                    visible: true
                }
                buttonPrimary {
                    visible: false
                }
                buttonSecondary1 {
                    visible: false
                }
                numberedSteps {
                    visible: false
                }
                temperatureStatus {
                    visible: false
                }
            }
        },

        // COMMON STEP - loaded_filament
        State {
            name: "loaded_filament"
            //this state doesn't have a when condiiton unlike others and
            //instead the switch case above is used to get into this state,
            //since we need the UI to be held at this screen
            //even after the process has completed, until the user presses 'done'.

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    source: ("qrc:/img/%1.png").arg(getImageForPrinter("clear_excess_material"))
                    visible: true
                }
                animatedImage {
                    visible: false
                }
                processStatusIcon {
                    visible: false
                }
            }

            PropertyChanges {
                target: contentRightSide
                textHeader {
                    style: TextHeadline.Base
                    text: qsTr("CLEAR EXCESS MATERIAL")
                    visible: true
                }
                textBody {
                    text: qsTr("Remove any excess material on the extruder or build plate " +
                               "and close the build chamber door.")
                    visible: true
                }
                buttonPrimary {
                    style: ButtonRectanglePrimary.Button
                    text: {
                        if(inFreStep) {
                            // During material loading in FRE for printers without
                            // a filament bay (Method XL) we directly start the
                            // support extruder loading from this state and only go
                            // to the loaded_filament_1 state after support material
                            // loading is complete, to tell the use to close the material
                            // case.
                            if(bayID == 1 && !bot.hasFilamentBay) {
                                qsTr("NEXT: LOAD MATERIAL 2")
                            } else {
                                // Text during support material loading in FRE or during
                                // mid-print-loading in FRE where the user is taken to the
                                // next screen which asks them to close the material case.
                                qsTr("NEXT")
                            }
                        } else {
                            // During regular loading the user is always asked to close
                            // the material case in the next screen at the end of every
                            // loading.
                            qsTr("NEXT")
                        }
                    }
                    visible: true
                }
                buttonSecondary1 {
                    style: ButtonRectanglePrimary.Button
                    text: {
                        if(inFreStep) {
                            if(bot.process.type == ProcessType.Print) {
                                qsTr("RETRY PURGING")
                            }
                            else if(bot.process.type == ProcessType.None) {
                                qsTr("RETRY LOADING")
                            }
                        } else {
                            qsTr("RETRY LOADING")
                        }
                    }
                    visible: true
                }
                numberedSteps {
                    visible: false
                }
                temperatureStatus {
                    visible: false
                }
            }
        },

        // COMMON STEP - Close Latch - loaded_filament_1
        State {
            name: "loaded_filament_1"

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    visible: false
                }
                animatedImage {
                    source: ("qrc:/img/%1.gif").arg(getImageForPrinter("close_latch_%1".arg(bayID)))
                    visible: true
                }
                processStatusIcon {
                    visible: false
                }
            }

            PropertyChanges {
                target: contentRightSide
                textHeader {
                    style: TextHeadline.Base
                    text: {
                        if(bot.hasFilamentBay) {
                            qsTr("CLOSE LATCH")
                        } else {
                            qsTr("CLOSE LID AND LATCH")
                        }
                    }
                    visible: true
                }
                textBody {
                    text: {
                        if(bot.hasFilamentBay) {
                            qsTr("Keeping the material bay sealed prevents moisture intake and " +
                                 "ensures best print quality.")
                        } else {
                            qsTr("Keeping the material case sealed prevents moisture intake and " +
                                 "ensures best print quality.")
                        }
                    }
                    visible: true
                }
                numberedSteps {
                    visible: false
                }
                buttonPrimary {
                    style: ButtonRectanglePrimary.Button
                    text: {
                        if(inFreStep) {
                            if(bot.process.type == ProcessType.Print) {
                                qsTr("DONE")
                            } else if(bot.process.type == ProcessType.None) {
                                if(bayID == 1 && bot.hasFilamentBay) {
                                    qsTr("NEXT: LOAD MATERIAL 2")
                                } else if(bayID == 2) {
                                    qsTr("DONE")
                                }
                            }
                        } else {
                            qsTr("DONE")
                        }
                    }
                    visible: true
                }
                buttonSecondary1 {
                    visible: false
                }
                temperatureStatus {
                    visible: false
                }
            }
        },

        // COMMON STEP - unloaded_filament
        State {
            name: "unloaded_filament"
            //this state doesn't have a when condiiton unlike others and
            //instead the switch case above is used to get into this state,
            //since we need the UI to be held at this screen
            //even after the process has completed, until the user presses 'done'.

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    visible: false
                }
                animatedImage {
                    source: ("qrc:/img/%1.gif").arg(getImageForPrinter("rewind_spool_%1".arg(bayID)))
                    visible: true
                }
                processStatusIcon {
                    visible: false
                }
            }

            PropertyChanges {
                target: contentRightSide
                textHeader {
                    style: TextHeadline.Base
                    text: qsTr("REWIND SPOOL")
                    visible: true
                }
                textBody {
                    text: qsTr("Open material bay %1 and carefully rewind the material onto the " +
                               "spool. Secure the end of the material inside the spool bag and " +
                               "seal. Close the bay door.").arg(bayID)
                    visible: bot.hasFilamentBay
                }
                numberedSteps {
                    steps: [qsTr("Hold the material at the entry port to maintain tension and prevent unspooling as you rewind."),
                            qsTr("Rewind material using the rollers until material has exited.")]
                    visible: !bot.hasFilamentBay
                }
                buttonPrimary {
                    style: {
                        if(bot.hasFilamentBay) {
                            ButtonRectanglePrimary.Button
                        } else {
                            ButtonRectanglePrimary.ButtonWithHelp
                        }
                    }
                    text: {
                        if(bot.hasFilamentBay) {
                            qsTr("DONE")
                        } else {
                            qsTr("NEXT")
                        }
                    }
                    visible: true
                }
                buttonSecondary1 {
                    delayedEnableTimeSec: 3
                    style: ButtonRectanglePrimary.DelayedEnable
                    text: qsTr("RETRY UNLOADING")
                    visible: true
                }
                temperatureStatus {
                    visible: false
                }
            }
        },

        // WITHOUT FILAMENT BAY ONLY STEP - Store Material - unloaded_filament_1
        State {
            name: "unloaded_filament_1"

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    source: "qrc:/img/methodxl_store_material.png"
                    visible: true
                }
                animatedImage {
                    visible: false
                }
                processStatusIcon {
                    visible: false
                }
            }

            PropertyChanges {
                target: contentRightSide
                textHeader {
                    style: TextHeadline.Base
                    text: qsTr("STORE MATERIAL + SEAL CASE")
                    visible: true
                }
                textBody {
                    text: qsTr("Carefully rewind and secure the tip onto the " +
                               "edge of the spool.") + "<br><br>" +
                          qsTr("Seal the latch of the material case and store " +
                               "the spool in the bag to prevent moisture intake.")
                    visible: true
                }
                buttonPrimary {
                    style: ButtonRectanglePrimary.Button
                    text: qsTr("DONE")
                    visible: true
                }
                buttonSecondary1 {
                    visible: false
                }
                temperatureStatus {
                    visible: false
                }
                numberedSteps {
                    visible: false
                }
            }
        },

        // COMMON STEP - error
        State {
            name: "error"
            //this state doesn't have a when condiiton unlike others and
            //instead the switch case above is used to get into this state,
            //since we need the UI to be held at this screen
            //even after the process has completed, until the user presses 'done'.

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    visible: false
                }
                animatedImage {
                    visible: false
                }
                processStatusIcon {
                    processStatus: ProcessStatusIcon.Failed
                    visible: true
                }
            }

            PropertyChanges {
                target: contentRightSide
                textHeader {
                    style: TextHeadline.Base
                    text: qsTr("PROCEDURE FAILED")
                    visible: true
                }
                textBody {
                    text: qsTr("Error %1").arg(errorCode)
                    visible: true
                }
                buttonPrimary {
                    style: ButtonRectanglePrimary.Button
                    text: {
                        if(inFreStep) {
                            if(bot.process.type == ProcessType.Print) {
                                isLoadFilament ? qsTr("RETRY LOADING") : qsTr("RETRY UNLOADING")
                            }
                            else if(bot.process.type == ProcessType.None) {
                                isLoadFilament ? qsTr("RETRY LOADING") : qsTr("RETRY UNLOADING")
                            }
                        } else {
                            isLoadFilament ? qsTr("RETRY LOADING") : qsTr("RETRY UNLOADING")
                        }
                    }
                    visible: true
                }
                buttonSecondary1 {
                    text: qsTr("SWAP MATERIAL")
                    style: ButtonRectanglePrimary.Button
                    visible: true
                    enabled: !inFreStep
                }
                temperatureStatus {
                    visible: false
                }
                numberedSteps {
                    visible: false
                }
            }
        },

        // COMMON STEP - error_not_extruding
        State {
            name: "error_not_extruding"
            extend: "error"
            PropertyChanges {
                target: contentRightSide
                textBody {
                   visible: false
                }
                buttonPrimary {
                    text: qsTr("RETRY EXTRUDING")
                    visible: true
                }
            }
        },

        // COMMON STEP - error_not_engaging
        State {
            name: "error_not_engaging"
            extend: "error"
            PropertyChanges {
                target: contentRightSide
                textHeader {
                    text: qsTr("Troubleshoot")
                }
                textBody {
                    text: qsTr("Please run the manual feed procedure below to heat the extruder and push material through at the top chamber.")
                }
                buttonPrimary {
                    text: qsTr("MANUAL FEED")
                }
                buttonSecondary1 {
                    text: qsTr("EXIT")
                }
            }
        },

        // COMMON STEP - top_assist_load
        State {
            name: "top_assist_load"

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    source: ("qrc:/img/%1.png").arg(getImageForPrinter("remove_top_lid"))
                    visible: true
                }
                animatedImage {
                    visible: false
                }
                processStatusIcon {
                    visible: false
                }
            }

            PropertyChanges {
                target: contentRightSide

                textHeader {
                    style: TextHeadline.Base
                    text: qsTr("REMOVE TOP LID")
                    visible: true
                }
                textBody {
                    text: qsTr("Remove the top lid so that material can be manually inserted directly into the extruder.")
                    visible: true
                }
                numberedSteps {
                    visible: false
                }
                buttonPrimary {
                    style: ButtonRectanglePrimary.Button
                    text: qsTr("NEXT")
                    visible: true
                }
            }
        }
    ]
}
