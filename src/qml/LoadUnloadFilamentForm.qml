import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0

Item {
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
    property bool isExternalLoad: false
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
                    isMaterialValid = true
                    if(materialWarningPopup.opened) {
                        materialWarningPopup.close()
                    }
                }
            }
        }
    }

    property bool isMaterialValid: false

    property bool isSpoolDetailsReady: bayID == 1 ?
                                       bay1.spoolDetailsReady :
                                       bay2.spoolDetailsReady

    onIsSpoolDetailsReadyChanged: {
        if(isSpoolDetailsReady) {
            if(bot.process.type == ProcessType.Load) {
                if(materialValidityCheck()) {
                    isMaterialValid = true
                    bot.acknowledgeMaterial(true)
                } else {
                    isMaterialValid = false
                }
            }
        }
        else {
            materialWarningPopup.close()
        }
    }

    // Also add spool checksum to this whenever thats
    // ready.
    function materialValidityCheck() {
        if(bayID == 1) {
            if(bay1.spoolPresent &&
               (bay1.filamentMaterialName == "PLA" ||
                bay1.filamentMaterialName == "TOUGH")) {
                return true
            }
            else if(bay1.filamentMaterialName == "PVA") {
                isMaterialMismatch = true
                return false
            }
            else {
                return false
            }
        }
        else if(bayID == 2) {
            if(bay2.spoolPresent &&
               bay2.filamentMaterialName == "PVA") {
                return true
            }
            else if(bay2.filamentMaterialName == "PLA" ||
                    bay2.filamentMaterialName == "TOUGH") {
                isMaterialMismatch = true
                return false
            }
            else {
                return false
            }
        }
    }

    property bool overrideInvalidMaterial: false
    property int materialCode: bayID == 1 ? bay1.filamentMaterialCode :
                                            bay2.filamentMaterialCode
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
    signal processDone
    property int currentState: bot.process.stateType
    onCurrentStateChanged: {
        switch(currentState) {
        case ProcessStateType.Stopping:
        case ProcessStateType.Done:
            snipMaterialAlertAcknowledged = false
            delayedEnableRetryButton()
            overrideInvalidMaterial = false
            if(bot.process.errorCode > 0) {
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
                    // Moving to default state is handled in cnacel
                    // button onClicked action, we just reset the
                    // cancelled flag here.
                    materialChangeCancelled = false
                }
            }
            else if(bot.process.type == ProcessType.Unload) {
                // We cant' cancel out of unloading so we don't
                // need the UI state logic like in the 'Load'
                // process above.
                state = "unloaded_filament"
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
                    materialSwipeView.swipeToItem(0)
                    // If cancelled out of load/unload while in print process
                    // enable print drawer to set UI back to printing state.
                    setDrawerState(false)
                    activeDrawer = printPage.printingDrawer
                    setDrawerState(true)
                    if(inFreStep &&
                       bot.process.type == ProcessType.Print) {
                        mainSwipeView.swipeToItem(1)
                    }
                }
                else {
                    isLoadFilament ? state = "loaded_filament" :
                                     state = "unloaded_filament"
                }
                if(bot.process.errorCode > 0) {
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
        visible: !snipMaterialAlertAcknowledged
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
        playing: materialSwipeView.currentIndex == 1 &&
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
            text: "OPEN BAY " + bayID
            font.capitalization: Font.AllUppercase
            anchors.top: parent.top
            anchors.topMargin: 100
            font.letterSpacing: 4
            wrapMode: Text.WordWrap
            font.family: "Antenna"
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
                bulletText: "Press side latch to unlock and\nopen bay " +
                            bayID
            }

            BulletedListItem {
                id: bulletItem2
                bulletNumber: "2"
                bulletText: "Place a " +
                            (bayID == 1 ? "Model " : "Support ") +
                            "material spool in\nthe bay"
            }

            BulletedListItem {
                id: bulletItem3
                bulletNumber: "3"
                bulletText: "Push the end of the material into\nthe slot until you feel it being\npulled in."
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
            font.family: "Antenna"
            font.weight: Font.Light
            font.pixelSize: 18
            lineHeight: 1.35
        }

        RoundedButton {
            id: acknowledgeButton
            label_width: 180
            label: "CONTINUE"
            buttonWidth: 180
            buttonHeight: 50
            anchors.top: instruction_description_text.bottom
            anchors.topMargin: 20
            opacity: 0
        }

        RoundedButton {
            id: retryButton
            label: "RETRY"
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
                text: currentTemperature + "C"
                font.family: "Antenna"
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
                text: targetTemperature + "C"
                font.family: "Antenna"
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
            when: (isMaterialValid || overrideInvalidMaterial) &&
                  !isExternalLoad && !bayFilamentSwitch &&
                  bot.process.stateType == ProcessStateType.Preheating &&
                  (bot.process.type == ProcessType.Load ||
                   bot.process.type == ProcessType.Print)

            PropertyChanges {
                target: snipMaterial
                visible: !snipMaterialAlertAcknowledged
            }

            PropertyChanges {
                target: main_instruction_text
                text: {
                    if(overrideInvalidMaterial) {
                        "UNKNOWN MATERIAL"
                    }
                    else if(isMaterialValid) {
                        materialName + " DETECTED"
                    }
                }
            }

            PropertyChanges {
                target: instruction_description_text
                text: "Push the end of the material into the slot until you feel it being pulled in."
                opacity: 0
            }

            PropertyChanges {
                target: acknowledgeButton
                opacity: 0
                label: "CONTINUE"
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
            when: ((bayFilamentSwitch && !extruderFilamentSwitch) ||
                   isExternalLoad) &&
                   bot.process.stateType == ProcessStateType.Preheating &&
                   (bot.process.type == ProcessType.Load ||
                   bot.process.type == ProcessType.Unload ||
                   bot.process.type == ProcessType.Print)

            PropertyChanges {
                target: snipMaterial
                visible: !snipMaterialAlertAcknowledged
            }

            PropertyChanges {
                target: main_instruction_text
                text: "MATERIAL LOADING"
                anchors.topMargin: 160
            }

            PropertyChanges {
                target: instruction_description_text
                text: "Helper motors are pushing material\nup to the extruder. This can take up to\n30 seconds."
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
            when: (extruderFilamentSwitch || isExternalLoad) &&
                  bot.process.stateType == ProcessStateType.Preheating &&
                  (bot.process.type == ProcessType.Load ||
                   bot.process.type == ProcessType.Unload ||
                   bot.process.type == ProcessType.Print)

            PropertyChanges {
                target: snipMaterial
                visible: false
            }

            PropertyChanges {
                target: main_instruction_text
                text: (targetTemperature > currentTemperature) ?
                          "EXTRUDER " + bayID + " IS\nHEATING UP" :
                          "EXTRUDER " + bayID + " IS\nCOOLING DOWN"
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
                text: currentTemperature + "C"
                visible: true
            }

            PropertyChanges {
                target: extruder_target_temperature_text
                text: targetTemperature + "C"
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
                target: main_instruction_text
                text: "EXTRUSION CONFIRMATION"
                anchors.topMargin: 120
            }

            PropertyChanges {
                target: instruction_description_text
                text: "Look inside of the printer and wait until you see material begin to extrude."
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
                label: "CONFIRM\nMATERIAL EXTRUSION"
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
                   bot.process.type == ProcessType.Print)

            PropertyChanges {
                target: snipMaterial
                visible: false
            }

            PropertyChanges {
                target: main_instruction_text
                text: "UNLOADING"
                anchors.topMargin: 165
            }

            PropertyChanges {
                target: instruction_description_text
                text: "The material is backing out of the extruder, please wait."
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
                target: main_instruction_text
                text: "CLEAR EXCESS MATERIAL AFTER EXTRUDER COOLS DOWN"
            }

            PropertyChanges {
                target: instruction_description_text
                text: "Wait a few moments until the material has cooled. Close the build chamber and material drawer."
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
                            "DONE"
                        }
                        else if(bot.process.type == ProcessType.None) {
                            if(bayID == 1) {
                                "NEXT: LOAD SUPPORT MATERIAL"
                            } else if(bayID == 2) {
                                "DONE"
                            }
                        }
                    }
                    else {
                        "DONE"
                    }
                }
            }

            PropertyChanges {
                target: retryButton
                label: {
                    if(inFreStep) {
                        if(bot.process.type == ProcessType.Print) {
                            "RETRY PURGING"
                        }
                        else if(bot.process.type == ProcessType.None) {
                            "RETRY LOADING"
                        }
                    }
                    else {
                        "RETRY LOADING"
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
                text: bot.extruderACurrentTemp + "C"
                visible: true
            }

            PropertyChanges {
                target: extruder_target_temperature_text
                text: bot.extruderBCurrentTemp + "C"
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
                target: main_instruction_text
                text: "REWIND SPOOL"
                anchors.topMargin: 120
            }

            PropertyChanges {
                target: instruction_description_text
                text: "Open material bay " +
                      bayID +
                      " and carefully rewind the material onto the spool. Secure the end of the material inside the smart spool bag and seal. Close the bay door."
                anchors.topMargin: 30
            }

            PropertyChanges {
                target: acknowledgeButton
                buttonWidth: 120
                anchors.topMargin: 30
                opacity: 1
                label: "DONE"
            }

            PropertyChanges {
                target: retryButton
                label: {
                    if(inFreStep) {
                        if(bot.process.type == ProcessType.Print) {
                            "RETRY UNLOADING"
                        }
                        else if(bot.process.type == ProcessType.None) {
                            "RETRY UNLOADING"
                        }
                    }
                    else {
                        "RETRY UNLOADING"
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
                target: main_instruction_text
                width: 300
                text: {
                    switch(bot.process.type) {
                      case ProcessType.Load:
                          "FILAMENT LOADING FAILED"
                          break;
                      case ProcessType.Unload:
                          "FILAMENT UNLOADING FAILED"
                          break;
                    }
                }
            }

            PropertyChanges {
                target: instruction_description_text
                text: "Error " + errorCode
            }

            PropertyChanges {
                target: acknowledgeButton
                buttonWidth: 120
                anchors.topMargin: 50
                opacity: 1
                label: "DONE"
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
