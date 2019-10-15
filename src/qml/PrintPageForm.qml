import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import StorageFileTypeEnum 1.0
import ErrorTypeEnum 1.0
import FreStepEnum 1.0

Item {
    smooth: false
    property string fileName: "unknown.makerbot"
    property string file_name
    property string print_time
    property string print_material
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
    property string chamber_temp
    property string slicer_name
    property string readyByTime
    property int lastPrintTimeSec
    property alias printingDrawer: printingDrawer
    property alias sortingDrawer: sortingDrawer
    property alias buttonCancelPrint: printingDrawer.buttonCancelPrint
    property alias buttonPausePrint: printingDrawer.buttonPausePrint
    property alias defaultItem: itemPrintStorageOpt
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

    onIsFileCopyingChanged: {
        if(isFileCopying &&
           mainSwipeView.currentIndex == 1) {
            copyingFilePopup.open()
        }
    }

    property bool isFileCopySuccessful: storage.fileCopySucceeded
    property bool internalStorageFull: false

    property bool usbStorageConnected: storage.usbStorageConnected
    onUsbStorageConnectedChanged: {
        if(!storage.usbStorageConnected) {
            if(printSwipeView.currentIndex != 0 &&
                    browsingUsbStorage) {
                setDrawerState(false)
                printSwipeView.swipeToItem(0)
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
            if(printSwipeView.currentIndex != 0) {
                printSwipeView.swipeToItem(0)
            }
            setDrawerState(false)
            activeDrawer = printPage.printingDrawer
            setDrawerState(true)
            if(!printFromUI) {
                getPrintDetailsTimer.start() //for prints started from repl
            }
            printFromUI = false //reset when the print actually starts
        }
        else {
            printStatusView.printStatusSwipeView.setCurrentIndex(0)
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
            storage.updateCurrentThing()
            getPrintFileDetails(storage.currentThing)
        }
    }

    Timer {
        id: getPrintDetailsTimer
        interval: 3000
        onTriggered: {
            storage.updateCurrentThing()
            getPrintFileDetails(storage.currentThing)
            this.stop()
        }
    }

    property bool isPrintFinished: bot.process.stateType == ProcessStateType.Completed ||
                                   bot.process.stateType == ProcessStateType.Failed

    onIsPrintFinishedChanged: {
        if(isPrintFinished) {
            var timeElapsed = new Date("", "", "", "", "", bot.process.elapsedTime)
            print_time = timeElapsed.getDate() != 31 ? timeElapsed.getDate() + "D " + timeElapsed.getHours() + "HR " + timeElapsed.getMinutes() + "M" :
                                                       timeElapsed.getHours() != 0 ? timeElapsed.getHours() + "HR " + timeElapsed.getMinutes() + "M" :
                                                                                     timeElapsed.getMinutes() + "M"
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
        if(isPrintDone && bot.chamberCurrentTemp > waitToCoolTemperature) {
            waitToCoolChamber.waitToCoolChamberScreenVisible = true
            waitToCoolChamber.startTimer()
        }
    }

    function getPrintFileDetails(file) {
        var printTimeSec = file.timeEstimateSec
        fileName = file.filePath + "/" + file.fileName
        file_name = file.fileBaseName
        model_extruder_used = file.extruderUsedA
        support_extruder_used = file.extruderUsedB
        print_model_material = file.materialNameA
        print_support_material = file.materialNameB
        print_material = !file.extruderUsedB ? file.materialNameA :
                                               file.materialNameA + "+" + file.materialNameB
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
        chamber_temp = file.chamberTempCelcius + "C"
        slicer_name = file.slicerName
        getPrintTimes(printTimeSec)
    }

    function resetPrintFileDetails() {
        fileName = ""
        file_name = ""
        print_time = ""
        model_extruder_used = false
        support_extruder_used = false
        print_material = ""
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
        chamber_temp = ""
        slicer_name = ""
        startPrintWithUnknownMaterials = false
    }

    // Compute print time, print end time & get them in string format for UI.
    // Called when selecting a file for print & also while clicking print again
    // at the end of a print to get new end time.
    function getPrintTimes(printTimeSec) {
        lastPrintTimeSec = printTimeSec
        var timeLeft = new Date("", "", "", "", "", printTimeSec)
        print_time = timeLeft.getDate() != 31 ? timeLeft.getDate() + "D " + timeLeft.getHours() + "HR " + timeLeft.getMinutes() + "M" :
                                                timeLeft.getHours() != 0 ? timeLeft.getHours() + "HR " + timeLeft.getMinutes() + "M" :
                                                                           timeLeft.getMinutes() + "M"
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

    SwipeView {
        id: printSwipeView
        smooth: false
        currentIndex: 0 // Should never be non zero
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = printSwipeView.currentIndex
            printSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            setCurrentItem(printSwipeView.itemAt(itemToDisplayDefaultIndex))
            printSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            printSwipeView.itemAt(prevIndex).visible = false
        }

        // printSwipeView.index = 0
        Item {
            id: itemPrintStorageOpt
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: mainSwipeView
            property int backSwipeIndex: 0
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    mainSwipeView.swipeToItem(0)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                printStatusView.testPrintComplete = false
                bot.cancel()
                mainSwipeView.swipeToItem(0)
            }

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
                        id: buttonInternalStorage
                        storageThumbnail.source: "qrc:/img/sombrero_icon.png"
                        storageThumbnail.width: 70
                        storageThumbnail.height: 53
                        storageThumbnail.anchors.leftMargin: 60
                        storageName: qsTr("INTERNAL STORAGE")
                        storageDescription: qsTr("FILES SAVED ON PRINTER")
                        storageUsed: Math.min(diskman.internalUsed.toFixed(1), 100)
                        onClicked: {
                            browsingUsbStorage = false
                            storage.setStorageFileType(StorageFileType.Print)
                            storage.updatePrintFileList("?root_internal?")
                            activeDrawer = printPage.sortingDrawer
                            setDrawerState(true)
                            printSwipeView.swipeToItem(1)
                        }
                    }

                    StorageTypeButton {
                        id: buttonUsbStorage
                        storageThumbnail.source: "qrc:/img/usb_icon.png"
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
                                printSwipeView.swipeToItem(1)
                            }
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
                print_model_material_: print_model_material
                print_support_material_: print_support_material
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

        // printSwipeView.index = 1
        Item {
            id: itemPrintStorage
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: printSwipeView
            property int backSwipeIndex: 0
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
                    printSwipeView.swipeToItem(0)
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
                            model.modelData.materialNameA + "+" + model.modelData.materialNameB
                        } else if (model.modelData.extruderUsedA && !model.modelData.extruderUsedB) {
                            model.modelData.materialNameA
                        }
                    }
                    materialError.visible: {
                        if (model.modelData.extruderUsedA && model.modelData.extruderUsedB) {
                            materialPage.bay1.usingExperimentalExtruder ?
                                (model.modelData.materialNameB != materialPage.bay2.filamentMaterialName.toLowerCase()) :
                                (model.modelData.materialNameA != materialPage.bay1.filamentMaterialName.toLowerCase() ||
                                 model.modelData.materialNameB != materialPage.bay2.filamentMaterialName.toLowerCase())
                        } else if (model.modelData.extruderUsedA && !model.modelData.extruderUsedB) {
                            materialPage.bay1.usingExperimentalExtruder ?
                                    false :
                                    model.modelData.materialNameA != materialPage.bay1.filamentMaterialName.toLowerCase()
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
                                setDrawerState(false)
                                printSwipeView.swipeToItem(2)
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

        // printSwipeView.index = 2
        Item {
            id: itemPrintFileOpt
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: printSwipeView
            property int backSwipeIndex: isPrintProcess ? 0 : 1
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    startPrintItem.startPrintSwipeView.setCurrentIndex(0)
                    resetPrintFileDetails()
                    setDrawerState(true)
                    currentItem.backSwiper.swipeToItem(currentItem.backSwipeIndex)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                startPrintItem.startPrintSwipeView.setCurrentIndex(0)
                resetPrintFileDetails()
                setDrawerState(false)
                printSwipeView.swipeToItem(0)
                mainSwipeView.swipeToItem(0)
            }

            StartPrintPage {
                id: startPrintItem
            }
        }

        // printSwipeView.index = 3
        Item {
            id: itemPrintInfoOpt
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: printSwipeView
            property int backSwipeIndex: isPrintProcess ? 0 : 2
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
                    id: printInfo_chamberTemperature
                    labelText: qsTr("Chamber Temperature")
                    dataText: chamber_temp
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
            if(printSwipeView.currentIndex != 1) {
                printSwipeView.swipeToItem(1)
            }
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
}
