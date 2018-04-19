import QtQuick 2.4
import StorageSortTypeEnum 1.0
import ProcessStateTypeEnum 1.0

PrintPageForm {
    buttonUsbStorage.filenameText.text: qsTr("USB") + cpUiTr.emptyStr
    buttonInternalStorage.filenameText.text: qsTr("INTERNAL STORAGE") + cpUiTr.emptyStr

    printingDrawer.buttonCancelPrint.onClicked: {
        bot.cancel()
        printingDrawer.close()
    }

    printingDrawer.buttonPausePrint.onClicked: {
        if(bot.process.stateType == ProcessStateType.Printing) {
            bot.pauseResumePrint("suspend")
        }
        else if(bot.process.stateType == ProcessStateType.Paused) {
            bot.pauseResumePrint("resume")
        }
        printingDrawer.close()
    }

    printingDrawer.buttonChangeFilament.onClicked: {
        if(bot.process.stateType == ProcessStateType.Paused) {
            if(printPage.printStatusView.printStatusSwipeView.currentIndex != 0) {
                printPage.printStatusView.printStatusSwipeView.setCurrentIndex(0)
            }
            if(mainSwipeView.currentIndex != 5) {
                mainSwipeView.swipeToItem(5)
            }
            printingDrawer.close()
        }
    }

    printingDrawer.buttonClose.onClicked: {
        printingDrawer.close()
    }

    sortingDrawer.buttonSortAZ.onClicked: {
        sortingDrawer.buttonSortAZ.buttonImage.source = "qrc:/img/check_circle_small.png"
        sortingDrawer.buttonSortDateAdded.buttonImage.source = ""
        sortingDrawer.buttonSortPrintTime.buttonImage.source = ""
        storage.sortType = StorageSortType.Alphabetic
        sortingDrawer.close()
    }

    sortingDrawer.buttonSortDateAdded.onClicked: {
        sortingDrawer.buttonSortAZ.buttonImage.source = ""
        sortingDrawer.buttonSortDateAdded.buttonImage.source = "qrc:/img/check_circle_small.png"
        sortingDrawer.buttonSortPrintTime.buttonImage.source = ""
        storage.sortType = StorageSortType.DateAdded
        sortingDrawer.close()
    }

    sortingDrawer.buttonSortPrintTime.onClicked: {
        sortingDrawer.buttonSortAZ.buttonImage.source = ""
        sortingDrawer.buttonSortDateAdded.buttonImage.source = ""
        sortingDrawer.buttonSortPrintTime.buttonImage.source = "qrc:/img/check_circle_small.png"
        storage.sortType = StorageSortType.PrintTime
        sortingDrawer.close()
    }

    sortingDrawer.buttonClose.onClicked: {
        sortingDrawer.close()
    }
}
