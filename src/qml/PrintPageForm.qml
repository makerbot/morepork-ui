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

    PrintingDrawer {
        id: printingDrawer
    }

    SwipeView {
        id: printSwipeView
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
            visible: false

            Flickable {
                id: flickableStorageOpt
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnStorageOpt.height
                visible: (bot.process.type != ProcessType.Print)

                Column {
                    id: columnStorageOpt
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MoreporkButton {
                        id: buttonUsbStorage
                        buttonText.text: "USB Storage"
                        onClicked: {
                            printSwipeView.swipeToItem(1)
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonInternalStorage
                        buttonText.text: "Internal Storage"
                        onClicked: {
                            bot.updateInternalStorageFileList()
                            printSwipeView.swipeToItem(2)
                        }
                    }
                }
            }

            PrintStatusViewForm{
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
            visible: false

            Flickable {
                id: flickableUsbStorage
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnUsbStorage.height

                Column {
                    id: columnUsbStorage
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
            visible: false

            ListView {
                anchors.fill: parent
                boundsBehavior: Flickable.DragOverBounds
                spacing: 1
                orientation: ListView.Vertical
                flickableDirection: Flickable.VerticalFlick

                model: bot.internalStorageFileList
                delegate: MoreporkButton {
                    buttonText.text: modelData
                    onClicked: {
                        if(buttonText.text !== "No Internal Files Found") {
                            fileName = buttonText.text
                            printSwipeView.swipeToItem(3)
                        }
                    }
                }
            }
        }

        // printSwipeView.index = 3
        Item {
            id: itemPrintFileOpt
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: bot.process.type == ProcessType.Print ? mainSwipeView : printSwipeView
            property int backSwipeIndex: bot.process.type == ProcessType.Print ? 0 : 2 // or 1 (both can use this Item theoretically)
            visible: false

            Flickable {
                id: flickableFileOpt
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnStorageOpt.height

                Column {
                    id: columnFilePrintOpt
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MoreporkButton {
                        id: buttonFilePrint
                        buttonText.text: "Print"
                        onClicked: {
                            bot.print(fileName)
                            printSwipeView.swipeToItem(0)
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonFileInfo
                        buttonText.text: "Info"
                        onClicked: {
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }


                    SwipeView {
                        id: printDeleteSwipeView
                        height: buttonFileInfo.height
                        anchors.right: parent.right
                        anchors.left: parent.left
                        interactive: false

                        Item {
                            MoreporkButton {
                                id: buttonFileDelete
                                buttonText.text: "Delete"
                                onClicked: {
                                    printDeleteSwipeView.setCurrentIndex(1)
                                }
                            }
                        }

                        Item{
                            Row{
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
