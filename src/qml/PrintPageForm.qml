import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import StorageFileTypeEnum 1.0
import ErrorTypeEnum 1.0
import FreStepEnum 1.0
import MachineTypeEnum 1.0

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
    property string buildplatform_temp
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
    property bool isFileCopying: storage.fileIsCopying
    property bool isFileDownloading: print_queue.downloading
    property bool fileDownloadFailed: print_queue.downloadingFailed
    property alias nylonCFPrintTipPopup: nylonCFPrintTipPopup
    property alias startPrintPopup: startPrintPopup

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

    property bool isFileCopySuccessful: storage.fileCopySucceeded || print_queue.downloadingSucceeded
    property bool internalStorageFull: false

    property bool usbStorageConnected: storage.usbStorageConnected
    onUsbStorageConnectedChanged: {
        if(!storage.usbStorageConnected) {
            if(printSwipeView.currentIndex != PrintPage.BasePage &&
               browsingUsbStorage) {
                setActiveDrawer(null)
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
            setActiveDrawer(printPage.printingDrawer)
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
            setActiveDrawer(null)
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

    function getTimeInDaysHoursMins(seconds) {
        var time = new Date("", "", "", "", "", seconds)
        return (time.getDate() != 31 ? time.getDate() + "D " + time.getHours() + "HR " + time.getMinutes() + "M" :
                                       time.getHours() != 0 ? time.getHours() + "HR " + time.getMinutes() + "M" :
                                                              time.getMinutes() + "M")
    }

    function getPrintFileDetails(file) {
        var printTimeSec = file.timeEstimateSec
        fileName = file.filePath + "/" + file.fileName
        file_name = inFreStep ? qsTr("TEST PRINT") : (isInManualCalibration ? qsTr("Z-Calibration Print") : file.fileBaseName)
        model_extruder_used = file.extruderUsedA
        support_extruder_used = file.extruderUsedB
        print_model_material = file.materialA
        print_support_material = file.materialB
        uses_support = file.usesSupport ? qsTr("YES") : qsTr("NO")
        uses_raft = file.usesRaft ? qsTr("YES") : qsTr("NO")
        model_mass = file.extrusionMassGramsA < 1000 ? file.extrusionMassGramsA.toFixed(1) + " g" :
                                                       (file.extrusionMassGramsA * 0.001).toFixed(1) + " Kg"
        support_mass = file.extrusionMassGramsB < 1000 ? file.extrusionMassGramsB.toFixed(1) + " g" :
                                                         (file.extrusionMassGramsB * 0.001).toFixed(1) + " Kg"
        modelMaterialRequired = (file.extrusionMassGramsA/1000).toFixed(3)
        supportMaterialRequired = (file.extrusionMassGramsB/1000).toFixed(3)
        layer_height_mm = file.layerHeightMM.toFixed(2)
        num_shells = file.numShells
        extruder_temp = !file.extruderUsedB ? file.extruderTempCelciusA + " °C" :
                                              file.extruderTempCelciusA + " °C" + " | " + file.extruderTempCelciusB + " °C"
        buildplane_temp = file.buildplaneTempCelcius + " °C"
        buildplatform_temp = file.buildplatformTempCelcius + " °C"
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
                            meta['extruder_temperatures'][0] + " °C" :
                            meta['extruder_temperatures'][0] + " °C" + " | " + meta['extruder_temperatures'][1] + " °C"
        if("build_plane_temperature" in meta) {
            meta["buildplane_target_temperature"] = meta["build_plane_temperature"]
            delete meta["build_plane_temperature"]
        } else {
            // Backwards compatibility, in case the user somehow lost
            // the .stl, and only has older .makerbot files on hand.
            meta["buildplane_target_temperature"] =
                    (meta["chamber_temperature"] > 40) ?
                        Math.round((meta["chamber_temperature"] * 1.333) - 13) :
                        meta["chamber_temperature"]
        }
        buildplane_temp = Math.round(meta['buildplane_target_temperature']) + " °C"
        if("platform_temperature" in meta) {
            buildplatform_temp = meta['platform_temperature'] + " °C"
        }
        getPrintTimes(printTimeSec)
        printQueuePopup.close()
        startPrintSource = PrintPage.FromPrintQueue
        printSwipeView.swipeToItem(PrintPage.StartPrintConfirm)
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
        var doneByDayString = daysLeft > 1 ? daysLeft + qsTr(" DAYS LATER") : daysLeft == 1 ? qsTr("TOMORROW") : qsTr("TODAY")
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
        StartPrintConfirm
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
        FromPrintQueue,
        FromPrintAgain
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

    LoggingStackLayout {
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
            property string topBarTitle: bot.process.type == ProcessType.Print ?
                                             qsTr("PRINT") :
                                             qsTr("Select Source")

            property int backSwipeIndex: 0
            smooth: false

            FlickableMenu {
                id: flickableStorageOpt
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
                        id: buttonPrintAgain
                        storageImage: "qrc:/img/print_again.png"
                        storageName: qsTr("PRINT AGAIN")
                        storageDescription: ""
                        onClicked: {
                            printPage.startPrintSource = PrintPage.FromPrintAgain
                            updateLastThing()
                            printPage.printSwipeView.swipeToItem(PrintPage.StartPrintConfirm)
                        }
                        visible: bot.printAgainEnabled
                        enabled: storage.doesPrintAgainFileExist
                    }

                    StorageTypeButton {
                        id: buttonQueuedPrints
                        storageImage: "qrc:/img/directory.png"
                        storageName: qsTr("QUEUE")
                        storageDescription: qsTr("FROM CLOUDPRINT")
                        onClicked: {
                            printSwipeView.swipeToItem(PrintPage.PrintQueueBrowser)
                        }
                    }

                    StorageTypeButton {
                        id: buttonUsbStorage
                        storageImage: "qrc:/img/usb.png"
                        storageName: qsTr("USB")
                        storageDescription: usbStorageConnected ? qsTr("EXTERNAL STORAGE") : qsTr("PLEASE INSERT A USB DRIVE")
                        enabled: usbStorageConnected
                        onClicked: {
                            if(usbStorageConnected) {
                                browsingUsbStorage = true
                                storage.setStorageFileType(StorageFileType.Print)
                                storage.updatePrintFileList("?root_usb?")
                                setActiveDrawer(printPage.sortingDrawer)
                                printSwipeView.swipeToItem(PrintPage.FileBrowser)
                            }
                        }
                    }

                    StorageTypeButton {
                        id: buttonInternalStorage
                        storageImage: "qrc:/img/internal_storage.png"
                        storageName: qsTr("INTERNAL STORAGE")
                        storageDescription: qsTr("FILES SAVED ON PRINTER")
                        storageUsed: Math.min(diskman.internalUsed.toFixed(1), 100)
                        onClicked: {
                            browsingUsbStorage = false
                            storage.setStorageFileType(StorageFileType.Print)
                            storage.updatePrintFileList("?root_internal?")
                            setActiveDrawer(printPage.sortingDrawer)
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
            property string topBarTitle: browsingUsbStorage ?
                                       qsTr("USB - Select File") :
                                       qsTr("Internal Storage - Select File")

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
                    setActiveDrawer(null)
                    printSwipeView.swipeToItem(PrintPage.BasePage)
                }
            }

            TextSubheader {
                id: noFilesText
                style: TextSubheader.Bold
                text: qsTr("NO PRINTABLE FILES")
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -40
                anchors.horizontalCenter: parent.horizontalCenter
                visible: storage.storageIsEmpty
                width: parent.width

                TextBody {
                    style: TextBody.Large
                    font.weight: Font.Light
                    text: qsTr("Choose another folder or export a .MakerBot file from the MakerBot Print app.")
                    anchors.top: parent.bottom
                    anchors.topMargin: 15
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
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
                            startPrintSource = PrintPage.FromLocal
                            setActiveDrawer(null)
                            startPrintInstructionsItem.acknowledged = false
                            printSwipeView.swipeToItem(PrintPage.StartPrintConfirm)

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
            property string topBarTitle: qsTr("Cloud Queue - Select File")
            smooth: false
            visible: false

            TextSubheader {
                id: noPrintsInQueueText
                font.weight: Font.Bold
                text: qsTr("NO PRINT JOBS IN QUEUE")
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -40
                anchors.horizontalCenter: parent.horizontalCenter
                visible: bot.net.printQueueEmpty

                TextBody {
                    style: TextBody.Large
                    font.weight: Font.Light
                    text: qsTr("Use MakerBot CloudPrint to add to your printer's queue.")
                    anchors.top: parent.bottom
                    anchors.topMargin: 15
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
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

                    onPressAndHold: {
                        file_name = model.modelData.fileName
                        print_job_id = model.modelData.jobId
                        print_token = model.modelData.token
                        print_url_prefix = model.modelData.urlPrefix
                        queueOptionsMenu.popup(queuedPrintFilebutton.x + 700,
                            queuedPrintFilebutton.y - printQueueList.contentY + 25)
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

                CloudQueueOptionsPopupMenu {
                    id: queueOptionsMenu
                }
            }
        }

        // PrintPage.StartPrintConfirm
        Item {
            id: itemStartPrint
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: printSwipeView
            property int backSwipeIndex: {
                if(isPrintProcess) {
                    PrintPage.BasePage
                } else {
                    switch(startPrintSource) {
                    case PrintPage.FromPrintAgain:
                        PrintPage.BasePage
                        break;
                    case PrintPage.FromPrintQueue:
                        PrintPage.PrintQueueBrowser
                        break;
                    case PrintPage.FromLocal:
                        PrintPage.FileBrowser
                        break;
                    default:
                        PrintPage.BasePage
                        break;
                    }
                }
            }
            property string topBarTitle: qsTr("Start Print")
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(isInManualCalibration) {
                    // Due to special calibration printing manual
                    // calibration is required on the print page.
                    // We don't want the user to be able to do normal back out
                    // Return to Manual Calibration process where we left off...
                    startPrintItem.startPrintSwipeView.setCurrentIndex(StartPrintPage.BasePage)
                    printSwipeView.swipeToItem(PrintPage.BasePage)
                    mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                    settingsPage.settingsSwipeView.swipeToItem(SettingsPage.ExtruderSettingsPage)
                    settingsPage.extruderSettingsPage.extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.CalibrationProceduresPage)
                    settingsPage.extruderSettingsPage.calibrationProcedures.calibrationProceduresSwipeView.swipeToItem(CalibrationProceduresPage.ManualZCalibrationPage)
                }
                else if(!inFreStep) {
                    startPrintItem.startPrintSwipeView.setCurrentIndex(StartPrintPage.BasePage)
                    if(startPrintSource == PrintPage.FromLocal) {
                        setActiveDrawer(printPage.sortingDrawer)
                    }
                    resetPrintFileDetails()
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
                setActiveDrawer(null)
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
    }

    CustomPopup {
        popupName: "CopyFileToInternalStorage"
        id: copyingFilePopup
        popupHeight: columnLayout_copy_file_popup.height+145
        onClosed: {
            internalStorageFull = false
        }

        showTwoButtons: internalStorageFull
        leftButtonText: qsTr("BACK")
        leftButton.onClicked: {
            copyingFilePopup.close()
        }

        rightButtonText: qsTr("VIEW FILES")
        rightButton.onClicked: {
            browsingUsbStorage = false
            storage.setStorageFileType(StorageFileType.Print)
            storage.updatePrintFileList("?root_internal?")
            setActiveDrawer(printPage.sortingDrawer)
            printSwipeView.swipeToItem(PrintPage.FileBrowser)
            copyingFilePopup.close()
        }

        showOneButton: !internalStorageFull
        fullButtonText: (isFileCopySuccessful || fileDownloadFailed)? qsTr("CLOSE") : qsTr("CANCEL")
        fullButton.onClicked: {
            storage.cancelCopy()
            print_queue.cancelDownload()
            copyingFilePopup.close()
        }

        ColumnLayout {
            id: columnLayout_copy_file_popup
            width: 650
            height: children.height
            anchors.top: copyingFilePopup.popupContainer.top
            anchors.topMargin: 35
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Image {
                id: error_image
                width: sourceSize.width - 10
                height: sourceSize.height -10
                Layout.alignment: Qt.AlignHCenter
                source: "qrc:/img/process_complete_small.png"
            }

            BusySpinner {
                id: busy_spinner_img
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                spinnerSize: 64
            }

            TextHeadline {
                id: alert_text_copy_file_popup
                Layout.alignment: Qt.AlignHCenter
                font.weight: Font.Bold
            }

            TextBody {
                id: description_text_copy_file_popup
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: 600
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                width: parent.width
            }

            states: [
                State {
                    name: "file_added"
                    when: isFileCopySuccessful

                    PropertyChanges {
                        target: error_image
                        source: "qrc:/img/process_complete_small.png"
                        visible: true
                    }

                    PropertyChanges {
                        target: busy_spinner_img
                        visible: false
                    }

                    PropertyChanges {
                        target: alert_text_copy_file_popup
                        text: qsTr("FILE ADDED")
                    }

                    PropertyChanges {
                        target: description_text_copy_file_popup
                        text: qsTr("The following file has been added to internal storage:") +
                                  ("<br><br><br><b>%1</b>").arg(file_name)
                    }
                },
                State {
                    name: "copying"
                    when: isFileCopying

                    PropertyChanges {
                        target: error_image
                        visible: false
                    }

                    PropertyChanges {
                        target: busy_spinner_img
                        visible: true
                    }

                    PropertyChanges {
                        target: alert_text_copy_file_popup
                        text: qsTr("COPYING")
                    }

                    PropertyChanges {
                        target: description_text_copy_file_popup
                        text: ("%1").arg(storage.fileCopyProgress*100) + "%"
                    }
                },
                State {
                    name: "downloading"
                    when: isFileDownloading

                    PropertyChanges {
                        target: error_image
                        visible: false
                    }

                    PropertyChanges {
                        target: busy_spinner_img
                        visible: true
                    }

                    PropertyChanges {
                        target: alert_text_copy_file_popup
                        text: qsTr("DOWNLOADING")
                    }

                    PropertyChanges {
                        target: description_text_copy_file_popup
                        text: print_queue.downloadTotalBytes > 0 ?
                            (print_queue.downloadProgressBytes*100/print_queue.downloadTotalBytes).toFixed(1) + "%" :
                            qsTr("%1 bytes").arg(print_queue.downloadProgressBytes)
                    }
                },
                State {
                    name: "download_failed"
                    when: fileDownloadFailed

                    PropertyChanges {
                        target: error_image
                        source: "qrc:/img/process_error_small.png"
                        visible: true
                    }

                    PropertyChanges {
                        target: busy_spinner_img
                        visible: false
                    }

                    PropertyChanges {
                        target: alert_text_copy_file_popup
                        text: qsTr("DOWNLOAD FAILED")
                    }

                    PropertyChanges {
                        target: description_text_copy_file_popup
                        text: qsTr("Failed to download file -- please check network connectivity")
                    }
                },
                State {
                    name: "storage_full"
                    when: internalStorageFull

                    PropertyChanges {
                        target: error_image
                        source: "qrc:/img/process_error_small.png"
                        visible: true
                    }

                    PropertyChanges {
                        target: busy_spinner_img
                        visible: false
                    }

                    PropertyChanges {
                        target: alert_text_copy_file_popup
                        text: qsTr("PRINTER STORAGE IS FULL")
                    }

                    PropertyChanges {
                        target: description_text_copy_file_popup
                        text: qsTr("Remove unwanted files from the printer's internal storage to free up space.")
                    }
                }

            ]
        }
    }

    CustomPopup {
        id: startPrintPopup
        popupName: "StartPrintPopup"
        popupHeight: startPrintPopup_column_layout.height+145
        showTwoButtons: true
        leftButtonText: qsTr("BACK")
        leftButton.onClicked: {
            // don't start print
            startPrintPopup.close()
        }
        rightButtonText: qsTr("CONFIRM")
        rightButton.onClicked: {
            // start print
            startPrintPopup.close()
            if(startPrintSource == PrintPage.FromPrintQueue) {
                print_queue.startQueuedPrint(print_url_prefix,
                                             print_job_id,
                                             print_token)
                printFromQueueState = PrintPage.WaitingToStartPrint
            } else if(startPrintSource == PrintPage.FromPrintAgain) {
                startPrint(printAgain=true)
            } else {
                startPrint()
            }
        }

        Column {
            id: startPrintPopup_column_layout
            width: parent.popupWidth
            height: children.height
            anchors.top: startPrintPopup.popupContainer.top
            anchors.topMargin: 35
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Image {
                id: build_plate_error_image
                width: sourceSize.width - 10
                height: sourceSize.height -10
                Layout.alignment: Qt.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                source: "qrc:/img/process_error_small.png"
                visible: !inFreStep
            }

            TextHeadline {
                id: title
                text: qsTr("CONFIRM BUILD PLATE IS CLEAR")
                Layout.alignment: Qt.AlignHCenter
                width: startPrintPopup.popupWidth
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    CustomPopup {
        popupName: "NylonCFPrintTip"
        id: nylonCFPrintTipPopup
        popupWidth: 720
        popupHeight: 275
        showTwoButtons: true
        leftButtonText: qsTr("DON'T REMIND ME AGAIN")
        leftButton.onClicked: {
            settings.setShowNylonCFAnnealPrintTip(false)
            nylonCFPrintTipPopup.close()
        }
        rightButtonText: qsTr("OK")
        rightButton.onClicked: {
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
        popupHeight: {
            if(printFromQueueState == PrintPage.WaitingToStartPrint) {
                columnLayout_print_queue_popup.height+ 80
            } else {
                columnLayout_print_queue_popup.height+145
            }
        }
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
        fullButtonText: {
            if(printFromQueueState == PrintPage.FetchingPrintDetails) {
                qsTr("CANCEL")
            } else if(printFromQueueState == PrintPage.FailedToStartPrint ||
                      printFromQueueState == PrintPage.FailedToGetPrintDetails) {
                qsTr("CLOSE")
            } else {
                defaultString
            }
        }
        fullButton.onClicked: {
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
            anchors.top: printQueuePopup.popupContainer.top
            anchors.topMargin: 35
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Image {
                id: error_image_print_queue
                width: sourceSize.width - 10
                height: sourceSize.height -10
                Layout.alignment: Qt.AlignHCenter
                source: "qrc:/img/process_error_small.png"
            }

            BusySpinner {
                id: waitingSpinner
                spinnerActive: true
                spinnerSize: 64
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            TextHeadline {
                id: alert_text_print_queue_popup
                Layout.alignment: Qt.AlignHCenter
                font.weight: Font.Bold
            }

            states: [
                State {
                    name: "fetching_print_details"
                    when: printFromQueueState == PrintPage.FetchingPrintDetails

                    PropertyChanges {
                        target: alert_text_print_queue_popup
                        text: qsTr("LOADING PRINT DETAILS")
                    }

                    PropertyChanges {
                        target: error_image_print_queue
                        visible: false
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        visible: true
                    }
                },
                State {
                    name: "failed_to_get_print_details"
                    when: printFromQueueState == PrintPage.FailedToGetPrintDetails

                    PropertyChanges {
                        target: alert_text_print_queue_popup
                        text: qsTr("Failed to get print details")
                    }

                    PropertyChanges {
                        target: error_image_print_queue
                        visible: true
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        visible: false
                    }
                },
                State {
                    name: "waiting_to_start_print"
                    when: printFromQueueState == PrintPage.WaitingToStartPrint

                    PropertyChanges {
                        target: alert_text_print_queue_popup
                        text: qsTr("Your print will start momentarily...")
                    }

                    PropertyChanges {
                        target: error_image_print_queue
                        visible: false
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        visible: true
                    }
                },
                State {
                    name: "failed_to_start_print"
                    when: printFromQueueState == PrintPage.FailedToStartPrint

                    PropertyChanges {
                        target: alert_text_print_queue_popup
                        text: qsTr("Failed to start the print")
                    }

                    PropertyChanges {
                        target: error_image_print_queue
                        visible: true
                    }

                    PropertyChanges {
                        target: waitingSpinner
                        visible: false
                    }
                }
            ]
        }
    }

    CustomPopup {
        popupName: "PrintFeedbackAcknowledgement"
        id: printFeedbackAcknowledgementPopup
        popupWidth: 715
        popupHeight: 336
        showOneButton: true
        fullButtonText: qsTr("OK")
        fullButton.onClicked: {
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

            Image{
                id: blue_check
                source: "qrc:/img/popup_complete.png"
                Layout.alignment: Qt.AlignHCenter
            }

            TextHeadline {
                id: alert_text_printFeedbackAcknowledgementPopup
                text: qsTr("FEEDBACK SUBMITTED")
                Layout.alignment: Qt.AlignHCenter
            }

            TextBody {
                id: description_text_printFeedbackAcknowledgementPopup
                text: {
                    if(printFeedbackAcknowledgementPopup.feedbackGood) {
                        qsTr("Thank you for your feedback. If you encounter issues, visit:")
                    } else {
                        qsTr("Thank you for your feedback. If you encounter ongoing issues, visit:")
                    }
                }
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                width: parent.width
            }

            TextBody {
                id: support_link
                text: "support.makerbot.com"
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                font.weight: Font.DemiBold
                width: parent.width
            }
        }
    }
}
