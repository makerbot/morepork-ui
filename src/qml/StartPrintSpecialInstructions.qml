import QtQuick 2.10

StartPrintSpecialInstructionsForm {
    nextButton.onClicked: {
        acknowledged = true
    }

    dontShowButton.onClicked: {
        acknowledged = true
        settings.setShowApplyGlueOnBuildPlateTip(print_model_material, false)
    }
}
