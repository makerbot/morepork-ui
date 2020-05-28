// This component is used in two places in the UI for selecting
// custom cleaning temperature for the labs extruder
// 1.) Standalone Nozzle Cleaning Process
// 2.) Interim nozzle cleaning steps in Calibration process
import QtQuick 2.10
import ProcessTypeEnum 1.0

CleanExtruderSettingsForm {
    function startCleaning(temp_list) {
        if(bot.process.type == ProcessType.CalibrationProcess) {
            // Calls process method to perform nozzle cleaning in
            // 'Nozzle Calibration' Kaiten Process
            bot.doNozzleCleaning(true, temp_list)
            chooseMaterial = false
        } else {
            // Calls jsonrpc method for initiating 'Nozzle Cleaning'
            // Kaiten Process
            bot.cleanNozzles(temp_list)
        }
    }
}
