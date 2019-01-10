import QtQuick 2.10
import StorageSortTypeEnum 1.0
import ProcessStateTypeEnum 1.0

UsbFirmwarePageForm {
    property string firmwareFileName: "empty"
    property bool updateFirmware: false

    function startFirmwareUpdate(file_name) {
        storage.backStackClear()
        updateFirmware = true
        firmwareFileName = file_name
    }

    property bool fileCopySucceeded: storage.fileCopySucceeded
    onFileCopySucceededChanged: {
        if(fileCopySucceeded && updateFirmware) {
            updateFirmware = false
            bot.installFirmwareFromDisk(firmwareFileName)
        }
    }
}
