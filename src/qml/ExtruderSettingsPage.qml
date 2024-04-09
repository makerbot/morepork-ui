import QtQuick 2.10
import QtQuick.Controls 2.2
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

ExtruderSettingsPageForm {
    buttonCalibrationProcedures.onClicked: {
        extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.CalibrationProceduresPage)
    }

    buttonCleanExtruders.onClicked: {
        extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.CleanExtrudersPage)
    }

    buttonAdjustZOffset.onClicked: {
        adjustZOffset.valueChanged = false
        bot.get_calibration_offsets()
        bot.getLastAutoCalOffsets()
        extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.AdjustZOffsetPage)
    }
}

