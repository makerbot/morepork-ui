import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    id: cleanExtrudersPage
    width: 800
    height: 420
    smooth: false
    antialiasing: false
    property alias cancelCleanExtrudersPopup: cancelCleanExtrudersPopup
    property alias actionButton: actionButton
    property int currentStep: bot.process.stateType
    signal processDone
    property bool hasFailed: bot.process.errorCode > 0

    onCurrentStepChanged: {
        if(bot.process.type == ProcessType.NozzleCleaningProcess) {
            switch(currentStep) {
                case ProcessStateType.HeatingNozzle:
                    state = "heating_nozzle"
                    break;
                case ProcessStateType.CleanNozzle:
                    state = "clean_nozzle"
                    break;
                case ProcessStateType.Done:
                    if(state != "cancelling" &&
                       state != "clean_extruders_failed" &&
                       state != "base state" &&
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

    property variant nozzleCleaningTempList : [
        {label: "pla", temperature : 190},
        {label: "tough", temperature : 190},
        {label: "petg", temperature : 190},
        {label: "abs", temperature : 240},
        {label: "asa", temperature : 240},
        {label: "nylon", temperature : 190},
        {label: "nylon-cf", "temperature": 250},
        {label: "tpu", "temperature": 190}
    ]

    Image {
        id: image
        width: sourceSize.width
        height: sourceSize.height
        anchors.verticalCenterOffset: -20
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/calib_check_nozzles_clean.png"
        opacity: 1.0
    }

    LoadingIcon {
        id: loadingIcon
        anchors.verticalCenterOffset: -30
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.verticalCenter: parent.verticalCenter
        opacity: 0
    }

    Item {
        id: mainItem
        width: 400
        height: 250
        visible: true
        anchors.left: parent.left
        anchors.leftMargin: 420
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -15
        opacity: 1.0

        Text {
            id: title
            width: 350
            text: qsTr("CLEAN EXTRUDER NOZZLES")
            antialiasing: false
            smooth: false
            font.letterSpacing: 3
            wrapMode: Text.WordWrap
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            color: "#e6e6e6"
            font.family: defaultFont.name
            font.pixelSize: 22
            font.weight: Font.Bold
            lineHeight: 1.2
            opacity: 1.0
        }

        Text {
            id: subtitle
            width: 350
            wrapMode: Text.WordWrap
            anchors.top: title.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: 0
            color: "#e6e6e6"
            font.family: defaultFont.name
            font.pixelSize: 18
            font.weight: Font.Light
            text: qsTr("If there is material on the tips of the extruders, use the provided steel brush to clean them in the next steps.")
            lineHeight: 1.2
            opacity: 1.0
        }

        RoundedButton {
            id: actionButton
            label: qsTr("CLEAN EXTRUDERS")
            buttonWidth: 310
            buttonHeight: 50
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: subtitle.bottom
            anchors.topMargin: 25
            opacity: 1.0
        }
    }

    CleanExtruderMaterialSelector {
        id: materialSelector
        visible: false
    }

    CleanExtrudersSequence {
        id: cleanExtruders
        visible: false
    }

    states: [
        State {
            name: "choose_material"

            PropertyChanges {
                target: image
                opacity: 0
            }

            PropertyChanges {
                target: mainItem
                opacity: 0
            }

            PropertyChanges {
                target: materialSelector
                visible: true
            }

            PropertyChanges {
                target: loadingIcon
                opacity: 0
            }
        },

        State {
            name: "loading"
            when: bot.process.type == ProcessType.NozzleCleaningProcess &&
                  (bot.process.stateType == ProcessStateType.Running ||
                   bot.process.stateType == ProcessStateType.CleaningUp)

            PropertyChanges {
                target: loadingIcon
                opacity: 1
            }

            PropertyChanges {
                target: image
                opacity: 0
            }

            PropertyChanges {
                target: mainItem
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: qsTr("LOADING")
                anchors.topMargin: 70
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("Please wait")
            }

            PropertyChanges {
                target: actionButton
                opacity: 0
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }

            PropertyChanges {
                target: cleanExtruders
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
                target: image
                opacity: 0
            }

            PropertyChanges {
                target: mainItem
                opacity: 0
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }

            PropertyChanges {
                target: cleanExtruders
                visible: true
            }

            PropertyChanges {
                target: loadingIcon
                opacity: 0
            }
        },

        State {
            name: "clean_extruders_complete"

            PropertyChanges {
                target: image
                source: "qrc:/img/process_successful.png"
                anchors.leftMargin: 80
                opacity: 1
            }

            PropertyChanges {
                target: mainItem
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: qsTr("PROCESS COMPLETE")
                anchors.topMargin: 40
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("")
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }

            PropertyChanges {
                target: actionButton
                button_text.text: qsTr("DONE")
            }

            PropertyChanges {
                target: loadingIcon
                opacity: 0
            }
        },
        State {
            name: "clean_extruders_failed"
            PropertyChanges {
                target: image
                source: "qrc:/img/error.png"
                opacity: 1
                anchors.leftMargin: 80
            }

            PropertyChanges {
                target: mainItem
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: qsTr("PROCESS FAILED")
                anchors.topMargin: 50
            }

            PropertyChanges {
                target: subtitle
                opacity: 0
            }

            PropertyChanges {
                target: actionButton
                anchors.topMargin: -50
                button_text.text: qsTr("DONE")
                opacity: 1
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }

            PropertyChanges {
                target: loadingIcon
                opacity: 0
            }
        },
        State {
            name: "cancelling"
            PropertyChanges {
                target: image
                opacity: 0
            }

            PropertyChanges {
                target: mainItem
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: qsTr("CANCELLING")
                opacity: 1
                anchors.topMargin: 80
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("Please wait.")
                opacity: 1
            }

            PropertyChanges {
                target: actionButton
                opacity: 0
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }

            PropertyChanges {
                target: loadingIcon
                opacity: 1
            }
        }
    ]

    CustomPopup {
        id: cancelCleanExtrudersPopup
        popupWidth: 720
        popupHeight: 250

        showTwoButtons: true
        left_button_text: qsTr("STOP PROCESS")
        left_button.onClicked: {
            bot.cancel()
            state = "cancelling"
            cancelCleanExtrudersPopup.close()
        }
        right_button_text: qsTr("CONTINUE")
        right_button.onClicked: {
            cancelCleanExtrudersPopup.close()
        }

        ColumnLayout {
            id: columnLayout_clean_extruders_popup
            width: 590
            height: children.height
            spacing: 20
            anchors.top: parent.top
            anchors.topMargin: 165
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: alert_text_clean_extruders_popup
                color: "#cbcbcb"
                text: qsTr("CANCEL CLEAN EXTRUDERS")
                font.letterSpacing: 3
                Layout.alignment: Qt.AlignHCenter
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 20
            }

            Text {
                id: description_text_clean_extruders_popup
                color: "#cbcbcb"
                text: qsTr("Are you sure you want to exit the clean extruders process?")
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                font.family: defaultFont.name
                font.pixelSize: 18
                font.letterSpacing: 1
                lineHeight: 1.3
            }
        }
    }
}
