import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import StorageFileTypeEnum 1.0
import ErrorTypeEnum 1.0
import FreStepEnum 1.0

Item {
    anchors.fill: parent
    smooth: false
    property string fileName: "unknown.makerbot"
    property string file_name
    property string print_time
    property bool model_extruder_used
    property bool support_extruder_used
    property string print_model_material
    property string print_support_material
    property string uses_support
    property string uses_raft
    property string model_mass
    property string support_mass
    property real modelMaterialRequired
    property real supportMaterialRequired
    property int num_shells
    property real layer_height_mm
    property string extruder_temp
    property string buildplane_temp
    property string slicer_name
    property string print_job_id
    property string print_token
    property string print_url_prefix
    property string readyByTime
    property int lastPrintTimeSec
    property alias printingDrawer: printingDrawer
    property alias sortingDrawer: sortingDrawer
    property alias buttonCancelPrint: printingDrawer.buttonCancelPrint
    property alias buttonPausePrint: printingDrawer.buttonPausePrint
    property alias buttonUsbStorage: buttonUsbStorage
    property alias buttonInternalStorage: buttonInternalStorage
    property bool browsingUsbStorage: false
    property alias printSwipeView: printSwipeView
    property bool printFromUI: false
    property bool printAgain: false
    property alias printStatusView: printStatusView
    property alias reviewTestPrint: reviewTestPrint
    property alias printErrorScreen: errorScreen
    readonly property int waitToCoolTemperature: 70
    property bool isFileCopying: storage.fileIsCopying
    property alias nylonCFPrintTipPopup: nylonCFPrintTipPopup

    onIsFileCopyingChanged: {
        if(isFileCopying &&
           mainSwipeView.currentIndex == MoreporkUI.PrintPage) {
            copyingFilePopup.open()
        }
    }

    property string print_model_material_name: bot.getMaterialName(print_model_material)
    property string print_support_material_name: bot.getMaterialName(print_support_material)
    property string print_material:
        (model_extruder_used? print_model_material_name : "") +
        (support_extruder_used? "+" + print_support_material_name : "")

    property bool isFileCopySuccessful: storage.fileCopySucceeded
    property bool internalStorageFull: false

    property bool usbStorageConnected: storage.usbStorageConnected
    onUsbStorageConnectedChanged: {
        if(!storage.usbStorageConnected) {
            if(printSwipeView.currentIndex != PrintPage.BasePage &&
                    browsingUsbStorage) {
                setDrawerState(false)
                printSwipeView.swipeToItem(PrintPage.BasePage)
            }
            if(safeToRemoveUsbPopup.opened) {
                bot.acknowledgeSafeToRemoveUsb()
                safeToRemoveUsbPopup.close()
            }
        }
    }

    property bool isPrintProcess: bot.process.type == ProcessType.Print
    onIsPrintProcessChanged: {
        if(isPrintProcess) {
            storage.backStackClear()
            //Move to index 0 of print page swipe
            //view when print process actually starts
            //assuming the user had navigated to other
            //pages before the print starts.
            resetSettingsSwipeViewPages()
            mainSwipeView.swipeToItem(MoreporkUI.PrintPage)
            printSwipeView.swipeToItem(PrintPage.BasePage)
            setDrawerState(false)
            activeDrawer = printPage.printingDrawer
            setDrawerState(true)
            if(printFromQueueState == PrintPage.WaitingToStartPrint) {
                checkStartQueuedPrintTimeout.stop()
                printQueuePopup.close()
            }
            if(!printFromUI) {
                getPrintDetailsTimer.start() //for prints started from repl
            }
            printFromUI = false //reset when the print actually starts
            printStatusView.acknowledgePrintFinished.failureFeedbackSelected = false // Reset when print starts
            showPrintTip()
            startPrintSource = PrintPage.None

            // Reset material page states when (an external) print process starts
            // so that the user isn't stuck on the material loading screen if
            // they had it open. Since this is the same cleanup signal at the
            // end of (mid-print) loading it takes us directly to the printing
            // screen too as a good side effect.
            materialPage.loadUnloadFilamentProcess.processDone()
        }
        else {
            printStatusView.printStatusSwipeView.setCurrentIndex(PrintStatusView.Page0)
            setDrawerState(false)
            // Only reset at end of 'Print Process'
            // if 'Print Again' option isn't used
            if(!printAgain) {
                storage.currentThingReset()
                resetPrintFileDetails()
            }
            printAgain = false
        }
    }

    property bool isPrintFileValid: bot.process.printFileValid
    onIsPrintFileValidChanged: {
        if(isPrintFileValid) {
            updateCurrentThing()
            showPrintTip()
        }
    }

    Timer {
        id: getPrintDetailsTimer
        interval: 3000
        onTriggered: {
            updateCurrentThing()
            this.stop()
        }
    }

    property bool isPrintFinished: bot.process.stateType == ProcessStateType.Completed ||
                                   bot.process.stateType == ProcessStateType.Failed

    onIsPrintFinishedChanged: {
        if(isPrintFinished) {
            print_time = getTimeInDaysHoursMins(bot.process.elapsedTime)
        }
    }

    WaitToCoolChamberScreen {
        id: waitToCoolChamber
        z: 1
        anchors.verticalCenterOffset: -20
        visible: waitToCoolChamberScreenVisible
        continueButton.button_mouseArea.onClicked: {
            waitToCoolChamberScreenVisible = false
        }
    }

    property bool isPrintDone: bot.process.stateType == ProcessStateType.Completed ||
                               bot.process.stateType == ProcessStateType.Failed ||
                               bot.process.stateType == ProcessStateType.Cancelling
    onIsPrintDoneChanged: {
        if(isPrintDone && bot.buildplaneCurrentTemp > waitToCoolTemperature) {
            waitToCoolChamber.waitToCoolChamberScreenVisible = true
            waitToCoolChamber.startTimer()
        }
    }

    function getTimeInDaysHoursMins(seconds) {
        var time = new Date("", "", "", "", "", seconds)
        return (time.getDate() != 31 ? time.getDate() + "D " + time.getHours() + "HR " + time.getMinutes() + "M" :
                                       time.getHours() != 0 ? time.getHours() + "HR " + time.getMinutes() + "M" :
                                                              time.getMinutes() + "M")
    }

    function getPrintFileDetails(file) {
        var printTimeSec = file.timeEstimateSec
        fileName = file.filePath + "/" + file.fileName
        file_name = file.fileBaseName
        model_extruder_used = file.extruderUsedA
        support_extruder_used = file.extruderUsedB
        print_model_material = file.materialA
        print_support_material = file.materialB
        uses_support = file.usesSupport ? "YES" : "NO"
        uses_raft = file.usesRaft ? "YES" : "NO"
        model_mass = file.extrusionMassGramsA < 1000 ? file.extrusionMassGramsA.toFixed(1) + " g" :
                                                       (file.extrusionMassGramsA * 0.001).toFixed(1) + " Kg"
        support_mass = file.extrusionMassGramsB < 1000 ? file.extrusionMassGramsB.toFixed(1) + " g" :
                                                         (file.extrusionMassGramsB * 0.001).toFixed(1) + " Kg"
        modelMaterialRequired = (file.extrusionMassGramsA/1000).toFixed(3)
        supportMaterialRequired = (file.extrusionMassGramsB/1000).toFixed(3)
        layer_height_mm = file.layerHeightMM.toFixed(2)
        num_shells = file.numShells
        extruder_temp = !file.extruderUsedB ? file.extruderTempCelciusA + "C" :
                                              file.extruderTempCelciusA + "C" + " + " + file.extruderTempCelciusB + "C"
        buildplane_temp = file.buildplaneTempCelcius + "C"
        slicer_name = file.slicerName
        getPrintTimes(printTimeSec)
    }

    function disconnectHandlers() {
        print_queue.onFetchMetadataSuccessful.disconnect(getQueuedPrintFileDetails)
        print_queue.onFetchMetadataFailed.disconnect(fetchMetadataFailed)
        print_queue.onFetchMetadataCancelled.disconnect(fetchMetadataCancelled)
    }

    function getQueuedPrintFileDetails(meta, shouldDisconnectHandlers = true) {
        if(shouldDisconnectHandlers) {
            disconnectHandlers()
        }
        var printTimeSec = meta['duration_s']
        model_extruder_used = meta['extrusion_distances_mm'][0] > 0 ? true : false
        support_extruder_used = meta['extrusion_distances_mm'][1] > 0 ? true : false
        print_model_material = meta['materials'][0]
        print_support_material = meta['materials'][1]
        model_mass = meta['extrusion_masses_g'][0] < 1000 ?
                        meta['extrusion_masses_g'][0].toFixed(1) + " g" :
                        (meta['extrusion_masses_g'][0] * 0.001).toFixed(1) + " Kg"
        support_mass = meta['extrusion_masses_g'][1] < 1000 ?
                        meta['extrusion_masses_g'][1].toFixed(1) + " g" :
                        (meta['extrusion_masses_g'][1] * 0.001).toFixed(1) + " Kg"
        modelMaterialRequired = (meta['extrusion_masses_g'][0]/1000).toFixed(3)
        supportMaterialRequired = (meta['extrusion_masses_g'][1]/1000).toFixed(3)
        extruder_temp = !support_extruder_used ?
                            meta['extruder_temperatures'][0] + "C" :
                            meta['extruder_temperatures'][0] + "C" + " + " + meta['extruder_temperatures'][1] + "C"
        buildplane_temp = Math.round(meta['buildplane_target_temperature']) + "C"
        getPrintTimes(printTimeSec)
        printQueuePopup.close()
        if(!startPrintMaterialCheck()) {
            startPrintErrorsPopup.open()
        }
        else {
            startPrintSource = PrintPage.FromPrintQueue
            printSwipeView.swipeToItem(PrintPage.StartPrintConfirm)
        }
    }

    function fetchMetadataFailed() {
        disconnectHandlers()
        printFromQueueState = PrintPage.FailedToGetPrintDetails
    }

    function fetchMetadataCancelled() {
        disconnectHandlers()
    }

    function resetPrintFileDetails() {
        fileName = ""
        file_name = ""
        print_time = ""
        model_extruder_used = false
        support_extruder_used = false
        print_model_material = ""
        print_support_material = ""
        uses_support = ""
        uses_raft = ""
        model_mass = ""
        support_mass = ""
        modelMaterialRequired = 0.0
        supportMaterialRequired = 0.0
        num_shells = ""
        extruder_temp = ""
        buildplane_temp = ""
        slicer_name = ""
        startPrintWithUnknownMaterials = false
        print_job_id = ""
        print_token = ""
        print_url_prefix = ""
    }

    // Compute print time, print end time & get them in string format for UI.
    // Called when selecting a file for print & also while clicking print again
    // at the end of a print to get new end time.
    function getPrintTimes(printTimeSec) {
        lastPrintTimeSec = printTimeSec
        print_time = getTimeInDaysHoursMins(printTimeSec)
        var currentTime = new Date()
        var endMS = currentTime.getTime() + printTimeSec*1000
        var endTime = new Date()
        endTime.setTime(endMS)
        var daysLeft = endTime.getDate() - currentTime.getDate()
        var doneByDayString = daysLeft > 1 ? daysLeft + " DAYS LATER" : daysLeft == 1 ? "TOMMORROW" : "TODAY"
        var doneByTimeString = endTime.getHours() % 12 == 0 ? endTime.getMinutes() < 10 ? "12" + ":0" + endTime.getMinutes() :
                                                                                          "12" + ":" + endTime.getMinutes() :
                                                              endTime.getMinutes() < 10 ? endTime.getHours() % 12 + ":0" + endTime.getMinutes() :
                                                                                          endTime.getHours() % 12 + ":" + endTime.getMinutes()
        var doneByMeridianString = endTime.getHours() >= 12 ? "PM" : "AM"
        readyByTime = doneByTimeString + " " + doneByMeridianString + " " + doneByDayString
    }

    PrintingDrawer {
        id: printingDrawer
    }

    SortDrawer {
        id: sortingDrawer
    }

    enum SwipeIndex {
        BasePage,
        FileBrowser,
        PrintQueueBrowser,
        StartPrintConfirm,
        FileInfoPage
    }

    enum QueuedPrintState {
        None,
        FetchingPrintDetails,
        FailedToGetPrintDetails,
        WaitingToStartPrint,
        FailedToStartPrint
    }

    property int startPrintSource: PrintPage.None
    enum StartPrintSource {
        None,
        FromLocal,
        FromPrintQueue
    }

    property int printFromQueueState: PrintPage.None
    onPrintFromQueueStateChanged: {
        if(printFromQueueState != PrintPage.None) {
            printQueuePopup.open()
        }
        if(printFromQueueState == PrintPage.WaitingToStartPrint) {
            checkStartQueuedPrintTimeout.start()
        }
    }

    Timer {
        id: checkStartQueuedPrintTimeout
        interval: 30000
        onTriggered: {
            if(printFromQueueState == PrintPage.WaitingToStartPrint) {
                printFromQueueState = PrintPage.FailedToStartPrint
            }
        }
    }

    LoggingSwipeView {
        id: printSwipeView
        logName: "printSwipeView"
        currentIndex: PrintPage.BasePage

        function customSetCurrentItem(swipeToIndex) {
            if(swipeToIndex == PrintPage.BasePage) {
                // When swiping to the 0th index of this swipeview set the
                // mainSwipeView page item that holds this page as the current
                // item since we want the back button to use the mainSwipeView
                // items' altBack()
                setCurrentItem(mainSwipeView.itemAt(MoreporkUI.PrintPage))
                return true
            }
        }

        // PrintPage.BasePage
        Item {
            id: itemPrintStorageOpt
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: mainSwipeView
            property int backSwipeIndex: 0
            smooth: false

            Flickable {
                id: flickableStorageOpt
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnStorageOpt.height
                visible: !isPrintProcess

                Column {
                    id: columnStorageOpt
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    StorageTypeButton {
                        id: buttonQueuedPrints
                        storageThumbnail.source: "qrc:/img/icon_directory.png"
                        storageThumbnailSourceSize.width: 47
                        storageThumbnailSourceSize.height: 43
                        storageThumbnail.anchors.leftMargin: 71
                        storageName: qsTr("QUEUE")
                        storageDescription: qsTr("FROM CLOUDPRINT")
                        onClicked: {
                            printSwipeView.swipeToItem(PrintPage.PrintQueueBrowser)
                        }
                    }

                    StorageTypeButton {
                        id: buttonUsbStorage
                        storageThumbnail.source: "qrc:/img/icon_usb.png"
                        storageThumbnailSourceSize.width: 45
                        storageThumbnailSourceSize.height: 53
                        storageThumbnail.anchors.leftMargin: 72
                        storageName: qsTr("USB")
                        storageDescription: usbStorageConnected ? qsTr("EXTERNAL STORAGE") : qsTr("PLEASE INSERT A USB DRIVE")
                        enabled: usbStorageConnected
                        onClicked: {
                            if(usbStorageConnected) {
                                browsingUsbStorage = true
                                storage.setStorageFileType(StorageFileType.Print)
                                storage.updatePrintFileList("?root_usb?")
                                activeDrawer = printPage.sortingDrawer
                                setDrawerState(true)
                                printSwipeView.swipeToItem(PrintPage.FileBrowser)
                            }
                        }
                    }

                    StorageTypeButton {
                        id: buttonInternalStorage
                        storageThumbnail.source: "qrc:/img/icon_sombrero.png"
                        storageThumbnailSourceSize.width: 34
                        storageThumbnailSourceSize.height: 45
                        storageThumbnail.anchors.leftMargin: 77
                        storageName: qsTr("INTERNAL STORAGE")
                        storageDescription: qsTr("FILES SAVED ON PRINTER")
                        storageUsed: Math.min(diskman.internalUsed.toFixed(1), 100)
                        onClicked: {
                            browsingUsbStorage = false
                            storage.setStorageFileType(StorageFileType.Print)
                            storage.updatePrintFileList("?root_internal?")
                            activeDrawer = printPage.sortingDrawer
                            setDrawerState(true)
                            printSwipeView.swipeToItem(PrintPage.FileBrowser)
                        }
                    }
                }
            }

            PrintStatusViewForm {
                id: printStatusView
                smooth: false
                // The error scrren visibility controls the
                // normal print status view screen visibility.
                visible: isPrintProcess && !errorScreen.visible
                fileName_: file_name
                filePathName: fileName
                support_mass_: support_mass
                model_mass_: model_mass
                uses_support_: uses_support
                uses_raft_: uses_raft
                print_time_: print_time
                print_model_material_: print_model_material_name
                print_support_material_: print_support_material_name
                model_extruder_used_: model_extruder_used
                support_extruder_used_: support_extruder_used
            }

            ErrorScreen {
                id: errorScreen
                isActive: bot.process.type == ProcessType.Print
                visible: {
                    isPrintProcess &&
                    (bot.process.stateType == ProcessStateType.Pausing ||
                     bot.process.stateType == ProcessStateType.Paused ||
                     bot.process.stateType == ProcessStateType.Failed ||
                     // Out of filament while printing, which should
                     // still show the error handling screen.
                     bot.process.stateType == ProcessStateType.UnloadingFilament ||
                     bot.process.stateType == ProcessStateType.Preheating) &&
                    lastReportedErrorType != ErrorType.NoError
                }
            }

            ReviewTestPrintPage {
                id: reviewTestPrint
                visible: inFreStep && printStatusView.testPrintComplete
            }
        }

        // PrintPage.FileBrowser
        Item {
            id: itemFileBrowser
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: printSwipeView
            property int backSwipeIndex: PrintPage.BasePage
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                resetPrintFileDetails()
                var backDir = storage.backStackPop()
                if(backDir !== "") {
                    storage.updatePrintFileList(backDir)
                }
                else {
                    setDrawerState(false)
                    printSwipeView.swipeToItem(PrintPage.BasePage)
                }
            }

            Text {
                id: noFilesText
                color: "#ffffff"
                font.weight: Font.Bold
                text: qsTr("NO PRINTABLE FILES")
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -40
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 19
                font.letterSpacing: 2
                visible: storage.storageIsEmpty

                Text {
                    color: "#ffffff"
                    font.family: "Antennae"
                    font.weight: Font.Light
                    text: qsTr("Choose another folder or export a .MakerBot\nfile from the MakerBot Print app.")
                    anchors.top: parent.bottom
                    anchors.topMargin: 15
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 17
                    font.letterSpacing: 1
                    lineHeight: 1.4
                }
            }

            ListView {
                id: fileList
                smooth: false
                anchors.fill: parent
                boundsBehavior: Flickable.DragOverBounds
                spacing: 1
                orientation: ListView.Vertical
                flickableDirection: Flickable.VerticalFlick
                ScrollBar.vertical: ScrollBar {}
                visible: !storage.storageIsEmpty
                model: storage.printFileList
                delegate:
                    FileButton {
                    id: filebutton
                    property int printTimeSecRaw: model.modelData.timeEstimateSec
                    property int printTimeMinRaw: printTimeSecRaw/60
                    property int printTimeHrRaw: printTimeMinRaw/60
                    property int printTimeDay: printTimeHrRaw/24
                    property int printTimeMin: printTimeMinRaw % 60
                    property int printTimeHr: printTimeHrRaw % 24
                    smooth: false
                    antialiasing: false
                    fileThumbnail.source: "image://thumbnail/" +
                                          model.modelData.filePath + "/" + model.modelData.fileName
                    filenameText.text: model.modelData.fileBaseName
                    fileDesc_rowLayout.visible: !model.modelData.isDir
                    filePrintTime.text: printTimeDay != 0 ?
                                            (printTimeDay + "D" + printTimeHr + "HR" + printTimeMin + "M") :
                                            (printTimeHr != 0 ? printTimeHr + "HR " + printTimeMin + "M" : printTimeMin + "M")
                    fileMaterial.text: {
                        if (model.modelData.extruderUsedA && model.modelData.extruderUsedB) {
                            bot.getMaterialName(model.modelData.materialA) + "+" +
                            bot.getMaterialName(model.modelData.materialB)
                        } else if (model.modelData.extruderUsedA && !model.modelData.extruderUsedB) {
                            bot.getMaterialName(model.modelData.materialA)
                        } else {
                            defaultString
                        }
                    }
                    materialError.visible: {
                        if (model.modelData.extruderUsedA && model.modelData.extruderUsedB) {
                            materialPage.bay1.usingExperimentalExtruder ?
                                (model.modelData.materialB != materialPage.bay2.filamentMaterial) :
                                (model.modelData.materialA != materialPage.bay1.filamentMaterial ||
                                 model.modelData.materialB != materialPage.bay2.filamentMaterial)
                        } else if (model.modelData.extruderUsedA && !model.modelData.extruderUsedB) {
                            materialPage.bay1.usingExperimentalExtruder ?
                                    false :
                                    model.modelData.materialA != materialPage.bay1.filamentMaterial
                        } else {
                            false
                        }

                    }
                    onClicked: {
                        if(model.modelData.isDir) {
                            storage.backStackPush(model.modelData.filePath)
                            storage.updatePrintFileList(model.modelData.filePath + "/" + model.modelData.fileName)
                        }
                        else if(model.modelData.fileBaseName !== "No Items Present") { // Ignore default fileBaseName object
                            getPrintFileDetails(model.modelData)
                            if(!startPrintMaterialCheck()) {
                                startPrintErrorsPopup.open()
                            }
                            else {
                                startPrintSource = PrintPage.FromLocal
                                setDrawerState(false)
                                startPrintInstructionsItem.acknowledged = false
                                printSwipeView.swipeToItem(PrintPage.StartPrintConfirm)
                            }
                        }
                    }

                    onPressAndHold: {
                        if(!model.modelData.isDir) {
                            // There is functionality in Qt 5.11 to get touch
                            // coordinates rather than using this lame way to
                            // open the options menu always at a specific position
                            // on the file button.
                            optionsMenu.popup(filebutton.x + 700, filebutton.y - fileList.contentY + 25)
                            getPrintFileDetails(model.modelData)
                        }
                    }
                }

                FileOptionsPopupMenu {
                    id: optionsMenu

                }
            }
        }

        // PrintPage.PrintQueueBrowser
        Item {
            id: itemPrintQueue
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: printSwipeView
            property int backSwipeIndex: PrintPage.BasePage
            smooth: false
            visible: false

            Text {
                id: noPrintsInQueueText
                color: "#ffffff"
                font.weight: Font.Bold
                text: qsTr("NO PRINT JOBS IN QUEUE")
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -40
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 19
                font.letterSpacing: 2
                visible: bot.net.printQueueEmpty

                Text {
                    color: "#ffffff"
                    font.family: "Antennae"
                    font.weight: Font.Light
                    text: qsTr("Use MakerBot CloudPrint to add to your printer's queue.")
                    anchors.top: parent.bottom
                    anchors.topMargin: 15
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 17
                    font.letterSpacing: 1
                    lineHeight: 1.4
                }
            }

            ListView {
                id: printQueueList
                smooth: false
                anchors.fill: parent
                boundsBehavior: Flickable.DragOverBounds
                spacing: 1
                orientation: ListView.Vertical
                flickableDirection: Flickable.VerticalFlick
                ScrollBar.vertical: ScrollBar {}
                visible: true
                model: bot.net.PrintQueue
                onModelChanged: {
                    // Reset the meta cache when the print queue list changes.
                    for(var job in cachedMeta) {
                        delete cachedMeta[job]
                    }
                }

                property var cachedMeta: ({})
                delegate:
                    FileButton {
                    id: queuedPrintFilebutton
                    smooth: false
                    antialiasing: false
                    fileThumbnail.source: {
                        "image://async/" + model.modelData.urlPrefix + "+" +
                                                 model.modelData.jobId + "+" +
                                                 model.modelData.token
                    }
                    fileThumbnail.asynchronous: true
                    filenameText.text: model.modelData.fileName
                    fileDesc_rowLayout.visible: true
                    filePrintTime.text: "-"
                    fileMaterial.text: "-"
                    onHasMetaChanged: {
                        if(hasMeta) {
                            filePrintTime.text = getTimeInDaysHoursMins(metaData['duration_s'])
                            fileMaterial.text = metaData['extrusion_distances_mm'][0] && metaData['extrusion_distances_mm'][1] ?
                                                bot.getMaterialName(metaData['materials'][0]) + "+" + bot.getMaterialName(metaData['materials'][1]) :
                                                bot.getMaterialName(metaData['materials'][0])
                        }
                    }

                    materialError.visible: {
                        if (!hasMeta) {
                            false
                        } else if (metaData['extrusion_distances_mm'][0] && metaData['extrusion_distances_mm'][1]) {
                            materialPage.bay1.usingExperimentalExtruder ?
                                (metaData['materials'][1] != materialPage.bay2.filamentMaterial) :
                                (metaData['materials'][0] != materialPage.bay1.filamentMaterial ||
                                 metaData['materials'][1] != materialPage.bay2.filamentMaterial)
                        } else if (metaData['extrusion_distances_mm'][0] && !metaData['extrusion_distances_mm'][1]) {
                            materialPage.bay1.usingExperimentalExtruder ?
                                    false :
                                    metaData['materials'][0] != materialPage.bay1.filamentMaterial
                        } else {
                            false
                        }
                    }
                    onClicked: {
                        file_name = model.modelData.fileName
                        print_job_id = model.modelData.jobId
                        print_token = model.modelData.token
                        print_url_prefix = model.modelData.urlPrefix
                        if(!hasMeta) {
                            // Blocking fetch for one file. This is probably no longer
                            // required and can use the async call as well.
                            printFromQueueState = PrintPage.FetchingPrintDetails
                            print_queue.onFetchMetadataSuccessful.connect(getQueuedPrintFileDetails)
                            print_queue.onFetchMetadataFailed.connect(fetchMetadataFailed)
                            print_queue.onFetchMetadataCancelled.connect(fetchMetadataCancelled)
                            print_queue.fetchPrintMetadata(model.modelData.urlPrefix,
                                                           model.modelData.jobId,
                                                           model.modelData.token)
                        } else {
                            // Meta already downloaded by async fetch, so go directly to
                            // the start print page. Images in the start print page are
                            // separately fetched asynchronously.
                            getQueuedPrintFileDetails(metaData, false)
                        }
                    }

                    Component.onCompleted: {
                        // Since components are dynamically created and destroyed based
                        // on whether they are currently visible in the viewport, we dont
                        // want to be fetching the metadata repeatedly, just because
                        // we're scrolling up and down through the list, so we check whether
                        // we have cached this print job's meta to quickly load from.
                        if(model.modelData.jobId in printQueueList.cachedMeta) {
                            metaData = printQueueList.cachedMeta[model.modelData.jobId]
                            hasMeta = true
                            metaCached = true
                        }
                        // Asynchronously fetch the metadata for this print job, if we
                        // can't find it in the cache. Since listview does lazy loading
                        // of elements the async requests are only made when neccessary.
                        // i.e when the elements come into the viewport.
                        if(!hasMeta) {
                            // This creates a new thread and returns immediately,
                            // The callback is executed once the thread finishes
                            // running.
                            print_queue.asyncFetchMeta(model.modelData.urlPrefix,
                                                  model.modelData.jobId,
                                                  model.modelData.token,
                                                  function(response) {
                                                      if(response["success"]) {
                                                          metaData = response["meta"]
                                                          if ("build_plane_temperature" in metaData) {
                                                              metaData["buildplane_target_temperature"] =
                                                                  metaData["build_plane_temperature"]
                                                              delete metaData["build_plane_temperature"]
                                                          } else {
                                                              // Backwards compatibility, in case the user somehow lost
                                                              // the .stl, and only has older .makerbot files on hand.
                                                              metaData["buildplane_target_temperature"] =
                                                                  (metaData["chamber_temperature"] > 40) ?
                                                                  Math.round((metaData["chamber_temperature"] * 1.333) - 13) :
                                                                  metaData["chamber_temperature"]
                                                          }
                                                          hasMeta = true
                                                      }
                                                  })
                        }
                    }

                    Component.onDestruction: {
                        // Whenever a print job's button goes out of view the component
                        // might be destroyed. So we check whether its metadata has
                        // already been downloaded and cache it, if it hasn't already
                        // been.
                        // The metadata cache is cleared anytime the print queue list
                        // chnages. (see onModelChanged())
                        if(hasMeta && !metaCached) {
                            printQueueList.cachedMeta[model.modelData.jobId] = metaData
                        }
                    }
                }
            }
        }

        // PrintPage.StartPrintConfirm
        Item {
            id: itemStartPrint
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: printSwipeView
            property int backSwipeIndex: isPrintProcess ?
                                             PrintPage.BasePage :
                                             startPrintSource == PrintPage.FromPrintQueue ?
                                                 PrintPage.PrintQueueBrowser :
                                                 PrintPage.FileBrowser
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    startPrintItem.startPrintSwipeView.setCurrentIndex(StartPrintPage.BasePage)
                    if(startPrintSource == PrintPage.FromLocal) {
                        resetPrintFileDetails()
                        setDrawerState(true)
                    }
                    currentItem.backSwiper.swipeToItem(currentItem.backSwipeIndex)
                    startPrintSource = PrintPage.None
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                startPrintItem.startPrintSwipeView.setCurrentIndex(StartPrintPage.BasePage)
                resetPrintFileDetails()
                setDrawerState(false)
                printSwipeView.swipeToItem(PrintPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            StartPrintSpecialInstructions {
                id: startPrintInstructionsItem
                z: 1
            }

            StartPrintPage {
                id: startPrintItem
            }
        }

        // PrintPage.FileInfoPage
        Item {
            id: itemPrintInfoOpt
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: printSwipeView
            property int backSwipeIndex: isPrintProcess ? PrintPage.BasePage : PrintPage.StartPrintConfirm
            smooth: false
            visible: false

            ColumnLayout {
                id: layout
                width: 600
                spacing: 10
                anchors.left: parent.left
                anchors.leftMargin: 65
                anchors.top: parent.top
                anchors.topMargin: 50
                smooth: false

                InfoItem {
                    id: printInfo_fileName
                    labelText: qsTr("Filename")
                    dataText: file_name
                }

                InfoItem {
                    id: printInfo_timeEstimate
                    labelText: qsTr("Print Time Estimate")
                    dataText: print_time
                }

                InfoItem {
                    id: printInfo_material
                    labelText: qsTr("Print Material")
                    dataText: print_material
                }

                InfoItem {
                    id: printInfo_usesSupport
                    labelText: qsTr("Supports")
                    dataText: uses_support
                    visible: false
                }

                InfoItem {
                    id: printInfo_usesRaft
                    labelText: qsTr("Rafts")
                    dataText: uses_raft
                    visible: false
                }

                InfoItem {
                    id: printInfo_modelMass
                    labelText: qsTr("Model")
                    dataText: model_mass
                }

                InfoItem {
                    id: printInfo_supportMass
                    labelText: qsTr("Support")
                    dataText: support_mass
                    visible: support_extruder_used
                }

                InfoItem {
                    id: printInfo_Shells
                    labelText: qsTr("Shells")
                    dataText: num_shells
                    visible: false
                }

                InfoItem {
                    id: printInfo_extruderTemperature
                    labelText: qsTr("Extruder Temperature")
                    dataText: extruder_temp
                }

                InfoItem {
                    id: printInfo_buildplaneTemperature
                    labelText: qsTr("Chamber Temp. (Build Plane)")
                    dataText: buildplane_temp
                    labelElement.font.pixelSize: 16
                    labelElement.font.letterSpacing: 2
                }

                InfoItem {
                    id: printInfo_slicerName
                    labelText: qsTr("Slicer Name")
                    dataText: slicer_name
                    visible: false
                }
            }
        }
    }

    CustomPopup {
        popupName: "CopyFileToInternalStorage"
        id: copyingFilePopup
        popupWidth: 720
        popupHeight: 265

        onClosed: {
            internalStorageFull = false
        }

        showTwoButtons: isFileCopySuccessful || internalStorageFull
        left_button_text: internalStorageFull ? qsTr("OK") : qsTr("DONE")
        left_button.onClicked: {
            copyingFilePopup.close()
        }

        right_button_text: internalStorageFull ? qsTr("VIEW FILES") : qsTr("VIEW FILE")
        right_button.onClicked: {
            browsingUsbStorage = false
            storage.setStorageFileType(StorageFileType.Print)
            storage.updatePrintFileList("?root_internal?")
            activeDrawer = printPage.sortingDrawer
            setDrawerState(true)
            printSwipeView.swipeToItem(PrintPage.FileBrowser)
            copyingFilePopup.close()
        }

        showOneButton: isFileCopying
        full_button_text: qsTr("CANCEL")
        full_button.onClicked: {
            storage.cancelCopy()
            copyingFilePopup.close()
        }

        ColumnLayout {
            id: columnLayout_copy_file_popup
            width: 590
            height: children.height
            spacing: 35
            anchors.top: parent.top
            anchors.topMargin: 150
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: alert_text_copy_file_popup
                color: "#cbcbcb"
                text: {
                    if(internalStorageFull) {
                        qsTr("PRINTER STORAGE IS FULL")
                    } else if(isFileCopying) {
                        qsTr("COPYING")
                    } else if(isFileCopySuccessful) {
                        qsTr("FILE ADDED")
                    } else {
                        defaultString
                    }
                }
                font.letterSpacing: 3
                Layout.alignment: Qt.AlignHCenter
                font.family: "Antennae"
                font.weight: Font.Bold
                font.pixelSize: 20
            }

            Text {
                id: description_text_copy_file_popup
                color: "#cbcbcb"
                text: {
                    if (internalStorageFull) {
                        qsTr("Remove unwanted files from the printer's internal storage to free up space")
                    } else if(isFileCopySuccessful) {
                        qsTr("<b>%1</b> has been added to internal storage.").arg(file_name)
                    } else {
                        defaultString
                    }
                }
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                font.family: "Antennae"
                font.pixelSize: 18
                font.letterSpacing: 1
                lineHeight: 1.3
                visible: isFileCopySuccessful || internalStorageFull
            }

            ProgressBar {
                id: progressBar
                Layout.alignment: Qt.AlignHCenter
                value: (storage.fileCopyProgress).toFixed(2)
                visible: isFileCopying
            }
        }
    }

    CustomPopup {
        popupName: "NylonCFPrintTip"
        id: nylonCFPrintTipPopup
        popupWidth: 720
        popupHeight: 275
        showTwoButtons: true
        left_button_text: qsTr("OK")
        left_button.onClicked: {
            nylonCFPrintTipPopup.close()
        }

        right_button_text: qsTr("DON'T REMIND ME AGAIN")
        right_button.onClicked: {
            settings.setShowNylonCFAnnealPrintTip(false)
            nylonCFPrintTipPopup.close()
        }

        ColumnLayout {
            id: columnLayout_nylon_cf_print_tip_popup
            width: 650
            height: 150
            anchors.top: parent.top
            anchors.topMargin: 125
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: title_nylon_cf_print_tip_popup
                color: "#cbcbcb"
                text: qsTr("NYLON CARBON FIBER TIP")
                font.letterSpacing: 3
                Layout.alignment: Qt.AlignHCenter
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 20
            }

            Text {
                id: description_nylon_cf_print_tip_popup
                color: "#cbcbcb"
                text: qsTr("After dissolving the support material away, annealing your print will remove any moisture from it and enhance its strength. Just place the print in the build chamber and tap settings > anneal print.")
                horizontalAlignment: Text.AlignHCenter
                Layout.maximumWidth: 575
                //Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                font.family: defaultFont.name
                font.pixelSize: 18
                lineHeight: 1.1
            }
        }
    }

    CustomPopup {
        popupName: "CloudPrintQueue"
        id: printQueuePopup
        popupWidth: 720
        popupHeight: 320
        visible: false
        showOneButton: {
            if(printFromQueueState == PrintPage.FetchingPrintDetails ||
               printFromQueueState == PrintPage.FailedToStartPrint ||
               printFromQueueState == PrintPage.FailedToGetPrintDetails) {
                true
            } else if(printFromQueueState == PrintPage.WaitingToStartPrint) {
                false
            } else {
                false
            }
        }
        full_button_text: {
            if(printFromQueueState == PrintPage.FetchingPrintDetails) {
                "CANCEL"
            } else if(printFromQueueState == PrintPage.FailedToStartPrint ||
                      printFromQueueState == PrintPage.FailedToGetPrintDetails) {
                "OK"
            } else {
                defaultString
            }
        }
        full_button.onClicked: {
            if(printFromQueueState == PrintPage.FetchingPrintDetails) {
                print_queue.cancelRequest(print_url_prefix, print_job_id)
            }
            printQueuePopup.close()
        }
        onClosed: {
            printFromQueueState = PrintPage.None
        }

        ColumnLayout {
            id: columnLayout_print_queue_popup
            width: 650
            height: children.height
            spacing: 35
            anchors.top: parent.top
            anchors.topMargin: 140
            anchors.horizontalCenter: parent.horizontalCenter

            BusySpinner {
                id: waitingSpinner
                spinnerActive: true
                spinnerSize: 64
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            Text {
                id: alert_text_print_queue_popup
                color: "#cbcbcb"
                font.letterSpacing: 3
                Layout.alignment: Qt.AlignHCenter
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 20
            }

            states: [
                State {
                    name: "fetching_print_details"
                    when: printFromQueueState == PrintPage.FetchingPrintDetails

                    PropertyChanges {
                        target: columnLayout_print_queue_popup
                        anchors.topMargin: 140
                    }

                    PropertyChanges {
                        target: alert_text_print_queue_popup
                        text: qsTr("LOADING PRINT DETAILS...")
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        spinnerActive: true
                    }
                },
                State {
                    name: "failed_to_get_print_details"
                    when: printFromQueueState == PrintPage.FailedToGetPrintDetails

                    PropertyChanges {
                        target: columnLayout_print_queue_popup
                        anchors.topMargin: 185
                    }

                    PropertyChanges {
                        target: alert_text_print_queue_popup
                        text: qsTr("Failed to get print details.")
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        spinnerActive: false
                    }
                },
                State {
                    name: "waiting_to_start_print"
                    when: printFromQueueState == PrintPage.WaitingToStartPrint

                    PropertyChanges {
                        target: columnLayout_print_queue_popup
                        anchors.topMargin: 160
                    }

                    PropertyChanges {
                        target: alert_text_print_queue_popup
                        text: qsTr("Your print will start momentarily...")
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        spinnerActive: true
                    }
                },
                State {
                    name: "failed_to_start_print"
                    when: printFromQueueState == PrintPage.FailedToStartPrint

                    PropertyChanges {
                        target: columnLayout_print_queue_popup
                        anchors.topMargin: 180
                    }

                    PropertyChanges {
                        target: alert_text_print_queue_popup
                        text: qsTr("Failed to start the print.")
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        spinnerActive: false
                    }
                }
            ]
        }
    }

    CustomPopup {
        popupName: "PrintFeedbackAcknowledgement"
        id: printFeedbackAcknowledgementPopup
        popupWidth: 720
        popupHeight: 275
        showOneButton: true
        full_button_text: qsTr("OK")
        full_button.onClicked: {
            printFeedbackAcknowledgementPopup.close()
            acknowledgePrint()
        }
        onOpened: {
            autoClosePopup.start()
        }
        onClosed: {
            autoClosePopup.stop()
        }

        property bool feedbackGood: true

        Timer {
            id: autoClosePopup
            interval: 7000
            onTriggered: printFeedbackAcknowledgementPopup.close()
        }

        ColumnLayout {
            id: columnLayout_printFeedbackAcknowledgementPopup
            width: 590
            height: children.height
            spacing: 20
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -30
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: alert_text_printFeedbackAcknowledgementPopup
                color: "#cbcbcb"
                text: qsTr("FEEDBACK SUBMITTED")
                font.letterSpacing: 3
                Layout.alignment: Qt.AlignHCenter
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 20
            }

            Text {
                id: description_text_printFeedbackAcknowledgementPopup
                color: "#cbcbcb"
                text: {
                    if(printFeedbackAcknowledgementPopup.feedbackGood) {
                        qsTr("Thanks for providing feedback. This will help us make improvements to your printer.")
                    } else {
                        qsTr("We are sorry that your print had trouble. If problems continue, please visit support.makerbot.com")
                    }
                }
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                font.family: defaultFont.name
                font.pixelSize: 18
                font.letterSpacing: 1
                lineHeight: 1.3
            }
        }
    }
}
