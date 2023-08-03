import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import StorageFileTypeEnum 1.0

// This component should only be used inside print page
// otherwise all references to variables used here will
// fail.
PopupMenu {
    id: optionsMenu
    menuHeight: children.height
    menuWidth: parent.width

    onOpened: {
        itemAt(count - 1).isLastItem = true
    }

    PopupMenuItem {
        id: addRemoveFileButton
        label: browsingUsbStorage ?
                   qsTr("ADD TO PRINTER STORAGE") :
                   qsTr("REMOVE FROM PRINTER STORAGE")
        onClicked: {
            if(browsingUsbStorage) {
                if(buttonInternalStorage.storageUsed < 95) {
                    storage.copyPrintFile(fileName)
                } else {
                    internalStorageFull = true
                    copyingFilePopup.open()
                }
            }
            else {
                storage.deletePrintFile(fileName)
                if(printSwipeView.currentIndex != PrintPage.FileBrowser) {
                    printSwipeView.swipeToItem(PrintPage.FileBrowser)
                    setDrawerState(true)
                }
            }
        }
    }

    PopupMenuItem {
        id: deleteFileButton
        label: qsTr("DELETE FILE")
        onClicked: {
            storage.deletePrintFile(fileName)
            if(printSwipeView.currentIndex != PrintPage.FileBrowser) {
                printSwipeView.swipeToItem(PrintPage.FileBrowser)
                setDrawerState(true)
            }
        }
        enabled: browsingUsbStorage
    }
}
