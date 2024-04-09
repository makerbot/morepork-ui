import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

LoggingItem {
    itemName: "CleanExtruders"
    id: cleanExtrudersPage
    width: 800
    height: 408

    property alias contentLeftSide: contentLeftSide
    property alias contentRightSide: contentRightSide
    property alias cleanExtrudersSequence: cleanExtrudersSequence
    property alias cancelCleanExtrudersPopup: cancelCleanExtrudersPopup
    property int currentStep: bot.process.stateType
    signal processDone
    property bool hasFailed: bot.process.errorCode > 0

    onCurrentStepChanged: {
        if(bot.process.type == ProcessType.NozzleCleaningProcess) {
            switch(currentStep) {
                case ProcessStateType.CleaningUp:
                   if (state != "cancelling" &&
                       state != "clean_extruders_failed" &&
                       !bot.process.cancelled) {
                       state = "clean_extruders_complete"
                   }
                   break;
                case ProcessStateType.Cancelling:
                    state = "cancelling"
                    break;
            }
        } else if(bot.process.type == ProcessType.None) {
            if(state == "cancelling") {
                processDone()
            }
        }
    }

    onHasFailedChanged: {
        if(bot.process.type == ProcessType.NozzleCleaningProcess) {
            state = "clean_extruders_failed"
        }
    }

    ContentLeftSide {
        id: contentLeftSide
        image {
            source: "qrc:/img/check_nozzles_clean.png"
            visible: true
        }
        loadingIcon {
            visible: false
        }
        visible: true
    }

    ContentRightSide {
        id: contentRightSide
        textHeader {
            text: qsTr("CLEAN EXTRUDER NOZZLES")
            visible: true
        }
        textBody {
            text: qsTr("Cleaning is not required the first time using the extruders. Otherwise, inspect the tips of the extruder for excess material.")
            visible: true
        }
        buttonPrimary {
            text: qsTr("START")
            visible: true
        }
        visible: true
    }

    CleanExtrudersSequence {
        id: cleanExtrudersSequence
        visible: false
        enabled: bot.process.type == ProcessType.NozzleCleaningProcess
    }

    CleanExtruderSettings {
        id: materialSelector
        visible: false
    }

    states: [
        State {
            name: "base state"

            PropertyChanges {
                target: contentLeftSide
                visible: true
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.image
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.loadingIcon
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.buttonSecondary1
                visible: false
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }

            PropertyChanges {
                target: cleanExtrudersSequence
                visible: false
            }
        },

        State {
            name: "choose_material"

            PropertyChanges {
                target: contentLeftSide
                visible: false
            }

            PropertyChanges {
                target: contentRightSide
                visible: false
            }

            PropertyChanges {
                target: cleanExtrudersSequence
                visible: false
            }

            PropertyChanges {
                target: materialSelector
                visible: true
            }
        },

        State {
            name: "loading"
            when: bot.process.type == ProcessType.NozzleCleaningProcess &&
                  (bot.process.stateType == ProcessStateType.Running)

            PropertyChanges {
                target: contentLeftSide
                visible: true
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.image
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.loadingIcon
                icon_image: LoadingIcon.Loading
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("LOADING")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("Please wait.")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                visible: false
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },

        State {
            name: "cleaning_process"
            when: bot.process.type == ProcessType.NozzleCleaningProcess &&
                  (bot.process.stateType == ProcessStateType.HeatingNozzle ||
                   bot.process.stateType == ProcessStateType.CleanNozzle ||
                   bot.process.stateType == ProcessStateType.FinishCleaning)

            PropertyChanges {
                target: contentLeftSide
                visible: false
            }

            PropertyChanges {
                target: contentRightSide
                visible: false
            }

            PropertyChanges {
                target: cleanExtrudersSequence
                visible: true
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },

        State {
            name: "clean_extruders_complete"

            PropertyChanges {
                target: contentLeftSide
                visible: true
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.image
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.loadingIcon
                icon_image: LoadingIcon.Success
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("PROCESS COMPLETE")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                text: qsTr("DONE")
                visible: true
            }

            PropertyChanges {
                target: cleanExtrudersSequence
                visible: false
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },

        State {
            name: "clean_extruders_failed"
            extend: "clean_extruders_complete"

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("PROCESS FAILED")
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.loadingIcon
                icon_image: LoadingIcon.Failure
                visible: true
            }
        },

        State {
            name: "cancelling"
            extend: "loading"
            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("CANCELLING")
                visible: true
            }
        }
    ]

    CustomPopup {
        popupName: "CancelCleanExtruders"
        id: cancelCleanExtrudersPopup
        popupWidth: 720
        popupHeight: 250
        showTwoButtons: true

        leftButtonText: qsTr("BACK")
        leftButton.onClicked: {
            cancelCleanExtrudersPopup.close()
        }
        rightButtonText: qsTr("CONFIRM")
        rightButton.onClicked: {
            bot.cancel()
            state = "cancelling"
            cancelCleanExtrudersPopup.close()
        }

        ColumnLayout {
            id: columnLayout
            width: 590
            height: 100
            anchors.top: parent.top
            anchors.topMargin: 145
            anchors.horizontalCenter: parent.horizontalCenter

            TextHeadline {
                text: qsTr("CANCEL CLEAN EXTRUDERS")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            TextBody {
                text: qsTr("Are you sure you want to exit the clean extruders process?")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }
        }
    }
}
