import QtQuick 2.4
import StorageSortTypeEnum 1.0

PrintPageForm {
    buttonUsbStorage.filenameText.text: qsTr("USB") + cpUiTr.emptyStr
    buttonInternalStorage.filenameText.text: qsTr("INTERNAL STORAGE") + cpUiTr.emptyStr

    printingDrawer.buttonCancelPrint.onClicked: {
        bot.cancel()
        printingDrawer.close()
    }

    printingDrawer.buttonPausePrint.onClicked: {
        bot.pausePrint()
        printingDrawer.close()
    }

    printingDrawer.buttonChangeFilament.onClicked: {

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
