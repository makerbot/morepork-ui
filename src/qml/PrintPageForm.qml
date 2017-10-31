import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

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
                    if(i !== nextIndex)
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
                //visible: (bot.process.type != 1)

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
                            printSwipeView.swipeForward(1)
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonInternalStorage
                        buttonText.text: "Internal Storage"
                        onClicked: {
                            bot.updateInternalStorageFileList()
                            printSwipeView.swipeForward(2)
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
            property var backSwiper: bot.process.type == 1 ? mainSwipeView : printSwipeView
            property int backSwipeIndex: bot.process.type == 1 ? 0 : 2 // or 1 (both can use this Item theoretically)
            property var backSwiperTest: printSwipeView
            property int backSwipeIndexTest: 0 // or 1 (both can use this Item theoretically)

            Flickable {
                id: flickableFileOpt
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnStorageOpt.height
                visible: (bot.process.type != 1)

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
                            //printSwipeView.swipeBackward(0)
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
                                        printSwipeView.swipeForward(2)
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

            SwipeView {
                id: printingSwipeView
                currentIndex: 0 // Should never be non zero
                anchors.fill: parent
                visible: (bot.process.type == 1)

                Item {
                    id: page0
                    PrintIcon{
                        x: 8
                        y: 40
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                    }

                    Column {
                        id: column0
                        x: 373
                        y: 180
                        spacing: 10
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            id: textPrintState
                            text: "PRINTING" //GETTING READY, PRINTING, PAUSED, PRINT COMPLETE
                            font.family: "Antenna"
                            font.letterSpacing: 3
                            font.weight: Font.Normal
                            font.pointSize: 25
                            color: "#a0a0a0"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        Text {
                            id: textFileName
                            text: fileName
                            font.family: "Antenna"
                            font.letterSpacing: 3
                            font.weight: Font.Light
                            font.pointSize: 20
                            color: "#a0a0a0"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        Column {
                            id: column1
                            spacing: 10

                            Text {
                                id: textTimeRemaining
                                text: bot.process.timeRemaining
                                font.family: "Antenna"
                                font.letterSpacing: 3
                                font.weight: Font.Light
                                font.pointSize: 20
                                color: "#a0a0a0"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            Text {
                                id: text0
                                text: "HEATING UP..."
                                visible: false
                                font.family: "Antenna"
                                font.letterSpacing: 3
                                font.weight: Font.Light
                                font.pointSize: 20
                                color: "#a0a0a0"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            Row {
                                id: row0
                                spacing: 15

                                Text {
                                    id: textExtACurrTemp
                                    text: bot.extruderACurrentTemp + "°C"
                                    font.family: "Antenna"
                                    font.letterSpacing: 3
                                    font.weight: Font.Light
                                    font.pointSize: 20
                                    color: "#a0a0a0"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }

                                Item { width: 1; height: parent.height; Rectangle { color: "#505050"; anchors.fill: parent } }

                                Text {
                                    id: textExtATargTemp
                                    text: bot.extruderATargetTemp + "°C"
                                    font.family: "Antenna"
                                    font.letterSpacing: 3
                                    font.weight: Font.Light
                                    font.pointSize: 20
                                    color: "#a0a0a0"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }
                            }

                            Row {
                                id: row1
                                spacing: 15

                                Text {
                                    id: textExtBCurrTemp
                                    text: bot.extruderBCurrentTemp + "°C"
                                    font.family: "Antenna"
                                    font.letterSpacing: 3
                                    font.weight: Font.Light
                                    font.pointSize: 20
                                    color: "#a0a0a0"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }

                                Item { width: 1; height: parent.height; Rectangle { color: "#505050"; anchors.fill: parent } }

                                Text {
                                    id: textExtBTargTemp
                                    text: bot.extruderBTargetTemp + "°C"
                                    font.family: "Antenna"
                                    font.letterSpacing: 3
                                    font.weight: Font.Light
                                    font.pointSize: 20
                                    color: "#a0a0a0"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }
                            }

                            Row {
                                id: row2
                                spacing: 15

                                Text {
                                    id: textChamberCurrTemp
                                    text: bot.chamberCurrentTemp + "°C"
                                    font.family: "Antenna"
                                    font.letterSpacing: 3
                                    font.weight: Font.Light
                                    font.pointSize: 20
                                    color: "#a0a0a0"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }

                                Item { width: 1; height: parent.height; Rectangle { color: "#505050"; anchors.fill: parent } }

                                Text {
                                    id: textChamberTargTemp
                                    text: bot.chamberTargetTemp + "°C"
                                    font.family: "Antenna"
                                    font.letterSpacing: 3
                                    font.weight: Font.Light
                                    font.pointSize: 20
                                    color: "#a0a0a0"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }

                Item {
                    id: page1
                    visible: (bot.process.type == 1)

                    Text {
                        id: blankPageText
                        text: "BLANK PAGE"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: "Antenna"
                        font.letterSpacing: 3
                        font.weight: Font.Light
                        font.pointSize: 40
                        color: "#a0a0a0"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
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
