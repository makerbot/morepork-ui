import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0

Item {
    property string fileName: "unknown.makerbot"
    property alias printingDrawer: printingDrawer
    property alias mouseAreaTopDrawerUp: printingDrawer.mouseAreaTopDrawerUp
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
                        id: buttonNotImplemented1
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
                Item {
                    id: printFileItem
                    height: 100
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left

                    RowLayout {
                        smooth: false
                        spacing: 0
                        anchors.fill: parent

                        Image {
                            id: image
                            fillMode: Image.PreserveAspectFit
                            Layout.maximumHeight: 100
                            Layout.maximumWidth: 100
                            Layout.fillHeight: true
                            Layout.fillWidth: false
                            source: model.modelData.isDir ? "qrc:/img/directory_icon.png" :
                                    "image://thumbnail/" + model.modelData.filePath + "/" + model.modelData.fileName
                        }

                        MoreporkButton {
                            anchors.leftMargin: image.width
                            buttonText.text: model.modelData.fileBaseName
                            smooth: false
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
                        }
                    }

                    Item { width: parent.width; height: 1; smooth: false
                           Rectangle { color: "#505050"; smooth: false; anchors.fill: parent } }
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
    }
}
