import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12
import ProcessStateTypeEnum 1.0

LoggingItem {
    itemName: "ManualCalibrationPrintFinished"
    id: manualCalibrationPrintFinished
    width: 400
    height: 165

    ColumnLayout {
        id: buttonContainerManualCalibration
        anchors.top: parent.top
        anchors.topMargin: 2
        spacing: 10

        ButtonRectanglePrimary {
            text: {
                if(bot.process.stateType == ProcessStateType.Cancelled ||
                        bot.process.stateType == ProcessStateType.Failed) {
                    qsTr("RETRY")
                } else {
                    qsTr("NEXT")
                }
            }
            logKey: text
            onClicked: {
                acknowledgePrint()
                // GO BACK TO MANUAL CALIBRATION
                mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.ExtruderSettingsPage)
                settingsPage.extruderSettingsPage.extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.CalibrationProceduresPage)
                settingsPage.extruderSettingsPage.calibrationProcedures.calibrationProceduresSwipeView.swipeToItem(CalibrationProceduresPage.ManualZCalibrationPage)
                if(bot.process.stateType == ProcessStateType.Cancelled ||
                        bot.process.stateType == ProcessStateType.Failed) {
                    settingsPage.extruderSettingsPage.calibrationProcedures.manualZCalibration.printSuccess = false
                    settingsPage.extruderSettingsPage.calibrationProcedures.manualZCalibration.resetProcess(false)
                } else {
                    settingsPage.extruderSettingsPage.calibrationProcedures.manualZCalibration.printSuccess = true
                    settingsPage.extruderSettingsPage.calibrationProcedures.manualZCalibration.state = "remove_support"
                }
            }
        }

        ButtonRectangleSecondary {
            text: qsTr("PRINT FAILED")
            logKey: text
            onClicked: {
                acknowledgePrint()
                if(bot.process.stateType == ProcessStateType.Cancelled ||
                        bot.process.stateType == ProcessStateType.Failed) {
                    settingsPage.extruderSettingsPage.calibrationProcedures.manualZCalibration.printSuccess = false
                } else {
                    settingsPage.extruderSettingsPage.calibrationProcedures.manualZCalibration.printSuccess = true
                }

                // PROMPT USER TO REDO AUTOCAL
                mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.ExtruderSettingsPage)
                settingsPage.extruderSettingsPage.extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.CalibrationProceduresPage)
                settingsPage.extruderSettingsPage.calibrationProcedures.calibrationProceduresSwipeView.swipeToItem(CalibrationProceduresPage.ManualZCalibrationPage)
                settingsPage.extruderSettingsPage.calibrationProcedures.manualZCalibration.state = "cal_issue"
            }
        }
    }
}
