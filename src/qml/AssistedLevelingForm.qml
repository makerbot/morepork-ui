import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

LoggingItem {
    itemName: "AssistedLeveling"
    id: assistedLevelingPage
    width: 800
    height: 440
    smooth: false
    property alias cancelLeveling: cancel_mouseArea
    property alias continueLeveling: continue_mouseArea
    property alias cancelAssistedLevelingPopup: cancelAssistedLevelingPopup
    property alias startDoneButton: startDoneButton
    property alias acknowledgeLevelButton: acknowledgeLevelButton
    property int currentHES
    property int targetHESUpper
    property int targetHESLower
    signal processDone

    property bool hasFailed: bot.process.errorCode !== 0
    property int currentState: bot.process.stateType
    onCurrentStateChanged: {
        // Conditions to move to appropriate UI states
        if(bot.process.type == ProcessType.AssistedLeveling) {
            switch(currentState) {
                case ProcessStateType.LevelingLeft:
                case ProcessStateType.LevelingRight:
                    state = "leveling"
                    break;
                case ProcessStateType.LevelingComplete:
                    if(state != "leveling_failed" &&
                       state != "cancelling") {
                        if(inFreStep) {
                            state = "leveling_successful"
                        }
                        else {
                            state = "leveling_complete"
                        }
                    }
                    break;
                case ProcessStateType.LevelingFailed:
                    state = "leveling_failed"
                    break;
                case ProcessStateType.Cancelling:
                    state = "cancelling"
                    break;
                default:
                    break;
            }
        }
        else if(bot.process.type == ProcessType.None) {
            if(state == "cancelling") {
                processDone()
            }
        }
    }

    onHasFailedChanged: {
        if(bot.process.type == ProcessType.AssistedLeveling) {
            state = "leveling_failed"
        }
    }

    Image {
        id: header_image
        width: sourceSize.width
        height: sourceSize.height
        anchors.verticalCenterOffset: -40
        anchors.left: parent.left
        anchors.leftMargin: 25
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/sombrero_build_plate.png"
        visible: true

        Item {
            id: mainItem
            width: 400
            height: 250
            visible: true
            anchors.left: parent.right
            anchors.leftMargin: 25
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: title
                width: 360
                text: qsTr("BUILD PLATFORM\nLEVELING")
                font.letterSpacing: 3
                wrapMode: Text.WordWrap
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                color: "#e6e6e6"
                font.family: defaultFont.name
                font.pixelSize: 24
                font.weight: Font.Bold
                lineHeight: 1.3
                visible: true
            }

            Text {
                id: subtitle
                width: 375
                wrapMode: Text.WordWrap
                anchors.top: title.bottom
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.leftMargin: 0
                color: "#e6e6e6"
                font.family: defaultFont.name
                font.pixelSize: 18
                font.weight: Font.Light
                text: qsTr("Assisted leveling will check your build platform and prompt you to make any adjustments.")
                lineHeight: 1.2
                visible: true
            }

            RoundedButton {
                id: startDoneButton
                label: qsTr("START LEVELING")
                buttonWidth: 260
                buttonHeight: 50
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: subtitle.bottom
                anchors.topMargin: 30
                visible: true
            }
        }
    }

    LoadingIcon {
        id: loadingIcon
        anchors.verticalCenterOffset: -40
        anchors.left: parent.left
        anchors.leftMargin: 100
        anchors.verticalCenter: parent.verticalCenter
        loading: visible
        visible: false

        Text {
            id: processText
            width: 325
            text: qsTr("PROCESS")
            anchors.top: parent.top
            anchors.topMargin: 50
            anchors.left: parent.right
            anchors.leftMargin: 75
            wrapMode: Text.WordWrap
            color: "#e6e6e6"
            font.family: defaultFont.name
            font.pixelSize: 22
            font.weight: Font.Bold
            lineHeight: 1.2
            font.letterSpacing: 3
        }

        Text {
            id: processDescriptionText
            width: 350
            wrapMode: Text.WordWrap
            color: "#e6e6e6"
            font.family: defaultFont.name
            font.pixelSize: 18
            font.weight: Font.Light
            text: qsTr("PROCESS DESCRIPTION")
            anchors.top: processText.bottom
            anchors.topMargin: 25
            anchors.left: parent.right
            anchors.leftMargin: 75
            lineHeight: 1.2
        }

        RowLayout {
            id: temperatureDisplay
            width: children.width
            height: 35
            anchors.left: parent.right
            anchors.leftMargin: 75
            anchors.top: processDescriptionText.bottom
            anchors.topMargin: 25
            spacing: 10
            opacity: 0

            Text {
                id: extruder_A_current_temperature_text
                text: qsTr("%1C").arg(bot.extruderACurrentTemp)
                font.family: defaultFont.name
                color: "#ffffff"
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pixelSize: 20
            }

            Rectangle {
                id: divider_rectangle1
                width: 1
                height: 25
                color: "#ffffff"
            }

            Text {
                id: extruder_A_target_temperature_text
                text: qsTr("50C")
                font.family: defaultFont.name
                color: "#ffffff"
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pixelSize: 20
            }

            Rectangle {
                width: 10
                color: "#000000"
            }

            Text {
                id: extruder_B_current_temperature_text
                text: qsTr("%1C").arg(bot.extruderBCurrentTemp)
                font.family: defaultFont.name
                color: "#ffffff"
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pixelSize: 20
            }

            Rectangle {
                id: divider_rectangle2
                width: 1
                height: 25
                color: "#ffffff"
            }

            Text {
                id: extruder_B_target_temperature_text
                text: qsTr("50C")
                font.family: defaultFont.name
                color: "#ffffff"
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pixelSize: 20
            }
        }
    }

    Image {
        id: levelingDirections
        width: sourceSize.width
        height: sourceSize.height
        visible: false
        anchors.verticalCenterOffset: -50
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: leveling_instruction
            text: qsTr("Text")
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 120
            lineHeight: 1.3
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#ffffff"
            font.family: defaultFont.name
            font.pixelSize: 18
            font.weight: Font.Light
        }

        Image {
            id: level
            width: 1600
            height: 104
            anchors.bottom: acknowledgeLevelButton.top
            anchors.bottomMargin: 35
            visible: false
            smooth: false
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 0
        }

        Image {
            id: range
            visible: false
            width: sourceSize.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: level.verticalCenter
            smooth: false
            source: "qrc:/img/build_plate_level_range.png"
        }

        Item {
            id: rangeIndicator
            width: 800
            height: 50
            anchors.bottom: acknowledgeLevelButton.top
            anchors.bottomMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            visible: false

            Text {
                id: low
                color: "#ffffff"
                text: qsTr("TOO CLOSE")
                anchors.horizontalCenterOffset: -250
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pixelSize: 18
                font.weight: Font.Bold
                font.family: defaultFont.name
            }

            Text {
                id: ok
                color: "#ffffff"
                text: qsTr("LEVEL")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pixelSize: 18
                font.weight: Font.Bold
                font.family: defaultFont.name
            }

            Text {
                id: high
                color: "#ffffff"
                text: qsTr("TOO FAR")
                anchors.horizontalCenterOffset: 250
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pixelSize: 18
                font.weight: Font.Bold
                font.family: defaultFont.name
            }
        }

        RoundedButton {
            id: acknowledgeLevelButton
            anchors.top: parent.bottom
            anchors.topMargin: 100
            anchors.horizontalCenter: parent.horizontalCenter
            buttonWidth: 180
            buttonHeight: 45
            label: qsTr("NEXT STEP")
            visible: false
        }
    }
    states: [
        State {
            name: "buildplate_instructions"
            when: bot.process.type == ProcessType.AssistedLeveling &&
                  bot.process.stateType == ProcessStateType.BuildPlateInstructions

            PropertyChanges {
                target: header_image
                anchors.leftMargin: 0
                source: "qrc:/img/remove_build_plate.png"
                visible: true
            }

            PropertyChanges {
                target: loadingIcon
                visible: false
            }

            PropertyChanges {
                target: title
                text: qsTr("OPEN DOOR AND\nREMOVE BUILD PLATE")
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("The extruders need to hit precise points under the build plate.")
            }

            PropertyChanges {
                target: startDoneButton
                buttonWidth: 120
                label: qsTr("NEXT")
                disable_button: false
                opacity: 1
            }

            PropertyChanges {
                target: levelingDirections
                visible: false
            }
        },

        State {
            name: "checking_level"
            when: bot.process.type == ProcessType.AssistedLeveling &&
                  (bot.process.stateType == ProcessStateType.Loading ||
                   bot.process.stateType == ProcessStateType.CheckingLevelness ||
                   bot.process.stateType == ProcessStateType.CheckLeftLevel ||
                   bot.process.stateType == ProcessStateType.CheckRightLevel ||
                   bot.process.stateType == ProcessStateType.Running ||
                   (bot.process.stateType == ProcessStateType.CleaningUp &&
                    state != "cancelling"))

            PropertyChanges {
                target: header_image
                visible: false
            }

            PropertyChanges {
                target: loadingIcon
                visible: true
            }

            PropertyChanges {
                target: levelingDirections
                visible: false
            }

            PropertyChanges {
                target: processText
                text: {
                    switch(bot.process.stateType) {
                    case ProcessStateType.CheckLeftLevel:
                        qsTr("MOVING TO THE\nLEFT LEVELING POINT")
                        break;
                    case ProcessStateType.CheckRightLevel:
                        qsTr("MOVING TO THE\nRIGHT LEVELING POINT")
                        break;
                    default:
                        if(bot.process.stepStr == "cooling") {
                            qsTr("COOLING EXTRUDER\nNOZZLES")
                        }
                        else {
                            qsTr("CHECKING\nLEVELNESS")
                        }
                        break;
                    }
                }
            }

            PropertyChanges {
                target: processDescriptionText
                text: {
                    switch(bot.process.stateType) {
                    case ProcessStateType.CheckLeftLevel:
                    case ProcessStateType.CheckRightLevel:
                        qsTr("The system is moving into position.")
                        break;
                    default:
                        if(bot.process.stepStr == "cooling") {
                            qsTr("Leveling will continue after the nozzles cool down")
                        }
                        else {
                            qsTr("The extruders are checking the levelness of the build platform.")
                        }
                        break;
                    }
                }
            }

            PropertyChanges {
                target: temperatureDisplay
                opacity: {
                    bot.process.stepStr == "cooling" ?
                             1 : 0
                }
            }
        },

        State {
            name: "leveling_instructions"
            when: bot.process.type == ProcessType.AssistedLeveling &&
                  bot.process.stateType == ProcessStateType.LevelingInstructions

            PropertyChanges {
                target: header_image
                visible: false
            }

            PropertyChanges {
                target: levelingDirections
                source: "qrc:/img/assisted_level_instructions.png"
                anchors.verticalCenterOffset: -50
                visible: true
            }

            PropertyChanges {
                target: leveling_instruction
                text: qsTr("Locate the two leveling hex screws under the part of the build platform.\nPushing up with too much force on the hex key\ncould cause false readings.")
                anchors.bottomMargin: 100
                visible: true
            }

            PropertyChanges {
                target: acknowledgeLevelButton
                anchors.topMargin: -80
                visible: true
            }

            PropertyChanges {
                target: loadingIcon
                visible: false
            }

            PropertyChanges {
                target: rangeIndicator
                visible: false
            }
        },

        State {
            name: "leveling"
            // To get into this UI state, the user has to
            // press the 'acknowledgeLevelButton' while in
            // the 'unlock_knob' state. The behavior is
            // defined in the onClicked action of the button.

            PropertyChanges {
                target: header_image
                visible: false
            }

            PropertyChanges {
                target: loadingIcon
                visible: false
            }

            PropertyChanges {
                target: levelingDirections
                anchors.verticalCenterOffset: -50
                source: {
                    if(currentHES >= targetHESLower && currentHES <= targetHESUpper) {
                        "qrc:/img/build_plate_leveled.png"
                    }
                    else {
                        switch(bot.process.stateType) {
                        case ProcessStateType.LevelingLeft:
                            if(currentHES < targetHESLower) {
                                "qrc:/img/build_plate_left_adjust_tighten.png"
                            }
                            else if(currentHES > targetHESUpper) {
                                "qrc:/img/build_plate_left_adjust_loosen.png"
                            }
                            break;
                        case ProcessStateType.LevelingRight:
                            if(currentHES < targetHESLower) {
                                "qrc:/img/build_plate_right_adjust_tighten.png"
                            }
                            else if(currentHES > targetHESUpper) {
                                "qrc:/img/build_plate_right_adjust_loosen.png"
                            }
                            break;
                        }
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: leveling_instruction
                text: {
                    switch(bot.process.stateType) {
                    case ProcessStateType.LevelingLeft:
                        qsTr("Adjust front left height")
                        break;
                    case ProcessStateType.LevelingRight:
                        qsTr("Adjust front right height")
                        break;
                    default:
                        ""
                        break;
                    }
                }
                anchors.bottomMargin: 250
                visible: true
            }

            PropertyChanges {
                target: level
                visible: true
                anchors.horizontalCenterOffset:
                    (targetHESLower + targetHESUpper)*0.5 - currentHES
                source: {
                    if(currentHES <= targetHESUpper && currentHES >= targetHESLower) {
                        "qrc:/img/build_plate_level.png"
                    }
                    else {
                        "qrc:/img/build_plate_not_level.png"
                    }
                }
            }

            PropertyChanges {
                target: acknowledgeLevelButton
                anchors.topMargin: -80
                visible: true
            }

            PropertyChanges {
                target: rangeIndicator
                visible: true
            }

            PropertyChanges {
                target: low
                opacity: {
                    (currentHES >= targetHESLower &&
                     ok.opacity != 1) ?
                        1 : 0.2
                }
            }

            PropertyChanges {
                target: ok
                opacity: (currentHES >= targetHESLower &&
                          currentHES <= targetHESUpper) ? 1 : 0.2
            }

            PropertyChanges {
                target: high
                opacity: {
                    (currentHES <= targetHESUpper &&
                     ok.opacity != 1) ?
                        1 : 0.2
                }
            }

            PropertyChanges {
                target: range
                visible: true
            }
        },

        State {
            name: "leveling_complete"
            // To get into this UI state, the switch case
            // at the top of file is used instead of the
            // usual 'when' condition, as we need the UI to
            // be held at this state and move forward only
            // after user input.

            PropertyChanges {
                target: header_image
                visible: true
                anchors.leftMargin: 0
                source: "qrc:/img/insert_build_plate.png"
            }

            PropertyChanges {
                target: loadingIcon
                visible: false
            }

            PropertyChanges {
                target: title
                width: 390
                text: qsTr("INSERT BUILD PLATE\nAND CLOSE DOOR")
                anchors.topMargin: 0
                font.pixelSize: 25
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("To finish leveling please insert the build\nplate back into the printer and close the\nbuild chamber door.")
            }

            PropertyChanges {
                target: startDoneButton
                buttonWidth: 180
                label: qsTr("CONTINUE")
                opacity: 1
                disable_button: false
            }

            PropertyChanges {
                target: levelingDirections
                visible: false
            }
        },

        State {
            name: "leveling_successful"
            // To get into this UI state, the switch case
            // at the top of file is used instead of the
            // usual 'when' condition, as we need the UI to
            // be held at this state and move forward only
            // after user input.

            PropertyChanges {
                target: header_image
                visible: true
                anchors.leftMargin: 0
                source: "qrc:/img/sombrero_welcome.png"
            }

            PropertyChanges {
                target: loadingIcon
                visible: false
            }

            PropertyChanges {
                target: title
                width: 390
                text: qsTr("BUILD PLATFORM\nIS LEVEL")
                anchors.topMargin: 0
                font.pixelSize: 25
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("Sensors indicate the build platform\nis level.")
            }

            PropertyChanges {
                target: startDoneButton
                buttonWidth: 120
                label: inFreStep ? qsTr("DONE") : qsTr("BEGIN Z CALIBRATION")
                opacity: 1
                disable_button: false
            }

            PropertyChanges {
                target: levelingDirections
                visible: false
            }
        },

        State {
            name: "leveling_failed"
            PropertyChanges {
                target: header_image
                anchors.leftMargin: 80
                source: "qrc:/img/error.png"
                visible: true
            }

            PropertyChanges {
                target: loadingIcon
                visible: false
            }

            PropertyChanges {
                target: title
                width: 390
                text: qsTr("ASSISTED LEVELING FAILED")
                font.pixelSize: 25
                anchors.topMargin: 55
            }

            PropertyChanges {
                target: subtitle
                text: ""
            }

            PropertyChanges {
                target: startDoneButton
                disable_button: false
                buttonWidth: 120
                anchors.topMargin: "-10"
                label: qsTr("DONE")
                opacity: 1
            }

            PropertyChanges {
                target: levelingDirections
                visible: false
            }

            PropertyChanges {
                target: mainItem
                anchors.leftMargin: 40
            }
        },
        State {
            name: "cancelling"
            PropertyChanges {
                target: header_image
                anchors.leftMargin: 80
                source: "qrc:/img/error.png"
                visible: false
            }

            PropertyChanges {
                target: loadingIcon
                visible: true
            }

            PropertyChanges {
                target: processText
                text: qsTr("CANCELLING LEVELING")
            }

            PropertyChanges {
                target: subtitle
                text: ""
            }

            PropertyChanges {
                target: levelingDirections
                visible: false
            }

            PropertyChanges {
                target: processDescriptionText
                text: qsTr("Please wait")
            }
        }
    ]

    Popup {
        id: cancelAssistedLevelingPopup
        width: 800
        height: 480
        modal: true
        dim: false
        focus: true
        parent: overlay
        closePolicy: Popup.CloseOnPressOutside
        background: Rectangle {
            id: popupBackgroundDim
            color: "#000000"
            rotation: rootItem.rotation == 180 ? 180 : 0
            opacity: 0.5
            anchors.fill: parent
        }
        enter: Transition {
                NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.InQuad; from: 0.0; to: 1.0 }
        }
        exit: Transition {
                NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.InQuad; from: 1.0; to: 0.0 }
        }

        Rectangle {
            id: basePopupItem
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
                id: horizontal_divider
                width: 720
                height: 2
                color: "#ffffff"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 72
            }

            Rectangle {
                id: vertical_divider
                x: 359
                y: 328
                width: 2
                height: 72
                color: "#ffffff"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Item {
                id: buttonBar
                width: 720
                height: 72
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                Rectangle {
                    id: cancel_rectangle
                    x: 0
                    y: 0
                    width: 360
                    height: 72
                    color: "#00000000"
                    radius: 10

                    Text {
                        id: cancel_leveling_text
                        color: "#ffffff"
                        text: qsTr("CANCEL LEVELING")
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
                        id: cancel_mouseArea
                        anchors.fill: parent
                        onPressed: {
                            cancel_leveling_text.color = "#000000"
                            cancel_rectangle.color = "#ffffff"
                        }
                        onReleased: {
                            cancel_leveling_text.color = "#ffffff"
                            cancel_rectangle.color = "#00000000"
                        }
                    }
                }

                Rectangle {
                    id: continue_rectangle
                    x: 360
                    y: 0
                    width: 360
                    height: 72
                    color: "#00000000"
                    radius: 10

                    Text {
                        id: continue_leveling_text
                        color: "#ffffff"
                        text: qsTr("CONTINUE LEVELING")
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: defaultFont.name
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MouseArea {
                        id: continue_mouseArea
                        anchors.fill: parent
                        onPressed: {
                            continue_leveling_text.color = "#000000"
                            continue_rectangle.color = "#ffffff"
                        }
                        onReleased: {
                            continue_leveling_text.color = "#ffffff"
                            continue_rectangle.color = "#00000000"
                        }
                    }
                }
            }

            ColumnLayout {
                id: columnLayout
                width: 590
                height: 100
                anchors.top: parent.top
                anchors.topMargin: 25
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: cancel_text
                    color: "#cbcbcb"
                    text: qsTr("CANCEL ASSISTED LEVELING")
                    font.letterSpacing: 3
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: defaultFont.name
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Text {
                    id: cancel_description_text
                    color: "#cbcbcb"
                    text: qsTr("Are you sure you want to cancel the leveling process?")
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
