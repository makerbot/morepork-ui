import QtQuick 2.10
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

DryMaterialForm {
    contentRightSide {
        buttonPrimary {
            onClicked: {
                if (bot.process.type != ProcessType.DryingCycleProcess) {
                    if (!hasFinished) {
                        dryConfirmBuildPlateClearPopup.open()
                    } else {
                        processDone()
                        hasFinished = false
                    }
                } else {
                    if(currentStep == ProcessStateType.WaitingForSpool) {
                        if(state == "dry_kit_instructions_1") {
                            state = "dry_kit_instructions_2"
                        }
                        else if(state == "dry_kit_instructions_2") {
                            state = "waiting_for_spool"
                        }
                        else if(state == "waiting_for_spool") {
                            doChooseMaterial = true
                        }
                    } else if(currentStep == ProcessStateType.Done) {
                        processDone()
                        hasFinished = false
                    }
                }
            }
        }
    }
}
