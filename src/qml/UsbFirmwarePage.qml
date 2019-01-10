import QtQuick 2.10
import StorageSortTypeEnum 1.0
import ProcessStateTypeEnum 1.0

UsbFirmwarePageForm {
    property bool updateFirmware: false

    function startFirmwareUpdate() {
        storage.backStackClear()
        updateFirmware = true
    }

    property bool fileCopySucceeded: storage.fileCopySucceeded
    onFileCopySucceededChanged: {
        if(fileCopySucceeded && updateFirmware) {
            updateFirmware = false
            // brooklyn_upload is chrooted to /home for security reasons so
            // don't pass file as /home/firmware/firmware.zip
            bot.installFirmwareFromDisk("firmware/firmware.zip")
        }
    }
}
