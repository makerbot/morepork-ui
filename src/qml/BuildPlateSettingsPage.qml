import QtQuick 2.10
import QtQuick.Controls 2.2
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

BuildPlateSettingsPageForm {
    buttonAssistedLeveling.onClicked: {
        buildPlateSettingsSwipeView.swipeToItem(BuildPlateSettingsPage.AssistedLevelingPage)
    }

    buttonMoveBuildPlatePage.onClicked: {
        /*if(raiseLowerBuildPlate.chamberDoorOpen) {
            doorOpenRaiseLowerBuildPlatePopup.open()
            return
        }*/

        buildPlateSettingsSwipeView.swipeToItem(BuildPlateSettingsPage.RaiseLowerBuildPlatePage)
    }
}
