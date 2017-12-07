import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0

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
    property bool browsingUsbStorage: false

    property bool usbStorageConnected: storage.usbStorageConnected
    onUsbStorageConnectedChanged: {
        if(!storage.usbStorageConnected && printSwipeView.currentIndex != 0 &&
            browsingUsbStorage)
            printSwipeView.swipeToItem(0)
    }

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
                        id: buttonInternalStorage
                        buttonText.text: "Internal Storage"
                        onClicked: {
                            browsingUsbStorage = false
                            storage.updateStorageFileList("?root_internal?")
                            printSwipeView.swipeToItem(1)
                        }
                    }

                    Item { width: parent.width; height: 1; smooth: false; visible: storage.usbStorageConnected
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent
                        }
                    }

                    MoreporkButton {
                        id: buttonUsbStorage
                        buttonText.text: "USB Storage"
                        visible: storage.usbStorageConnected
                        onClicked: {
                            browsingUsbStorage = true
                            storage.updateStorageFileList("?root_usb?")
                            printSwipeView.swipeToItem(1)
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
            id: itemPrintStorage
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: printSwipeView
            property int backSwipeIndex: 0
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack(){
                var backDir = storage.backStackPop()
                if(backDir !== ""){
                    storage.updateStorageFileList(backDir)
                }
                else{
                    printSwipeView.swipeToItem(0)
                }
            }

            Text{
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
                    FileButton{
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
                            if(model.modelData.isDir){
                                storage.backStackPush(model.modelData.filePath)
                                storage.updateStorageFileList(model.modelData.filePath + "/" + model.modelData.fileName)
                            }
                            else if(model.modelData.fileBaseName !== "No Items Present") { // Ignore default fileBaseName object
                                fileName = model.modelData.filePath + "/" + model.modelData.fileName
                                file_name = model.modelData.fileBaseName
                                printTimeSecRaw = model.modelData.timeEstimateSec
                                printTimeMinRaw = printTimeSecRaw/60
                                printTimeHrRaw = printTimeMinRaw/60
                                printTimeDay = printTimeHrRaw/24
                                printTimeMin = printTimeMinRaw % 60
                                printTimeHr = printTimeHrRaw % 24
                                print_time = printTimeDay > 1 ? (printTimeDay + "D" + printTimeHr + "HR" + printTimeMin + "M") :
                                    (printTimeHr > 1 ? printTimeHr + "HR " + printTimeMin + "M" : printTimeMin + "M")
                                print_material = model.modelData.materialNameA == "" ? model.modelData.materialNameB :
                                    model.modelData.materialNameA + "+" + model.modelData.materialNameB
                                uses_support = model.modelData.usesSupport ? "YES" : "NO"
                                uses_raft = model.modelData.usesRaft ? "YES" : "NO"
                                model_mass = model.modelData.extrusionMassGramsB < 1000 ?
                                    model.modelData.extrusionMassGramsB.toFixed(1) + " g" :
                                    (model.modelData.extrusionMassGramsB * 0.001).toFixed(1) + " Kg"
                                support_mass = model.modelData.extrusionMassGramsA < 1000 ?
                                    model.modelData.extrusionMassGramsA.toFixed(1) + " g" :
                                    (model.modelData.extrusionMassGramsA * 0.001).toFixed(1) + " Kg"
                                num_shells = model.modelData.numShells
                                extruder_temp = model.modelData.extruderTempCelciusA == 0 ?
                                    model.modelData.extruderTempCelciusB + "C" :
                                    model.modelData.extruderTempCelciusA + "C" + " + " + model.modelData.extruderTempCelciusB + "C"
                                chamber_temp = model.modelData.chamberTempCelcius + "C"
                                slicer_name = model.modelData.slicerName
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
            property var backSwiper: bot.process.type == ProcessType.Print ? mainSwipeView : printSwipeView
            property int backSwipeIndex: bot.process.type == ProcessType.Print ? 0 : 1
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
                            printSwipeView.swipeToItem(3)
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
                                        printSwipeView.swipeToItem(1)
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

        // printSwipeView.index = 3
        Item {
           id: itemPrintInfoOpt
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: bot.process.type == ProcessType.Print ? mainSwipeView : printSwipeView
            property int backSwipeIndex: bot.process.type == ProcessType.Print ? 0 : 2
            smooth: false
            visible: false

            Flickable {
                id: flickable
                anchors.topMargin: 10
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
                        textData.text: file_name
                    }

                    InfoItem {
                        id: printInfo_timeEstimate
                        width: parent.width
                        textLabel.text: qsTr("Print Time Estimate") + cpUiTr.emptyStr
                        textData.text: print_time
                    }

                    InfoItem {
                        id: printInfo_material
                        width: parent.width
                        textLabel.text: qsTr("Print Material") + cpUiTr.emptyStr
                        textData.text: print_material
                    }

                    InfoItem {
                        id: printInfo_usesSupport
                        width: parent.width
                        textLabel.text: qsTr("Supports") + cpUiTr.emptyStr
                        textData.text: uses_support
                    }

                    InfoItem {
                        id: printInfo_usesRaft
                        width: parent.width
                        textLabel.text: qsTr("Rafts") + cpUiTr.emptyStr
                        textData.text: uses_raft
                    }

                    InfoItem {
                        id: printInfo_modelMass
                        width: parent.width
                        textLabel.text: qsTr("Model") + cpUiTr.emptyStr
                        textData.text: model_mass
                    }

                    InfoItem {
                        id: printInfo_supportMass
                        width: parent.width
                        textLabel.text: qsTr("Support") + cpUiTr.emptyStr
                        textData.text: support_mass
                    }

                    InfoItem {
                        id: printInfo_Shells
                        width: parent.width
                        textLabel.text: qsTr("Shells") + cpUiTr.emptyStr
                        textData.text: num_shells
                    }

                    InfoItem {
                        id: printInfo_extruderTemperature
                        width: parent.width
                        textLabel.text: qsTr("Extruder Temperature") + cpUiTr.emptyStr
                        textData.text: extruder_temp
                    }

                    InfoItem {
                        id: printInfo_chamberTemperature
                        width: parent.width
                        textLabel.text: qsTr("Chamber Temperature") + cpUiTr.emptyStr
                        textData.text: chamber_temp
                    }

                    InfoItem {
                        id: printInfo_slicerName
                        width: parent.width
                        textLabel.text: qsTr("Slicer Name") + cpUiTr.emptyStr
                        textData.text: slicer_name
                    }
                }
            }
        }
    }
}
