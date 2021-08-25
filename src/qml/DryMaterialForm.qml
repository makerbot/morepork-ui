import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    id: dryMaterialPage
    width: 800
    height: 420
    smooth: false
    antialiasing: false
    property alias cancelDryingCyclePopup: cancelDryingCyclePopup
    property alias actionButton: actionButton
    property alias dryConfirmBuildPlateClearPopup: dryConfirmBuildPlateClearPopup
    property alias left_button: dryConfirmBuildPlateClearPopup.left_button
    property real timeLeftHours: bot.process.timeRemaining/3600
    property int currentStep: bot.process.stateType
    signal processDone
    property bool hasFailed: bot.process.errorCode !== 0
    property bool doChooseMaterial: false
    property bool hasFinished: false

    onCurrentStepChanged: {
        if(bot.process.type == ProcessType.DryingCycleProcess) {
            switch(currentStep) {
                case ProcessStateType.WaitingForSpool:
                    state = "dry_kit_instructions_1"
                    break;
                case ProcessStateType.Loading:
                case ProcessStateType.DryingSpool:
                    doChooseMaterial = false
                    state = "drying_spool"
                    break;
                case ProcessStateType.Done:
                    if(state != "cancelling" &&
                       state != "drying_failed" &&
                       state != "base state") {
                        state = "drying_complete"
                        hasFinished = true
                    }
                    break;
                case ProcessStateType.Cancelling:
                    state = "cancelling"
                    doChooseMaterial = false
                    hasFinished = false
                    break;
            }
        } else if(bot.process.type == ProcessType.None) {
            if(state == "cancelling") {
                processDone()
            }
        }
    }

    onHasFailedChanged: {
        if(bot.process.type == ProcessType.DryingCycleProcess) {
            state = "drying_failed"
            hasFinished = true
        }
    }

    property variant dryingMaterialsListMethod : [
        {label: "pva", temperature : 60, time : 24},
        {label: "nylon || nylon cf || nylon 12 cf || petg", temperature : 60, time : 24},
        {label: "pla || tough", temperature : 45, time : 24}
    ]

    property variant dryingMaterialsListMethodX : [
        {label: "sr30", temperature : 0, time : 0},
        {label: "pva", temperature : 70, time : 24},
        {label: "rapidrinse", temperature : 50, time : 24},
        {label: "nylon || nylon cf || nylon 12 cf", temperature : 70, time : 24},
        {label: "abs || asa || pc-abs || petg", temperature : 60, time : 24},
        {label: "pla || tough", temperature : 45, time : 24}
    ]

    Image {
        id: image
        width: sourceSize.width
        height: sourceSize.height
        anchors.verticalCenterOffset: -20
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/dry_material.png"
        opacity: 1.0
    }

    Item {
        id: mainItem
        width: 400
        height: 250
        visible: true
        anchors.left: parent.left
        anchors.leftMargin: image.width
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -15
        opacity: 1.0

        Text {
            id: title
            width: 350
            text: qsTr("DRY MATERIAL")
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
            text: qsTr("Material extrusion issues may be caused by moisture absorption by the filament.\nThis procedure will allow you to dry\nmaterials for improved print quality,\nusing METHOD’s built-in heaters\nPlease sure the build plate is empty.")
            lineHeight: 1.2
            opacity: 1.0
        }

        RoundedButton {
            id: actionButton
            label: qsTr("START")
            buttonWidth: 310
            buttonHeight: 50
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: subtitle.bottom
            anchors.topMargin: 25
            opacity: 1.0
            button_mouseArea.onClicked: {
                if (bot.process.type != ProcessType.DryingCycleProcess) {
                    if (!hasFinished) {
                        dryConfirmBuildPlateClearPopup.open()
                    } else {
                        processDone()
                        hasFinished = false
                    }
                } else {
                    if(currentStep == ProcessStateType.WaitingForSpool) {
                        if(dryMaterialPage.state == "dry_kit_instructions_1") {
                            dryMaterialPage.state = "dry_kit_instructions_2"
                        }
                        else if(dryMaterialPage.state == "dry_kit_instructions_2") {
                            dryMaterialPage.state = "waiting_for_spool"
                        }
                        else if(dryMaterialPage.state == "waiting_for_spool") {
                            doChooseMaterial = true
                        }
                    } else if(currentStep == ProcessStateType.Done) {
                        processDone()
                        hasFinished = false
                    }
                }
            }
        }

        Text {
            id: under_button_text
            width: 350
            wrapMode: Text.WordWrap
            anchors.top: actionButton.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: 0
            color: "#e6e6e6"
            font.family: defaultFont.name
            font.pixelSize: 18
            font.weight: Font.Light
            text: qsTr("")
            lineHeight: 1.2
            opacity: 1.0
        }

        ColumnLayout {
            id: status
            anchors.top: title.bottom
            anchors.topMargin: 10
            width: children.width
            height: 50
            anchors.left: parent.left
            anchors.leftMargin: 0
            spacing: 10
            opacity: 0

            Text {
                id: time_remaining_text
                text: "999"
                font.family: defaultFont.name
                color: "#ffffff"
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pixelSize: 20
            }

            Text {
                id: chamber_temperature_text
                text: "999"
                font.family: defaultFont.name
                color: "#ffffff"
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pixelSize: 20
            }
        }
    }

    LoadingIcon {
        id: loadingIcon
        anchors.verticalCenterOffset: -30
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.verticalCenter: parent.verticalCenter
        visible: false
    }

    DryMaterialSelector {
        id: materialSelector
        visible: false
    }

    states: [
        State {
            name: "positioning_build_plate"
            when: bot.process.type == ProcessType.DryingCycleProcess &&
                  bot.process.stateType == ProcessStateType.PositioningBuildPlate

            PropertyChanges {
                target: image
                opacity: 0
            }

            PropertyChanges {
                target: title
                text: qsTr("BUILD PLATE MOVING INTO PLACE")
                anchors.topMargin: 40
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("The build plate is moving into position so the material can be placed closer to the heaters.")
            }

            PropertyChanges {
                target: actionButton
                opacity: 0
            }

            PropertyChanges {
                target: loadingIcon
                visible: true
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },
        State {
            name: "dry_kit_instructions_1"

            PropertyChanges {
                target: image
                source: "qrc:/img/replace_desiccant.png"
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: qsTr("REPLACE DESICCANT")
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("SPOOL TYPE A\nRemove cap and insert one 70g bag\nRe-attach cap to spool\n\nSPOOL TYPE B\nRemove puck from spool\nRemove cap and insert one 30g bag\nRe-attach cap and puck to spool")
            }

            PropertyChanges {
                target: actionButton
                button_text.text: qsTr("NEXT")
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },
        State {
            name: "dry_kit_instructions_2"

            PropertyChanges {
                target: image
                source: "qrc:/img/spool_bag.png"
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: qsTr("PLACE SPOOL IN BAG")
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("Confirm your re-usable Mylar storage\nbag has no holes.\n\nPlace spool in bag and add additional\nfresh bags of dessicant before sealing.")
            }

            PropertyChanges {
                target: actionButton
                button_text.text: qsTr("NEXT")
            }

            PropertyChanges {
                target: under_button_text
                text: qsTr("For additional mylar bags and desiccant, purchase the MATERIAL DRY KIT at store.makerbot.com")
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },
        State {
            name: "waiting_for_spool"

            PropertyChanges {
                target: image
                source: "qrc:/img/dry_material_spool.png"
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: qsTr("PLACE THE SEALED BAG ON BUILD PLATE")
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("Position the material in the center of the build plate and close the build chamber door.")
            }

            PropertyChanges {
                target: actionButton
                button_text.text: qsTr("SELECT MATERIAL")
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },
        State {
            name: "choose_material"
            when: doChooseMaterial

            PropertyChanges {
                target: image
                opacity: 0
            }

            PropertyChanges {
                target: mainItem
                opacity: 0
            }

            PropertyChanges {
                target: loadingIcon
                visible: false
            }

            PropertyChanges {
                target: materialSelector
                visible: true
            }
        },
        State {
            name: "drying_spool"

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
                text: {
                    if(bot.process.stateType == ProcessStateType.Loading) {
                        qsTr("HEATING CHAMBER")

                    } else if(bot.process.stateType == ProcessStateType.DryingSpool) {
                        qsTr("DRYING MATERIAL")
                    }
                }
                anchors.topMargin: 60
            }

            PropertyChanges {
                target: status
                opacity: 1
            }

            PropertyChanges {
                target: time_remaining_text
                visible: {
                    if(bot.process.stateType == ProcessStateType.Loading) {
                        false

                    } else if(bot.process.stateType == ProcessStateType.DryingSpool) {
                        true
                    }
                }
                text: {
                    (timeLeftHours < 1 ?
                         Math.round(timeLeftHours * 60) + "M " :
                         Math.round(timeLeftHours*10)/10 + "H ") +
                    qsTr("REMAINING")
                }
            }

            PropertyChanges {
                target: chamber_temperature_text
                text: bot.chamberCurrentTemp + "°C" + " | " + bot.chamberTargetTemp + "°C"
            }

            PropertyChanges {
                target: subtitle
                opacity: 0
            }

            PropertyChanges {
                target: actionButton
                opacity: 0
            }

            PropertyChanges {
                target: loadingIcon
                visible: true
                loadingProgress: bot.process.printPercentage
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },
        State {
            name: "drying_complete"

            PropertyChanges {
                target: image
                source: "qrc:/img/process_successful.png"
                anchors.leftMargin: 80
                opacity: 1
            }

            PropertyChanges {
                target: mainItem
                anchors.leftMargin: 420
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: qsTr("DRYING COMPLETE")
                opacity: 1
                anchors.topMargin: 40
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("The material is now dry and ready to use.")
                opacity: 1
            }

            PropertyChanges {
                target: actionButton
                opacity: 1
            }

            PropertyChanges {
                target: loadingIcon
                visible: false
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }

            PropertyChanges {
                target: actionButton
                button_text.text: qsTr("DONE")
            }
        },
        State {
            name: "drying_failed"
            PropertyChanges {
                target: image
                source: "qrc:/img/error.png"
                opacity: 1
                anchors.leftMargin: 80
            }

            PropertyChanges {
                target: mainItem
                opacity: 1
                anchors.leftMargin: 420
            }

            PropertyChanges {
                target: title
                text: qsTr("DRYING FAILED")
                opacity: 1
                anchors.topMargin: 40
            }

            PropertyChanges {
                target: subtitle
                opacity: 0
            }

            PropertyChanges {
                target: actionButton
                anchors.topMargin: -75
                opacity: 1
            }

            PropertyChanges {
                target: loadingIcon
                visible: false
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }

            PropertyChanges {
                target: actionButton
                button_text.text: qsTr("DONE")
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
                anchors.leftMargin: 420
            }

            PropertyChanges {
                target: title
                text: qsTr("CANCELLING")
                opacity: 1
                anchors.topMargin: 40
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
                target: loadingIcon
                loadingProgress: 0
                visible: true
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        }
    ]

    CustomPopup {
        id: cancelDryingCyclePopup
        popupWidth: 720
        popupHeight: 265

        showTwoButtons: true
        left_button_text: qsTr("STOP DRYING")
        left_button.onClicked: {
            bot.cancel()
            state = "cancelling"
            cancelDryingCyclePopup.close()
        }
        right_button_text: qsTr("CONTINUE")
        right_button.onClicked: {
            cancelDryingCyclePopup.close()
        }

        ColumnLayout {
            id: columnLayout_copy_file_popup
            width: 590
            height: children.height
            spacing: 20
            anchors.top: parent.top
            anchors.topMargin: 150
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: alert_text_copy_file_popup
                color: "#cbcbcb"
                text: qsTr("EXIT PROCEDURE")
                font.letterSpacing: 3
                Layout.alignment: Qt.AlignHCenter
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 20
            }

            Text {
                id: description_text_copy_file_popup
                color: "#cbcbcb"
                text: qsTr("Are you sure you want to cancel and exit the procedure?")
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

    CustomPopup {
        id: dryConfirmBuildPlateClearPopup
        popupWidth: 720
        popupHeight: 220

        showTwoButtons: true
        left_button_text: qsTr("CONFIRM")
        left_button.onClicked: {
            bot.buildPlateCleared()
            dryConfirmBuildPlateClearPopup.close()
        }
        right_button_text: qsTr("BACK")
        right_button.onClicked: {
            dryConfirmBuildPlateClearPopup.close()
        }

        ColumnLayout {
            id: columnLayout_clear_build_plate_popup
            width: 590
            height: 100
            anchors.top: parent.top
            anchors.topMargin: 135
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: clear_build_plate_text
                color: "#cbcbcb"
                text: qsTr("CLEAR BUILD PLATE")
                font.letterSpacing: 3
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 20
            }

            Text {
                id: clear_build_plate_desc_text
                color: "#cbcbcb"
                text: qsTr("Check to make sure the printer build plate is empty.")
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                font.family: defaultFont.name
                font.pixelSize: 18
                lineHeight: 1.3
            }
        }
    }
}
