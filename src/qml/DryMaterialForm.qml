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
    property alias buildplateClearedButtonArea: buildplateClearedButtonArea
    property real timeLeftHours: bot.process.timeRemaining/3600
    property int currentStep: bot.process.stateType
    signal processDone
    property bool hasFailed: bot.process.errorCode !== 0

    onCurrentStepChanged: {
        if(bot.process.type == ProcessType.DryingCycleProcess) {
            switch(currentStep) {
                case ProcessStateType.WaitingForSpool:
                    state = "waiting_for_spool"
                    break;
                case ProcessStateType.Loading:
                case ProcessStateType.DryingSpool:
                    state = "drying_spool"
                    break;
                case ProcessStateType.Done:
                    if(state != "cancelling" &&
                       state != "drying_failed" &&
                       state != "base state") {
                        state = "drying_complete"
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
        if(bot.process.type == ProcessType.DryingCycleProcess) {
            state = "drying_failed"
        }
    }

    property variant dryingMaterialsListMethod : [
        {label: "pla", temperature : 45, time : 4},
        {label: "tough", temperature : 45, time : 4},
        {label: "pva", temperature : 45, time : 16},
        {label: "abs/asa/sr30", temperature : 60, time : 4},
        {label: "petg", temperature : 60, time : 2}
    ]

    property variant dryingMaterialsListMethodX : [
        {label: "pla", temperature : 45, time : 4},
        {label: "tough", temperature : 45, time : 4},
        {label: "pva", temperature : 45, time : 16},
        {label: "abs/asa/sr30", temperature : 60, time : 4},
        {label: "petg", temperature : 60, time : 2},
        {label: "nylon", temperature : 80, time : 8}
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
            text: qsTr("If material is printing poorly, this may be due to moisture uptake. Method's built-in heaters can dry the material for improved print quality. Be sure the build plate is empty.")
            lineHeight: 1.2
            opacity: 1.0
        }

        RoundedButton {
            id: actionButton
            label: qsTr("RAISE BUILD PLATE")
            buttonWidth: 310
            buttonHeight: 50
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: subtitle.bottom
            anchors.topMargin: 25
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
            name: "waiting_for_spool"

            PropertyChanges {
                target: image
                source: "qrc:/img/dry_material_spool.png"
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: qsTr("PLACE THE MATERIAL SPOOL ON THE BUILD PLATE")
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("Position the material in the center of the build plate and close the build chamber door.")
            }

            PropertyChanges {
                target: actionButton
                button_text.text: qsTr("CHOOSE MATERIAL")
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },
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
                text: bot.chamberCurrentTemp + "°C"
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
                text: qsTr("STOP DRYING CYCLE")
                font.letterSpacing: 3
                Layout.alignment: Qt.AlignHCenter
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 20
            }

            Text {
                id: description_text_copy_file_popup
                color: "#cbcbcb"
                text: qsTr("Are you sure you want to exit the drying process?\nThe material may still contain some moisture.")
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
        enter: Transition {
                NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.InQuad; from: 0.0; to: 1.0 }
        }
        exit: Transition {
                NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.InQuad; from: 1.0; to: 0.0 }
        }
        onOpened: {
            start_dry_text.color = "#000000"
            start_dry_rectangle.color = "#ffffff"
        }

        Rectangle {
            id: basePopupItem2
            color: "#000000"
            rotation: rootItem.rotation == 180 ? 180 : 0
            width: 720
            height: 220
            radius: 10
            border.width: 2
            border.color: "#ffffff"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                id: horizontal_divider2
                width: 720
                height: 2
                color: "#ffffff"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 72
            }

            Item {
                id: buttonBar1
                width: 720
                height: 72
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                Rectangle {
                    id: start_dry_rectangle
                    x: 0
                    y: 0
                    width: 360
                    height: 72
                    color: "#00000000"
                    radius: 10

                    Text {
                        id: start_dry_text
                        color: "#ffffff"
                        text: qsTr("BUILD PLATE CLEARED")
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: false
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: defaultFont.name
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MouseArea {
                        id: buildplateClearedButtonArea
                        anchors.fill: parent
                        onPressed: {
                            start_dry_text.color = "#000000"
                            start_dry_rectangle.color = "#ffffff"
                        }
                        onReleased: {
                            start_dry_text.color = "#ffffff"
                            start_dry_rectangle.color = "#00000000"
                        }
                        onClicked: {
                            bot.buildPlateCleared()
                            dryConfirmBuildPlateClearPopup.close()
                        }
                    }
                }

                Rectangle {
                    id: cancel_dry_rectangle
                    x: 360
                    y: 0
                    width: 360
                    height: 72
                    color: "#00000000"
                    radius: 10

                    Text {
                        id: cancel_dry_text
                        color: "#ffffff"
                        text: qsTr("CANCEL")
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: defaultFont.name
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MouseArea {
                        id: cancel_dry_mouseArea
                        anchors.fill: parent
                        onPressed: {
                            cancel_dry_text.color = "#000000"
                            cancel_dry_rectangle.color = "#ffffff"
                        }
                        onReleased: {
                            cancel_dry_text.color = "#ffffff"
                            cancel_dry_rectangle.color = "#00000000"
                        }
                        onClicked: {
                            bot.cancel()
                            dryConfirmBuildPlateClearPopup.close()
                        }
                    }
                }
            }

            ColumnLayout {
                id: columnLayout2
                width: 590
                height: 100
                anchors.top: parent.top
                anchors.topMargin: 25
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
                    text: qsTr("Please be sure your build plate is clear.")
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
}
