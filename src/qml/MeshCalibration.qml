import QtQuick 2.10
import ProcessStateTypeEnum 1.0
import ExtruderTypeEnum 1.0

MeshCalibrationForm {
    contentRightSide {
        buttonPrimary {
            onClicked: {
                if (state == "calibration_finished") {
                    meshCalibration.processDone()
                } else if (state == "install_build_plate") {
                    meshCalibration.state = "secure_build_plate"
                } else if (state == "secure_build_plate") {
                    bot.calibrateMesh()
                } else {
                    // Button action in 'base state'
                    meshCalibration.state = "install_build_plate"
                }
            }
        }
    }

    cleanExtrudersSequence {
        contentRightSide {
            buttonPrimary {
                onClicked: {
                    if (meshCalibration.state == "clean_nozzles" &&
                            bot.process.stateType == ProcessStateType.CheckNozzleClean) {
                        if (bot.extruderAType == ExtruderType.MK14_EXP) {
                            meshCalibration.chooseMaterial = true
                        } else {
                            bot.doNozzleCleaning(true)
                        }
                    } else if (meshCalibration.state == "clean_nozzles" &&
                            bot.process.stateType == ProcessStateType.FinishCleaning) {
                        bot.acknowledgeNozzleCleaned(true)
                    }
                }
            }

            buttonSecondary1 {
                onClicked: {
                    if (meshCalibration.state == "clean_nozzles" &&
                            bot.process.stateType == ProcessStateType.CheckNozzleClean) {
                        bot.doNozzleCleaning(false)
                    } else if (meshCalibration.state == "clean_nozzles" &&
                            bot.process.stateType == ProcessStateType.FinishCleaning) {
                        bot.acknowledgeNozzleCleaned(false)
                    }
                }
            }
        }
    }
}
