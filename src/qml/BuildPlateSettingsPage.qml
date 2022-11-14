import QtQuick 2.10
import QtQuick.Controls 2.2
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

BuildPlateSettingsPageForm {
    buttonRaiseLowerBuildPlate.onClicked: {
        buildPlateSettingsSwipeView.swipeToItem(BuildPlateSettingsPage.RaiseLowerBuildPlatePage)
    }

    buttonAssistedLeveling.onClicked: {
        buildPlateSettingsSwipeView.swipeToItem(BuildPlateSettingsPage.AssistedLevelingPage)
    }
}
