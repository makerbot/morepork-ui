import QtQuick 2.10

StartPrintSpecialInstructionsForm {
    nextButton.button_mouseArea.onClicked: {
        acknowledged = true
    }

    dontShowButton.button_mouseArea.onClicked: {
        acknowledged = true
        settings.setShowApplyGlueOnBuildPlateTip(print_model_material, false)
    }
}
