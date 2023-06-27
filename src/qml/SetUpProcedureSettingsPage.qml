import QtQuick 2.0

SetUpProcedureSettingsPageForm {

    buttonSetupGuide.onClicked: {
        helpPopup.state = "fre"
        helpPopup.open()
    }

    buttonMaterialCase.onClicked: {
        setUpProcedureSettingsSwipeView.swipeToItem(SetUpProcedureSettingsPage.MaterialCaseSetup)
    }

}
