import QtQuick 2.10
import StorageSortTypeEnum 1.0
import ProcessStateTypeEnum 1.0

UsbFirmwarePageForm {
    function startFirmwareUpdate(file_name) {
        storage.backStackClear()
        bot.installFirmwareFromDisk(file_name)
    }
}
