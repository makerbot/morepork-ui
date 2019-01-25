import QtQuick 2.10
import StorageSortTypeEnum 1.0
import ProcessStateTypeEnum 1.0

FirmwareFileListUsbForm {
    property bool updateFirmware: false

    function startFirmwareUpdate() {
        updateFirmware = true
    }

    property bool fileCopySucceeded: storage.fileCopySucceeded
    onFileCopySucceededChanged: {
        if(fileCopySucceeded && updateFirmware) {
            updateFirmware = false
            storage.backStackClear()
            bot.installFirmwareFromPath("firmware/firmware.zip")
        }
    }
}
