import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    smooth: false
    property string fileName: "unknown.makerbot"
    property string file_name
    property string print_time
    property string print_material
    property string uses_support
    property string uses_raft
    property string model_mass
    property string support_mass
    property int num_shells
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

    property bool usbStorageConnected: storage.usbStorageConnected
    onUsbStorageConnectedChanged: {
        if(!storage.usbStorageConnected &&
           printSwipeView.currentIndex != 0 &&
           browsingUsbStorage) {
            setDrawerState(false)
            printSwipeView.swipeToItem(0)
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

    function getPrintFileDetails(file) {
        var printTimeSec = file.timeEstimateSec
        fileName = file.filePath + "/" + file.fileName
        file_name = file.fileBaseName
        print_material = file.materialNameA == "" ? file.materialNameB :
                                                    file.materialNameA + "+" + file.materialNameB
        uses_support = file.usesSupport ? "YES" : "NO"
        uses_raft = file.usesRaft ? "YES" : "NO"
        model_mass = file.extrusionMassGramsB < 1000 ? file.extrusionMassGramsB.toFixed(1) + " g" :
                                                       (file.extrusionMassGramsB * 0.001).toFixed(1) + " Kg"
        support_mass = file.extrusionMassGramsA < 1000 ? file.extrusionMassGramsA.toFixed(1) + " g" :
                                                         (file.extrusionMassGramsA * 0.001).toFixed(1) + " Kg"
        num_shells = file.numShells
        extruder_temp = file.extruderTempCelciusA == 0 ? file.extruderTempCelciusB + "C" :
                                                         file.extruderTempCelciusA + "C" + " + " + file.extruderTempCelciusB + "C"
        chamber_temp = file.chamberTempCelcius + "C"
        slicer_name = file.slicerName
        getPrintTimes(printTimeSec)
    }

    function resetPrintFileDetails() {
        fileName = ""
        file_name = ""
        print_time = ""
        print_material = ""
        uses_support = ""
        uses_raft = ""
        model_mass = ""
        support_mass = ""
        num_shells = ""
        extruder_temp = ""
        chamber_temp = ""
        slicer_name = ""
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
            smooth: false
            visible: false

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

                    FileButton {
                        id: buttonInternalStorage
                        fileThumbnail.source: "qrc:/img/sombrero_icon.png"
                        fileThumbnail.width: 96
                        fileThumbnail.height: 120
                        filenameText.text: "INTERNAL STORAGE"
                        filePrintTime.text: "FILES SAVED ON PRINTER"
                        fileMaterial.visible: false
                        onClicked: {
                            browsingUsbStorage = false
                            storage.updateStorageFileList("?root_internal?")
                            activeDrawer = printPage.sortingDrawer
                            setDrawerState(true)
                            printSwipeView.swipeToItem(1)
                        }
                    }

                    Item { width: parent.width; height: 1; smooth: false
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent
                        }
                    }

                    FileButton {
                        id: buttonUsbStorage
                        fileThumbnail.source: "qrc:/img/usb_icon.png"
                        fileThumbnail.opacity: usbStorageConnected ? 1 : 0.4
                        fileThumbnail.width: 96
                        fileThumbnail.height: 120
                        filenameText.text: "USB"
                        filenameText.opacity: usbStorageConnected ? 1 : 0.4
                        filePrintTime.text: usbStorageConnected ? "EXTERNAL STORAGE" : "PLEASE INSERT A USB DRIVE"
                        filePrintTime.opacity: usbStorageConnected ? 1 : 0.4
                        fileMaterial.visible: false
                        onClicked: {
                            if(usbStorageConnected) {
                                browsingUsbStorage = true
                                storage.updateStorageFileList("?root_usb?")
                                activeDrawer = printPage.sortingDrawer
                                setDrawerState(true)
                                printSwipeView.swipeToItem(1)
                            }
                        }
                    }
                    Item { width: parent.width; height: 1; smooth: false
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent
                        }
                    }
                }
            }

            PrintStatusViewForm{
                id: printStatusView
                smooth: false
                visible: isPrintProcess
                fileName_: file_name
                filePathName: fileName
                support_mass_: support_mass
                model_mass_: model_mass
                uses_support_: uses_support
                uses_raft_: uses_raft
                print_time_: print_time
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
                var backDir = storage.backStackPop()
                if(backDir !== "") {
                    storage.updateStorageFileList(backDir)
                }
                else {
                    setDrawerState(false)
                    printSwipeView.swipeToItem(0)
                }
            }

            Text {
                color: "#ffffff"
                font.family: "Antennae"
                font.weight: Font.Light
                text: "No Items"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 20
                visible: storage.storageIsEmpty
            }

            ListView {
                smooth: false
                anchors.fill: parent
                boundsBehavior: Flickable.DragOverBounds
                spacing: 1
                orientation: ListView.Vertical
                flickableDirection: Flickable.VerticalFlick
                visible: !storage.storageIsEmpty
                model: storage.printFileList
                delegate:
                    FileButton {
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
                    fileMaterial.text: model.modelData.materialNameA == "" ?
                                           model.modelData.materialNameB :
                                           model.modelData.materialNameA + "+" + model.modelData.materialNameB
                    onClicked: {
                        if(model.modelData.isDir) {
                            storage.backStackPush(model.modelData.filePath)
                            storage.updateStorageFileList(model.modelData.filePath + "/" + model.modelData.fileName)
                        }
                        else if(model.modelData.fileBaseName !== "No Items Present") { // Ignore default fileBaseName object
                            getPrintFileDetails(model.modelData)
                            setDrawerState(false)
                            printSwipeView.swipeToItem(2)
                        }
                    }

                    Item { width: parent.width; height: 1; smooth: false
                        Rectangle { color: "#4d4d4d"; smooth: false; anchors.fill: parent } }
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
                resetPrintFileDetails()
                setDrawerState(true)
                currentItem.backSwiper.swipeToItem(currentItem.backSwipeIndex)
            }

            Item {
                id: startPrintItem
                anchors.fill: parent

                Item {
                    id: modelItem
                    width: 212
                    height: 300
                    smooth: false
                    anchors.left: parent.left
                    anchors.leftMargin: 100
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: back_image
                        smooth: false
                        anchors.fill: parent
                        source: "qrc:/img/back_build_volume.png"
                    }

                    Image {
                        id: model_image
                        smooth: false
                        width: 320
                        height: 200
                        anchors.verticalCenterOffset: 50
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        source: "image://thumbnail/" + fileName
                    }

                    Image {
                        id: front_image
                        smooth: false
                        anchors.fill: parent
                        source: "qrc:/img/front_build_volume.png"
                    }
                }

                ColumnLayout {
                    id: columnLayout
                    width: 400
                    height: 225
                    antialiasing: false
                    smooth: false
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 400
                    spacing: 10

                    Image {
                        id: infoIcon
                        width: sourceSize.width
                        height: sourceSize.height
                        antialiasing: false
                        smooth: false
                        source: "qrc:/img/info_icon_small.png"

                        MouseArea {
                            width: 80
                            height: 80
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: printSwipeView.swipeToItem(3)
                        }
                    }

                    Item {
                        id: spacingItem
                        width: 100
                        height: 5
                        antialiasing: false
                        smooth: false
                    }

                    Text {
                        id: printName
                        text: file_name
                        smooth: false
                        antialiasing: false
                        font.letterSpacing: 3
                        font.family: "Antennae"
                        font.weight: Font.Bold
                        font.pixelSize: 21
                        color: "#cbcbcb"
                    }

                    RowLayout {
                        id: printTimeRowLayout
                        antialiasing: false
                        smooth: false
                        spacing: 10

                        Text {
                            id: printTimeLabel
                            text: "PRINT TIME"
                            smooth: false
                            antialiasing: false
                            font.letterSpacing: 3
                            font.family: "Antennae"
                            font.weight: Font.Light
                            font.pixelSize: 18
                            color: "#ffffff"
                        }

                        Rectangle {
                            id: dividerRectangle
                            width: 1
                            height: 18
                            color: "#ffffff"
                            antialiasing: false
                            smooth: false
                        }

                        Text {
                            id: printTime
                            text: print_time
                            smooth: false
                            antialiasing: false
                            font.letterSpacing: 3
                            font.family: "Antennae"
                            font.weight: Font.Light
                            font.pixelSize: 18
                            color: "#ffffff"
                        }
                    }

                    Text {
                        id: readyByLabel
                        text: "READY BY : " + readyByTime
                        smooth: false
                        antialiasing: false
                        font.letterSpacing: 3
                        font.family: "Antennae"
                        font.weight: Font.Light
                        font.pixelSize: 18
                        color: "#ffffff"
                    }

                    RowLayout {
                        id: materialRowLayout
                        antialiasing: false
                        smooth: false
                        spacing: 10

                        Text {
                            id: materialLabel
                            text: "MATERIAL"
                            smooth: false
                            antialiasing: false
                            font.letterSpacing: 3
                            font.family: "Antennae"
                            font.weight: Font.Light
                            font.pixelSize: 18
                            color: "#ffffff"
                        }

                        Rectangle {
                            id: dividerRectangle1
                            width: 1
                            height: 18
                            color: "#ffffff"
                            antialiasing: false
                            smooth: false
                        }

                        Image {
                            id: lowMaterialAlert
                            height: 12
                            width: 12
                            antialiasing: false
                            smooth: false
                            source: "qrc:/img/alert.png"
                        }
                    }

                    Item {
                        id: spacingItem1
                        width: 200
                        height: 3
                        smooth: false
                        antialiasing: false
                    }

                    RoundedButton {
                        buttonWidth: 210
                        buttonHeight: 50
                        label: "START PRINT"
                        button_mouseArea.onClicked: {
                            storage.backStackClear()
                            activeDrawer = printPage.printingDrawer
                            bot.print(fileName)
                            printFromUI = true
                            printSwipeView.swipeToItem(0)
                        }
                    }
                }
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
                height: 350
                anchors.left: parent.left
                anchors.leftMargin: 65
                anchors.top: parent.top
                anchors.topMargin: 50
                smooth: false

                InfoItem {
                    id: printInfo_fileName
                    labelText: qsTr("Filename") + cpUiTr.emptyStr
                    dataText: file_name
                }

                InfoItem {
                    id: printInfo_timeEstimate
                    labelText: qsTr("Print Time Estimate") + cpUiTr.emptyStr
                    dataText: print_time
                }

                InfoItem {
                    id: printInfo_material
                    labelText: qsTr("Print Material") + cpUiTr.emptyStr
                    dataText: print_material
                }

                InfoItem {
                    id: printInfo_usesSupport
                    labelText: qsTr("Supports") + cpUiTr.emptyStr
                    dataText: uses_support
                }

                InfoItem {
                    id: printInfo_usesRaft
                    labelText: qsTr("Rafts") + cpUiTr.emptyStr
                    dataText: uses_raft
                }

                InfoItem {
                    id: printInfo_modelMass
                    labelText: qsTr("Model") + cpUiTr.emptyStr
                    dataText: model_mass
                }

                InfoItem {
                    id: printInfo_supportMass
                    labelText: qsTr("Support") + cpUiTr.emptyStr
                    dataText: support_mass
                }

                InfoItem {
                    id: printInfo_Shells
                    labelText: qsTr("Shells") + cpUiTr.emptyStr
                    dataText: num_shells
                }

                InfoItem {
                    id: printInfo_extruderTemperature
                    labelText: qsTr("Extruder Temperature") + cpUiTr.emptyStr
                    dataText: extruder_temp
                }

                InfoItem {
                    id: printInfo_chamberTemperature
                    labelText: qsTr("Chamber Temperature") + cpUiTr.emptyStr
                    dataText: chamber_temp
                }

                InfoItem {
                    id: printInfo_slicerName
                    labelText: qsTr("Slicer Name") + cpUiTr.emptyStr
                    dataText: slicer_name
                }
            }
        }
    }
}
