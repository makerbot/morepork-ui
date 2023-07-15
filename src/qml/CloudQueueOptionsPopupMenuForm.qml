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
        label: qsTr("DOWNLOAD TO PRINTER STORAGE")
        onClicked: {
            if(buttonInternalStorage.storageUsed < 95) {
                print_queue.downloadSlice(print_url_prefix, print_job_id,
                                          print_token, file_name)
            } else {
                internalStorageFull = true
            }
            copyingFilePopup.open()
        }
    }
}
