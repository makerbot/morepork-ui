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

    onOpened: {
        itemAt(count - 1).isLastItem = true
    }

    PopupMenuItem {
        id: addRemoveFileButton
        label: browsingUsbStorage ?
                   qsTr("Add to printer storage") :
                   qsTr("Remove from printer\nstorage")
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
                if(printSwipeView.currentIndex != 1) {
                    printSwipeView.swipeToItem(1)
                }
            }
        }
    }

    PopupMenuItem {
        id: deleteFileButton
        label: qsTr("Delete file")
        onClicked: {
            storage.deletePrintFile(fileName)
            if(printSwipeView.currentIndex != 1) {
                printSwipeView.swipeToItem(1)
            }
        }
        enabled: browsingUsbStorage
    }

    PopupMenuItem {
        id: closeMenuButton
        label: qsTr("Close")
        onClicked: {
            optionsMenu.close()
        }
    }
}
