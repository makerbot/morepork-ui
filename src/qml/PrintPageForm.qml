import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    property string fileName: "emptry_str"
    property alias printingDrawer: printingDrawer
    property alias mouseAreaTopDrawerUp: printingDrawer.mouseAreaTopDrawerUp
    property alias buttonCancelPrint: printingDrawer.buttonCancelPrint
    property alias buttonPausePrint: printingDrawer.buttonPausePrint
    property alias printDeleteSwipeView: printDeleteSwipeView
    property alias defaultItem: itemPrintStorageOpt

    PrintingDrawer {
        id: printingDrawer
    }

    SwipeView {
        id: printSwipeView
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex){
            if(itemToDisplayDefaultIndex === 0){
                printSwipeView.setCurrentIndex(0)
                setCurrentItem(printSwipeView.itemAt(0))
            }
            else {
                var i
                for(i = 1; i < printSwipeView.count; i++){
                    if(printSwipeView.itemAt(i).defaultIndex === itemToDisplayDefaultIndex){
                        if(i !== 1){
                            printSwipeView.moveItem(i, 1)
                        }
                        setCurrentItem(printSwipeView.itemAt(1))
                        printSwipeView.setCurrentIndex(1)
                        break
                    }
                }
            }
        }

        Item {
            id: itemPrintStorageOpt
            property int defaultIndex: 0
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: mainSwipeView
            property int backSwipeIndex: 0

            Flickable {
                id: flickableStorageOpt
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnStorageOpt.height

                Column {
                    id: columnStorageOpt
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MoreporkButton {
                        id: buttonUsbStorage
                        buttonText.text: qsTr("USB Storage") + cpUiTr.emptyStr
                        onClicked: {
                            printSwipeView.swipeToItem(1)
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonInternalStorage
                        buttonText.text: qsTr("Internal Storage") + cpUiTr.emptyStr
                        onClicked: {
                            bot.updateInternalStorageFileList()
                            printSwipeView.swipeToItem(2)
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: goToPrintIcon
                        buttonText.text: qsTr("Print Icon Demo")
                        onClicked: {
                            printSwipeView.swipeToItem(4)
                        }
                    }
                }
            }
        }

        Item {
            id: itemPrintUsbStorage
            property int defaultIndex: 1
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: printSwipeView
            property int backSwipeIndex: 0

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

        // TODO: transitioning to and from this listview is a jump instead of slide transition
        // Clicking on an item in the list jump transitions to flickableFileOpt
        // Clicking the back button while on flickableFileOpt is also a jump transition
        Item {
            id: itemPrintInternalStorage
            property int defaultIndex: 2
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: printSwipeView
            property int backSwipeIndex: 0

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

        Item {
            id: itemPrintFileOpt
            property int defaultIndex: 3
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: printSwipeView
            property int backSwipeIndex: 2 // or 1 (both can use this Item theoretically)

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
                        buttonText.text: qsTr("Print") + cpUiTr.emptyStr
                        onClicked: {
                            bot.print(fileName)
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonFileInfo
                        buttonText.text: qsTr("Info") + cpUiTr.emptyStr
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
                                buttonText.text: qsTr("Delete") + cpUiTr.emptyStr
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
                                    buttonText.text: qsTr("For Real?") + cpUiTr.emptyStr
                                    buttonText.color: "#f0f0f0"
                                    enabled: false
                                }

                                MoreporkButton {
                                    id: buttonDeleteYes
                                    anchors.left: {}
                                    anchors.right: {}
                                    width: printDeleteSwipeView.width/3
                                    buttonText.text: qsTr("Yes") + cpUiTr.emptyStr
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
                                    buttonText.text: qsTr("No") + cpUiTr.emptyStr
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

        Item {
            id: itemPrintIconDemo
            property int defaultIndex: 4
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: printSwipeView
            property int backSwipeIndex: 0

            PrintIcon{
                x: 8
                y: 40
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 8
            }
        }
    }
}
