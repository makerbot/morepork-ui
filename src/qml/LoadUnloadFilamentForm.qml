import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0
import ErrorTypeEnum 1.0
import ExtruderTypeEnum 1.0

LoggingItem {
    itemName: "LoadUnloadFilament"
    id: loadUnloadForm
    width: 800
    height: 420

    property alias snipMaterial: snipMaterial
    property alias acknowledgeButton: acknowledgeButton
    property alias retryButton: retryButton
    property bool snipMaterialAlertAcknowledged: false
    property int currentTemperature: bayID == 1 ? bot.extruderACurrentTemp : bot.extruderBCurrentTemp
    property int targetTemperature: bayID == 1 ? bot.extruderATargetTemp : bot.extruderBTargetTemp
    property bool bayFilamentSwitch: false
    property bool extruderFilamentSwitch: false
    property bool isExternalLoadUnload: false
    property int lastHeatingTemperature: 0
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
        retryButton.disable_button = true
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
            // (sorry)
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
            retryButton.disable_button = false
        }
    }

    LoadingIcon {
        id: loading_gear
        anchors.left: parent.left
        anchors.leftMargin: 70
        anchors.verticalCenterOffset: -20
        anchors.verticalCenter: parent.verticalCenter
        loading: false
    }

    SnipMaterialScreen {
        id: snipMaterial
        z: 1
        anchors.verticalCenterOffset: -20
        visible: !snipMaterialAlertAcknowledged && !isExternalLoadUnload && !bayFilamentSwitch
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

    Image {
        id: static_image
        width: 400
        height: 480
        anchors.verticalCenterOffset: -10
        anchors.verticalCenter: parent.verticalCenter
        source: ""
        cache: false
        opacity: (animated_image.opacity == 0) ?
                     1 : 0
        smooth: false
    }

    AnimatedImage {
        id: animated_image
        width: 400
        height: 480
        anchors.verticalCenterOffset: -10
        anchors.verticalCenter: parent.verticalCenter
        source: bayID == 1 ?
                    "qrc:/img/place_spool_bay1.gif" :
                    "qrc:/img/place_spool_bay2.gif"
        cache: false
        // Since this is the base state, settting playing to true
        // makes the gif always keep playing even when this page is
        // not visible which makes the entire UI lag.
        playing: materialSwipeView.currentIndex == 2 &&
                 (loadUnloadForm.state == "base state" ||
                  loadUnloadForm.state == "feed_filament" ||
                  loadUnloadForm.state == "loaded_filament" ||
                  loadUnloadForm.state == "unloaded_filament") &&
                 (!materialWarningPopup.opened &&
                  !cancelLoadUnloadPopup.opened &&
                  !materialPageDrawer.opened)
        opacity: 1
        smooth: false
    }

    Item {
        id: contentItem
        x: 400
        y: -40
        width: 400
        height: 420
        anchors.left: parent.left
        anchors.leftMargin: 400

        Text {
            id: main_instruction_text
            width: 375
            color: "#cbcbcb"
            text: qsTr("OPEN BAY %1").arg(bayID)
            font.capitalization: Font.AllUppercase
            anchors.top: parent.top
            anchors.topMargin: 100
            font.letterSpacing: 4
            wrapMode: Text.WordWrap
            font.family: defaultFont.name
            font.weight: Font.Bold
            font.pixelSize: 20
            lineHeight: 1.3
        }

        ColumnLayout {
            id: instructionsList
            width: 300
            height: 200
            anchors.top: main_instruction_text.bottom
            anchors.topMargin: 18
            opacity: 1.0

            BulletedListItem {
                id: bulletItem1
                bulletNumber: "1"
                bulletText: qsTr("Press side latch to unlock and\nopen bay %1").arg(bayID)
            }

            BulletedListItem {
                id: bulletItem2
                bulletNumber: "2"
                bulletText: qsTr("Place a %1 material spool in\nthe bay").arg(
                                    bayID == 1 ? qsTr("Model") : qsTr("Support"))
            }

            BulletedListItem {
                id: bulletItem3
                bulletNumber: "3"
                bulletText: qsTr("Push the end of the material into\nthe slot until you feel it being\npulled in.")
            }
        }

        Text {
            id: instruction_description_text
            width: 350
            color: "#cbcbcb"
            text: "\n\n\n"
            anchors.top: main_instruction_text.bottom
            anchors.topMargin: 30
            wrapMode: Text.WordWrap
            font.family: defaultFont.name
            font.weight: Font.Light
            font.pixelSize: 18
            lineHeight: 1.35
        }

        RoundedButton {
            id: acknowledgeButton
            label_width: 180
            label: qsTr("CONTINUE")
            buttonWidth: 180
            buttonHeight: 50
            anchors.top: instruction_description_text.bottom
            anchors.topMargin: 20
            opacity: 0
        }

        RoundedButton {
            id: retryButton
            label: qsTr("RETRY")
            label_size: 18
            buttonWidth: 150
            buttonHeight: 50
            anchors.left: acknowledgeButton.left
            anchors.top: acknowledgeButton.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 15
            visible: false
        }

        RowLayout {
            id: temperatureDisplay
            anchors.top: main_instruction_text.bottom
            anchors.topMargin: 20
            width: children.width
            height: 35
            spacing: 10
            visible: false

            Text {
                id: extruder_current_temperature_text
                text: qsTr("%1C").arg(currentTemperature)
                font.family: defaultFont.name
                color: "#ffffff"
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pixelSize: 20
            }

            Rectangle {
                id: divider_rectangle
                width: 1
                height: 25
                color: "#ffffff"
            }

            Text {
                id: extruder_target_temperature_text
                text: qsTr("%1C").arg(targetTemperature)
                font.family: defaultFont.name
                color: "#ffffff"
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pixelSize: 20
            }
        }
    }

    states: [
        State {
            name: "feed_filament"
            when: isMaterialValid && !isExternalLoadUnload && !bayFilamentSwitch &&
                  bot.process.stateType == ProcessStateType.Preheating &&
                  (bot.process.type == ProcessType.Load ||
                   bot.process.type == ProcessType.Print)

            PropertyChanges {
                target: snipMaterial
                visible: !snipMaterialAlertAcknowledged
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
                target: main_instruction_text
                text: {
                    if (bot.hasFilamentBay) {
                        qsTr("%1 DETECTED").arg(materialName)
                    } else {
                        qsTr("LOADING FILAMENT")
                    }
                }
            }

            PropertyChanges {
                target: instruction_description_text
                text: qsTr("Push the end of the material into the slot until you feel it being pulled in.")
                opacity: 0
            }

            PropertyChanges {
                target: acknowledgeButton
                opacity: 0
                label: qsTr("CONTINUE")
            }

            PropertyChanges {
                target: retryButton
                visible: false
            }

            PropertyChanges {
                target: animated_image
                opacity: 1
                source: bayID == 1 ?
                            "qrc:/img/insert_filament_bay1.gif" :
                            "qrc:/img/insert_filament_bay2.gif"
            }

            PropertyChanges {
                target: instructionsList
                opacity: 1
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
                visible: !snipMaterialAlertAcknowledged && !isExternalLoadUnload
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
                target: main_instruction_text
                text: qsTr("MATERIAL LOADING")
                anchors.topMargin: 160
            }

            PropertyChanges {
                target: instruction_description_text
                text: qsTr("Helper motors are pushing material\nup to the extruder. This can take up to\n30 seconds.")
            }

            PropertyChanges {
                target: temperatureDisplay
                visible: false
            }

            PropertyChanges {
                target: animated_image
                opacity: 0
            }

            PropertyChanges {
                target: static_image
                visible: false
            }

            PropertyChanges {
                target: instructionsList
                opacity: 0
            }

            PropertyChanges {
                target: acknowledgeButton
                opacity: 0
            }

            PropertyChanges {
                target: retryButton
                visible: false
            }

            PropertyChanges {
                target: loading_gear
                loading: true
            }
        },
        State {
            name: "preheating"
            when: (extruderFilamentSwitch || isExternalLoadUnload) &&
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
                    isExternalLoadUnload &&
                    targetTemperature > 0 &&
                    ((currentTemperature + 30) >= targetTemperature)
                }
            }

            PropertyChanges {
                target: userAssistedLoadInstructions
                visible: false
            }

            PropertyChanges {
                target: main_instruction_text
                text: (targetTemperature > currentTemperature) ?
                          qsTr("EXTRUDER %1 IS\nHEATING UP").arg(bayID) :
                          qsTr("EXTRUDER %1 IS\nCOOLING DOWN").arg(bayID)
                anchors.topMargin: 140
            }

            PropertyChanges {
                target: instruction_description_text
                text: ""
            }

            PropertyChanges {
                target: temperatureDisplay
                visible: true
            }

            PropertyChanges {
                target: extruder_current_temperature_text
                text: qsTr("%1C").arg(currentTemperature)
                visible: true
            }

            PropertyChanges {
                target: extruder_target_temperature_text
                text: qsTr("%1C").arg(targetTemperature)
                visible: true
            }

            PropertyChanges {
                target: animated_image
                opacity: 0
            }

            PropertyChanges {
                target: static_image
                source: {
                    if(bayID == 1) {
                        switch(bot.extruderAType) {
                        case ExtruderType.MK14:
                            "qrc:/img/extruder_1_heating.png"
                            break;
                        case ExtruderType.MK14_HOT:
                            "qrc:/img/extruder_1XA_heating.png"
                            break;
                        case ExtruderType.MK14_EXP:
                            "qrc:/img/extruder_labs_heating.png"
                            break;
                        case ExtruderType.MK14_COMP:
                            "qrc:/img/extruder_1c_heating.png"
                            break;
                        case ExtruderType.MK14_HOT_E:
                            "qrc:/img/extruder_labs_1_ht_heating.png"
                            break;
                        }
                    } else if(bayID == 2) {
                        switch(bot.extruderBType) {
                        case ExtruderType.MK14:
                            "qrc:/img/extruder_2_heating.png"
                            break;
                        case ExtruderType.MK14_HOT:
                            "qrc:/img/extruder_2XA_heating.png"
                            break;
                        }
                    }
                }
            }

            PropertyChanges {
                target: instructionsList
                opacity: 0
            }

            PropertyChanges {
                target: acknowledgeButton
                opacity: 0
            }

            PropertyChanges {
                target: retryButton
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
                target: main_instruction_text
                text: qsTr("EXTRUSION CONFIRMATION")
                anchors.topMargin: {
                    instruction_description_text.height < 100 ?
                                140 : 75
                }
            }

            PropertyChanges {
                target: instruction_description_text
                text: {
                    qsTr("Look inside of the printer and wait until you see material begin to extrude.") +
                           ((shouldUserAssistPurging(bayID) ?
                             qsTr("\n\n%1 may require assistance to extrude. ").arg(materialName) +
                             qsTr("If you don't see the filament extruding, gently push it in at the filament bay slot.") :
                                ""))
                }
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: acknowledgeButton
                label_size: 18
                label_width: 350
                buttonWidth: 350
                buttonHeight: 80
                anchors.topMargin: 20
                opacity: 1
                label: qsTr("CONFIRM\nMATERIAL EXTRUSION")
            }

            PropertyChanges {
                target: retryButton
                visible: false
            }

            PropertyChanges {
                target: animated_image
                opacity: 0
            }

            PropertyChanges {
                target: static_image
                source: bayID == 1 ?
                            "qrc:/img/confirm_extrusion_1.png" :
                            "qrc:/img/confirm_extrusion_2.png"
            }

            PropertyChanges {
                target: instructionsList
                opacity: 0
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
                target: main_instruction_text
                text: {
                    doingAutoUnload ?  qsTr("OUT OF FILAMENT") : qsTr("UNLOADING")
                }
                anchors.topMargin: 165
            }

            PropertyChanges {
                target: instruction_description_text
                text: {
                    doingAutoUnload ?
                        qsTr("Please wait while the remaining material backs out of the printer.") :
                        qsTr("The material is backing out of the extruder, please wait.")
                }
                anchors.topMargin: 30
            }

            PropertyChanges {
                target: animated_image
                opacity: 0
            }

            PropertyChanges {
                target: static_image
                opacity: 0
            }

            PropertyChanges {
                target: instructionsList
                opacity: 0
            }

            PropertyChanges {
                target: acknowledgeButton
                opacity: 0
            }

            PropertyChanges {
                target: retryButton
                visible: false
            }

            PropertyChanges {
                target: loading_gear
                loading: true
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
                target: main_instruction_text
                text: qsTr("CLEAR EXCESS MATERIAL AFTER EXTRUDER COOLS DOWN")
            }

            PropertyChanges {
                target: instruction_description_text
                text: qsTr("Wait a few moments until the material has cooled. Close the build chamber and material drawer.")
                anchors.topMargin: 60
            }

            PropertyChanges {
                target: acknowledgeButton
                opacity: 1
                anchors.topMargin: 20
                label_width: {
                    if(inFreStep) {
                        if(bot.process.type == ProcessType.Print) {
                            100
                        }
                        else if(bot.process.type == ProcessType.None) {
                            if(bayID == 1) {
                                375
                            } else if(bayID == 2) {
                                100
                            }
                        }
                    }
                    else {
                        100
                    }
                }

                buttonWidth: {
                    if(inFreStep) {
                        if(bot.process.type == ProcessType.Print) {
                            100
                        }
                        else if(bot.process.type == ProcessType.None) {
                            if(bayID == 1) {
                                375
                            } else if(bayID == 2) {
                                100
                            }
                        }
                    }
                    else {
                        100
                    }
                }

                label_size: {
                    if(inFreStep) {
                        if(bot.process.type == ProcessType.Print) {
                            18
                        }
                        else if(bot.process.type == ProcessType.None) {
                            if(bayID == 1) {
                               14
                            } else if(bayID == 2) {
                                18
                            }
                        }
                    }
                    else {
                        18
                    }
                }

                label: {
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
                target: retryButton
                label: {
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
                label_size: 18
                buttonWidth: 260
                buttonHeight: 50
                visible: true
            }

            PropertyChanges {
                target: animated_image
                opacity: 1
                source: bayID == 1 ?
                            "qrc:/img/close_bay1.gif" :
                            "qrc:/img/close_bay2.gif"
            }

            PropertyChanges {
                target: static_image
                opacity: 0
            }

            PropertyChanges {
                target: temperatureDisplay
                anchors.topMargin: 12
                visible: true
            }

            PropertyChanges {
                target: extruder_current_temperature_text
                text: qsTr("%1C").arg(bot.extruderACurrentTemp)
                visible: true
            }

            PropertyChanges {
                target: extruder_target_temperature_text
                text: qsTr("%1C").arg(bot.extruderBCurrentTemp)
                visible: true
            }

            PropertyChanges {
                target: instructionsList
                opacity: 0
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
                target: main_instruction_text
                text: qsTr("REWIND SPOOL")
                anchors.topMargin: 120
            }

            PropertyChanges {
                target: instruction_description_text
                text: qsTr("Open material bay %1 and carefully rewind the material onto the spool. Secure the end of the material inside the smart spool bag and seal. Close the bay door.").arg(bayID)
                anchors.topMargin: 30
            }

            PropertyChanges {
                target: acknowledgeButton
                buttonWidth: 120
                anchors.topMargin: 30
                opacity: 1
                label: qsTr("DONE")
            }

            PropertyChanges {
                target: retryButton
                label: {
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
                label_size: 18
                label_width: 260
                buttonWidth: 260
                buttonHeight: 50
                visible: true
            }

            PropertyChanges {
                target: animated_image
                opacity: 1
                source: bayID == 1 ?
                            "qrc:/img/rewind_spool_1.gif" :
                            "qrc:/img/rewind_spool_2.gif"
            }

            PropertyChanges {
                target: static_image
                opacity: 0
            }

            PropertyChanges {
                target: instructionsList
                opacity: 0
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
                target: main_instruction_text
                width: 300
                text: {
                    switch(bot.process.type) {
                      case ProcessType.Load:
                          qsTr("FILAMENT LOADING FAILED")
                          break;
                      case ProcessType.Unload:
                          qsTr("FILAMENT UNLOADING FAILED")
                          break;
                    }
                }
            }

            PropertyChanges {
                target: instruction_description_text
                text: qsTr("Error %1").arg(errorCode)
            }

            PropertyChanges {
                target: acknowledgeButton
                buttonWidth: 120
                anchors.topMargin: 50
                opacity: 1
                label: qsTr("DONE")
            }

            PropertyChanges {
                target: retryButton
                label: {
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
                label_size: 18
                label_width: 260
                buttonWidth: 260
                buttonHeight: 50
                visible: true
            }

            PropertyChanges {
                target: animated_image
                opacity: 0
            }

            PropertyChanges {
                target: static_image
                source: bayID == 1 ?
                            "qrc:/img/extruder_1_heating.png" :
                            "qrc:/img/extruder_2_heating.png"
            }

            PropertyChanges {
                target: instructionsList
                opacity: 0
            }
        }
    ]
}
