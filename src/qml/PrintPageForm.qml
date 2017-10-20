import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    property alias printingDrawer: printingDrawer
    property alias mouseAreaTopDrawerUp: printingDrawer.mouseAreaTopDrawerUp
    property alias buttonCancelPrint: printingDrawer.buttonCancelPrint
    property alias buttonPausePrint: printingDrawer.buttonPausePrint

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
                setBackButtonSwipe(mainSwipeView, 0)
            }
            else {
                var i
                for(i = 1; i < printSwipeView.count; i++){
                    if(printSwipeView.itemAt(i).defaultIndex === itemToDisplayDefaultIndex){
                        if(i !== 1){
                            printSwipeView.moveItem(i, 1)
                        }
                        printSwipeView.setCurrentIndex(1)
                        if(itemToDisplayDefaultIndex > 0 && itemToDisplayDefaultIndex < 4) {
                            setBackButtonSwipe(printSwipeView, 0)
                        }
                        break
                    }
                }
            }
        }

        Item {
            property int defaultIndex: 0
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
                            setBackButtonSwipe(printSwipeView, 0)
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonInternalStorage
                        buttonText.text: qsTr("Internal Storage") + cpUiTr.emptyStr
                        onClicked: {
                            bot.updateInternalStorageFileList()
                            printSwipeView.swipeToItem(2)
                            setBackButtonSwipe(printSwipeView, 0)
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: goToPrintIcon
                        buttonText.text: qsTr("Go to Print Icon")
                        onClicked: {
                            printSwipeView.swipeToItem(3)
                            setBackButtonSwipe(printSwipeView, 0)
                        }
                    }
                }
            }
        }

        Item {
            property int defaultIndex: 1
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
            property int defaultIndex: 2

            ListView {
                width: parent.width
                height: parent.height
                boundsBehavior: Flickable.DragOverBounds
                spacing: 1
                orientation: ListView.Vertical
                flickableDirection: Flickable.VerticalFlick

                model: bot.internalStorageFileList
                delegate: MoreporkButton {
                    buttonText.text: modelData
                    onClicked: {
                        bot.print(buttonText.text)
                    }
                }
            }
        }

        Item{
            property int defaultIndex: 3
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
