import QtQuick 2.10
import QtQuick.Controls 2.2
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

ExtruderSettingsPageForm {
    buttonCalibrateToolhead.onClicked: {
        extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.CalibrateExtrudersPage)
    }

    buttonCalibrateZAxisOnly.onClicked: {
        extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.CalibrateExtrudersPage)
        bot.calibrateToolheads(["z"])
    }

    buttonCleanExtruders.onClicked: {
        extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.CleanExtrudersPage)
    }
}

