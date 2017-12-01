import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0

Item {
    property string fileName: "unknown.makerbot"
    property alias printingDrawer: printingDrawer
    property alias buttonCancelPrint: printingDrawer.buttonCancelPrint
    property alias buttonPausePrint: printingDrawer.buttonPausePrint
    property alias printDeleteSwipeView: printDeleteSwipeView
    property alias defaultItem: itemPrintStorageOpt
    property alias buttonUsbStorage: buttonUsbStorage
    property alias buttonInternalStorage: buttonInternalStorage
    property alias buttonFilePrint: buttonFilePrint
    property alias buttonFileInfo: buttonFileInfo
    property alias buttonFileDelete: buttonFileDelete
    property bool internalStorage: false
    smooth: false

    PrintingDrawer {
        id: printingDrawer
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
                visible: (bot.process.type != ProcessType.Print)

                Column {
                    id: columnStorageOpt
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MoreporkButton {
                        id: buttonUsbStorage
                        buttonText.text: "USB Storage"
                        onClicked: {
                            internalStorage = false
                            printSwipeView.swipeToItem(1)
                        }
                    }

                    Item { width: parent.width; height: 1; smooth: false
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent
                        }
                    }

                    MoreporkButton {
                        id: buttonInternalStorage
                        buttonText.text: "Internal Storage"
                        onClicked: {
                            internalStorage = true
                            storage.updateInternalStorageFileList()
                            printSwipeView.swipeToItem(2)
                        }
                    }
                }
            }

            PrintStatusViewForm{
                smooth: false
                visible: bot.process.type == ProcessType.Print
                fileName_: fileName
            }
        }

        // printSwipeView.index = 1
        Item {
            id: itemPrintUsbStorage
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: printSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            Flickable {
                id: flickableUsbStorage
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnUsbStorage.height

                Column {
                    id: columnUsbStorage
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MoreporkButton {
                        id: buttonNotImplemented
                        buttonText.text: "Not Implemented"
                    }
                }
            }
        }

        // printSwipeView.index = 2
        Item {
            id: itemPrintInternalStorage
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: printSwipeView
            property int backSwipeIndex: 0
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack(){
                var backDir = storage.backStackPop()
                if(backDir !== ""){
                    storage.updateInternalStorageFileList(storage.backStackPop())
                }
                else{
                    printSwipeView.swipeToItem(0)
                }
            }

            ListView {
                smooth: false
                anchors.fill: parent
                boundsBehavior: Flickable.DragOverBounds
                spacing: 1
                orientation: ListView.Vertical
                flickableDirection: Flickable.VerticalFlick

                model: storage.printFileList
                delegate:
                    FileButton{
                        property int printTimeSecRaw: model.modelData.timeEstimateSec
                        property int printTimeMinRaw: printTimeSecRaw/60
                        property int printTimeHrRaw: printTimeMinRaw/60
                        property int printTimeDay: printTimeHrRaw/24
                        property int printTimeMin: printTimeMinRaw % 60
                        property int printTimeHr: printTimeHrRaw % 24
                        smooth: false
                        antialiasing: false
                        fileThumbnail.source: "image://thumbnail/" + model.modelData.filePath + "/" + model.modelData.fileName
                        filenameText.text: model.modelData.fileBaseName
                        fileDesc_rowLayout.visible: !model.modelData.isDir
                        filePrintTime.text: printTimeDay != 0 ? printTimeDay + "D" + printTimeHr + "HR" + printTimeMin + "M" : printTimeHr != 0 ? printTimeHr + "HR " + printTimeMin + "M" : printTimeMin + "M"
                        fileMaterial.text: model.modelData.materialNameA == "" ? model.modelData.materialNameB : model.modelData.materialNameA + "+" + model.modelData.materialNameB

                        onClicked: {
                            if(model.modelData.isDir){
                                storage.backStackPush(model.modelData.filePath)
                                storage.updateInternalStorageFileList(model.modelData.filePath + "/" + model.modelData.fileName)
                            }
                            else if(model.modelData.fileBaseName !== "thing") { // Ignore default fileBaseName object
                                fileName = model.modelData.filePath + "/" + model.modelData.fileName
                                printSwipeView.swipeToItem(3)
                            }
                        }

                    Item { width: parent.width; height: 1; smooth: false
                           Rectangle { color: "#4d4d4d"; smooth: false; anchors.fill: parent } }
                }
            }
        }

        // printSwipeView.index = 3
        Item {
            id: itemPrintFileOpt
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: bot.process.type == ProcessType.Print ? mainSwipeView : printSwipeView
            property int backSwipeIndex: bot.process.type == ProcessType.Print ? 0 : internalStorage ? 2 : 1
            smooth: false
            visible: false

            Flickable {
                id: flickableFileOpt
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnStorageOpt.height

                Column {
                    id: columnFilePrintOpt
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MoreporkButton {
                        id: buttonFilePrint
                        buttonText.text: "Print"
                        onClicked: {
                            storage.backStackClear()
                            bot.print(fileName)
                            printSwipeView.swipeToItem(0)
                        }
                    }

                    Item { width: parent.width; height: 1; smooth: false
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent
                        }
                    }

                    MoreporkButton {
                        id: buttonFileInfo
                        buttonText.text: "Info"
                        onClicked: {
                        }
                    }

                    Item { width: parent.width; height: 1; smooth: false
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent
                        }
                    }

                    SwipeView {
                        id: printDeleteSwipeView
                        height: buttonFileInfo.height
                        smooth: false
                        anchors.right: parent.right
                        anchors.left: parent.left
                        interactive: false

                        Item {
                            smooth: false
                            MoreporkButton {
                                id: buttonFileDelete
                                buttonText.text: "Delete"
                                onClicked: {
                                    printDeleteSwipeView.setCurrentIndex(1)
                                }
                            }
                        }

                        Item{
                            smooth: false
                            Row{
                                smooth: false
                                MoreporkButton {
                                    id: buttonConfirmDelete
                                    anchors.left: {}
                                    anchors.right: {}
                                    width: printDeleteSwipeView.width/3
                                    buttonText.text: "For Real?"
                                    buttonText.color: "#f0f0f0"
                                    enabled: false
                                }

                                MoreporkButton {
                                    id: buttonDeleteYes
                                    anchors.left: {}
                                    anchors.right: {}
                                    width: printDeleteSwipeView.width/3
                                    buttonText.text: "Yes"
                                    onClicked: {
                                        bot.deletePrintFile(fileName)
                                        bot.updateInternalStorageFileList()
                                        printSwipeView.swipeToItem(2)
                                        printDeleteSwipeView.setCurrentIndex(0)
                                    }
                                }

                                MoreporkButton {
                                    id: buttonDeleteNo
                                    anchors.left: {}
                                    anchors.right: {}
                                    width: printDeleteSwipeView.width/3
                                    buttonText.text: "No"
                                    onClicked: {
                                        printDeleteSwipeView.setCurrentIndex(0)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // printSwipeView.index = 4
        Item {
           id: itemPrintInfoOpt
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: bot.process.type == ProcessType.Print ? mainSwipeView : printSwipeView
            property int backSwipeIndex: bot.process.type == ProcessType.Print ? 0 : 3
            smooth: false
            visible: false

            Flickable {
                id: flickable
                anchors.fill: parent
                anchors.leftMargin: 15
                interactive: true
                flickableDirection: Flickable.VerticalFlick
                contentHeight: column.height
                smooth: false

                Column {
                    id: column
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 1

                    InfoItem {
                        id: printInfo_fileName
                        width: parent.width
                        textLabel.text: qsTr("Filename") + cpUiTr.emptyStr
                        textData.text: model.modelData.fileBaseName
                    }

                    InfoItem {
                        id: printInfo_filePath
                        width: parent.width
                        textLabel.text: qsTr("File Path") + cpUiTr.emptyStr
                        textData.text: model.modelData.filePath
                    }

                    InfoItem {
                        property int printTimeSecRaw: model.modelData.timeEstimateSec
                        property int printTimeMinRaw: printTimeSecRaw/60
                        property int printTimeHrRaw: printTimeMinRaw/60
                        property int printTimeDay: printTimeHrRaw/24
                        property int printTimeMin: printTimeMinRaw % 60
                        property int printTimeHr: printTimeHrRaw % 24
                        id: printInfo_timeEstimate
                        width: parent.width
                        textLabel.text: qsTr("Print Time Estimate") + cpUiTr.emptyStr
                        textData.text: printTimeDay != 0 ? printTimeDay + "D" + printTimeHr + "HR" + printTimeMin + "M" : printTimeHr != 0 ? printTimeHr + "HR " + printTimeMin + "M" : printTimeMin + "M"
                    }

                    InfoItem {
                        id: printInfo_material
                        width: parent.width
                        textLabel.text: qsTr("Print Material") + cpUiTr.emptyStr
                        textData.text: model.modelData.materialNameA == "" ? model.modelData.materialNameB : model.modelData.materialNameA + "+" + model.modelData.materialNameB
                    }

                    InfoItem {
                        id: printInfo_layerHeight
                        width: parent.width
                        textLabel.text: qsTr("Layer Height") + cpUiTr.emptyStr
                        textData.text: model.modelData.layerHeightMM + "mm"
                    }

                    InfoItem {
                        id: printInfo_infillDensity
                        width: parent.width
                        textLabel.text: qsTr("Infill Density") + cpUiTr.emptyStr
                        textData.text: model.modelData.infillDensity + "%"
                    }

                    InfoItem {
                        id: printInfo_usesSupport
                        width: parent.width
                        textLabel.text: qsTr("Supports") + cpUiTr.emptyStr
                        textData.text: model.modelData.usesSupport ? "YES" : "NO"
                    }

                    InfoItem {
                        id: printInfo_usesRaft
                        width: parent.width
                        textLabel.text: qsTr("Rafts") + cpUiTr.emptyStr
                        textData.text: model.modelData.usesSupport ? "YES" : "NO"
                    }

                    InfoItem {
                        id: printInfo_modelMass
                        width: parent.width
                        textLabel.text: qsTr("Model") + cpUiTr.emptyStr
                        textData.text: model.modelData.extrusionMassGramsB == "" ? "0 Kg" : model.modelData.extrusionMassGramsB/1000 + " Kg"
                    }

                    InfoItem {
                        id: printInfo_supportMass
                        width: parent.width
                        textLabel.text: qsTr("Support") + cpUiTr.emptyStr
                        textData.text: model.modelData.extrusionMassGramsA == "" ? "0 Kg" : model.modelData.extrusionMassGramsA/1000 + " Kg"
                    }

                    InfoItem {
                        id: printInfo_Shells
                        width: parent.width
                        textLabel.text: qsTr("Shells") + cpUiTr.emptyStr
                        textData.text: model.modelData.numShells
                    }

                    InfoItem {
                        id: printInfo_extruderTemperature
                        width: parent.width
                        textLabel.text: qsTr("Extruder Temperature") + cpUiTr.emptyStr
                        textData.text: model.modelData.extruderTempCelciusA == "" ? model.modelData.extruderTempCelciusB + "C" : model.modelData.extruderTempCelciusA + "C" + " + " + model.modelData.extruderTempCelciusB + "C"
                    }

                    InfoItem {
                        id: printInfo_chamberTemperature
                        width: parent.width
                        textLabel.text: qsTr("Chamber Temperature") + cpUiTr.emptyStr
                        textData.text: model.modeData.chamberTempCelcius + "C"
                    }

                    InfoItem {
                        id: printInfo_slicerName
                        width: parent.width
                        textLabel.text: qsTr("Slicer Name") + cpUiTr.emptyStr
                        textData.text: model.modelData.slicerName
                    }
                }
            }
        }
    }
}
