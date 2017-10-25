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

        function swipeForward(itemToDisplayDefaultIndex){
            swipeToItem(itemToDisplayDefaultIndex, true)
        }

        function swipeBackward(itemToDisplayDefaultIndex){
            swipeToItem(itemToDisplayDefaultIndex, false)
        }

        function swipeToItem(itemToDisplayDefaultIndex, moveforward) {
            var nextIndex = moveforward ? printSwipeView.currentIndex+1 : printSwipeView.currentIndex-1
            var i
            for(i = 0; i < printSwipeView.count; ++i) {
                if(printSwipeView.itemAt(i).defaultIndex === itemToDisplayDefaultIndex) {
                    if(i !== 1)
                        printSwipeView.moveItem(i, nextIndex)
                    setCurrentItem(printSwipeView.itemAt(nextIndex))
                    printSwipeView.setCurrentIndex(nextIndex)
                    break
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
                            printSwipeView.swipeForward(1)
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonInternalStorage
                        buttonText.text: qsTr("Internal Storage") + cpUiTr.emptyStr
                        onClicked: {
                            bot.updateInternalStorageFileList()
                            printSwipeView.swipeForward(2)
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: goToPrintIcon
                        buttonText.text: qsTr("Print Icon Demo")
                        onClicked: {
                            printSwipeView.swipeForward(4)
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
                            printSwipeView.swipeForward(3)
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
                                        printSwipeView.swipeForward(2)
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

            SwipeView {
                id: printingSwipeView
                currentIndex: 0
                anchors.fill: parent

                Item {
                    id: page0
                    PrintIcon{
                        x: 8
                        y: 40
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                    }
                }

                Item {
                    id: page1
                }

                Item {
                    id: page2
                }

                Item {
                    id: page3
                }
            }

            PageIndicator {
                id: indicator

                count: printingSwipeView.count
                currentIndex: printingSwipeView.currentIndex

                anchors.bottom: printingSwipeView.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                delegate: Rectangle{
                    implicitWidth: 8
                    implicitHeight: 8

                    radius: width / 2
                    color: "#f0f0f0"

                    opacity: index === indicator.currentIndex ? 1.00 : (pressed ? 0.75 : 0.50)

                    Behavior on opacity {
                        OpacityAnimator {
                            duration: 100
                        }
                    }
                }
            }
        }
    }
}
