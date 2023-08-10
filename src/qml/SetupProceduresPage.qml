import QtQuick 2.0

SetupProceduresPageForm {

    buttonSetupGuide.onClicked: {
        helpPopup.state = "fre"
        helpPopup.open()
    }

    buttonMaterialCase.onClicked: {
        setupProceduresSwipeView.swipeToItem(SetupProceduresPage.MaterialCaseSetup)
    }

}
