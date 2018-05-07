import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    id: assistedLevelingPage
    width: 800
    height: 440
    smooth: false
    property alias startDoneButton: startDoneButton
    property alias acknowledgeLevelButton: acknowledgeLevelButton
    property int currentHES
    property int targetHESUpper
    property int targetHESLower
    signal processDone

    property int currentState: currentStep
    onCurrentStateChanged: {
        // Conditions to move to appropriate UI states
        if(currentProcess == ProcessType.AssistedLeveling) {
            switch(currentState) {
                case ProcessStateType.LevelingLeft:
                case ProcessStateType.LevelingRight:
                    state = "unlock_knob"
                    break;
                case ProcessStateType.LevelingComplete:
                    state = "leveling_complete"
                    break;
                default:
                    break;
            }
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
                width: 252
                text: "LEVEL         BUILD PLATE"
                font.letterSpacing: 3
                wrapMode: Text.WordWrap
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                color: "#e6e6e6"
                font.family: "Antennae"
                font.pixelSize: 30
                font.weight: Font.Bold
                lineHeight: 1.3
                visible: true
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
                font.family: "Antennae"
                font.pixelSize: 18
                font.weight: Font.Light
                text: "Assisted leveling will check your build plate and prompt you to make any adjustments"
                lineHeight: 1.2
                visible: true
            }

            RoundedButton {
                id: startDoneButton
                label: "BEGIN LEVELING"
                buttonWidth: 260
                buttonHeight: 50
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: subtitle.bottom
                anchors.topMargin: 20
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
            width: 275
            text: "DEFAULT"
            wrapMode: Text.WordWrap
            anchors.left: parent.right
            anchors.leftMargin: 75
            anchors.verticalCenter: parent.verticalCenter
            color: "#e6e6e6"
            font.family: "Antennae"
            font.pixelSize: 22
            font.weight: Font.Bold
            lineHeight: 1.3
            font.letterSpacing: 3
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
            text: "Text"
            anchors.top: parent.bottom
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#e6e6e6"
            font.family: "Antennae"
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
                text: "TOO CLOSE"
                anchors.horizontalCenterOffset: -250
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pixelSize: 18
                font.weight: Font.Bold
                font.family: "Antennae"
            }

            Text {
                id: ok
                color: "#ffffff"
                text: "LEVEL"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pixelSize: 18
                font.weight: Font.Bold
                font.family: "Antennae"
            }

            Text {
                id: high
                color: "#ffffff"
                text: "TOO FAR"
                anchors.horizontalCenterOffset: 250
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.pixelSize: 18
                font.weight: Font.Bold
                font.family: "Antennae"
            }
        }

        RoundedButton {
            id: acknowledgeLevelButton
            anchors.top: parent.bottom
            anchors.topMargin: 100
            anchors.horizontalCenter: parent.horizontalCenter
            buttonWidth: 180
            buttonHeight: 45
            label: "NEXT STEP"
            visible: false
        }

    }
    states: [
        State {
            name: "buildplate_instructions"
            when: currentProcess == ProcessType.AssistedLeveling &&
                  currentStep == ProcessStateType.BuildPlateInstructions

            PropertyChanges {
                target: header_image
                source: "qrc:/img/build_plate_open_door.png"
                visible: true
            }

            PropertyChanges {
                target: loadingIcon
                visible: false
            }

            PropertyChanges {
                target: title
                text: "OPEN DOOR"
            }

            PropertyChanges {
                target: subtitle
                text: "In order for your device to correctly level the build plate you must open the door."
            }

            PropertyChanges {
                target: startDoneButton
                disable_button: true
                opacity: 0
            }

            PropertyChanges {
                target: mainItem
                anchors.verticalCenterOffset: 30
                anchors.leftMargin: -100
            }

            PropertyChanges {
                target: levelingDirections
                visible: false
            }
        },

        State {
            name: "loading_state"
            when: currentProcess == ProcessType.AssistedLeveling &&
                  (currentStep == ProcessStateType.Loading ||
                   currentStep == ProcessStateType.CheckFirstPoint ||
                   currentStep == ProcessStateType.CheckLeftLevel ||
                   currentStep == ProcessStateType.CheckRightLevel)

            PropertyChanges {
                target: header_image
                visible: false
            }

            PropertyChanges {
                target: loadingIcon
                visible: true
            }

            PropertyChanges {
                target: processText
                text: {
                    switch(currentStep) {
                    case ProcessStateType.Loading:
                        "HOMING TO CENTER POINT"
                        break;
                    case ProcessStateType.CheckFirstPoint:
                        "CHECKING THE CENTER POINT"
                        break;
                    case ProcessStateType.CheckLeftLevel:
                        "CHECKING THE LEFT POINT"
                        break;
                    case ProcessStateType.CheckRightLevel:
                        "CHECKING THE RIGHT POINT"
                        break;
                    default:
                        "DEFAULT TEXT"
                        break;
                    }
                }
            }

            PropertyChanges {
                target: levelingDirections
                visible: false
            }
        },

        State {
            name: "unlock_knob"
            // To get into this UI state, the switch case
            // at the top of file is used instead of the
            // usual 'when' condition, as we need the UI to
            // be held at this state and move forward only
            // after user input.

            PropertyChanges {
                target: header_image
                visible: false
            }

            PropertyChanges {
                target: levelingDirections
                anchors.verticalCenterOffset: -100
                source: {
                    switch(currentStep) {
                    case ProcessStateType.LevelingLeft:
                        "qrc:/img/build_plate_left_lock_unlock.png"
                        break;
                    case ProcessStateType.LevelingRight:
                        "qrc:/img/build_plate_right_lock_unlock.png"
                        break;
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: leveling_instruction
                text: {
                    switch(currentStep) {
                    case ProcessStateType.LevelingLeft:
                        "Loosen front left lock."
                        break;
                    case ProcessStateType.LevelingRight:
                        "Loosen front right lock."
                        break;
                    }
                }
                anchors.topMargin: 35
                visible: true
            }

            PropertyChanges {
                target: acknowledgeLevelButton
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
                anchors.verticalCenterOffset: -140
                source: {
                    if(currentHES >= targetHESLower && currentHES <= targetHESUpper) {
                        "qrc:/img/build_plate_leveled.png"
                    }
                    else{
                        switch(currentStep) {
                        case ProcessStateType.LevelingLeft:
                            "qrc:/img/build_plate_left_adjust.png"
                            break;
                        case ProcessStateType.LevelingRight:
                            "qrc:/img/build_plate_right_adjust.png"
                        }
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: leveling_instruction
                text: {
                    if(currentHES < targetHESLower) {
                        "Twist clockwise to bring the build plate back to leveled range"
                    }
                    else if(currentHES > targetHESUpper) {
                        "Twist counter clockwise to bring the build plate back to leveled range "
                    }
                    else if((currentHES < targetHESUpper && currentHES > targetHESLower)) {
                        ""
                    }
                }
                anchors.topMargin: 10
                visible: true
            }

            PropertyChanges {
                target: level
                visible: true
                anchors.horizontalCenterOffset:
                    currentHES - (targetHESLower + targetHESUpper)/2
                source:
                    if(currentHES <= targetHESUpper && currentHES >= targetHESLower) {
                        "qrc:/img/build_plate_level.png"
                    }
                    else {
                        "qrc:/img/build_plate_not_level.png"
                    }
            }

            PropertyChanges {
                target: acknowledgeLevelButton
                anchors.topMargin: 160
                visible: true
            }

            PropertyChanges {
                target: rangeIndicator
                visible: true
            }

            PropertyChanges {
                target: low
                opacity: currentHES <= targetHESLower ? 1 : 0.2
            }

            PropertyChanges {
                target: ok
                opacity: (currentHES >= targetHESLower &&
                          currentHES <= targetHESUpper) ? 1 : 0.2
            }

            PropertyChanges {
                target: high
                opacity: currentHES >= targetHESUpper ? 1 : 0.2
            }

            PropertyChanges {
                target: range
                visible: true
            }
        },

        State {
            name: "lock_knob"
            // To get into this UI state, the user has to
            // press the 'acknowledgeLevelButton' while in
            // the 'leveling' state. The behavior is defined
            // in the onClicked action of the button.

            PropertyChanges {
                target: header_image
                visible: false
            }

            PropertyChanges {
                target: levelingDirections
                anchors.verticalCenterOffset: -100
                source: {
                    switch(currentStep) {
                    case ProcessStateType.LevelingLeft:
                        "qrc:/img/build_plate_left_lock_unlock.png"
                        break;
                    case ProcessStateType.LevelingRight:
                        "qrc:/img/build_plate_right_lock_unlock.png"
                        break;
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: leveling_instruction
                text: {
                    switch(currentStep) {
                    case ProcessStateType.LevelingLeft:
                        "Tighten front left lock."
                        break;
                    case ProcessStateType.LevelingRight:
                        "Tighten front right lock."
                        break;
                    }
                }
                anchors.topMargin: 35
                visible: true

            }

            PropertyChanges {
                target: acknowledgeLevelButton
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
            name: "leveling_complete"
            // To get into this UI state, the switch case
            // at the top of file is used instead of the
            // usual 'when' condition, as we need the UI to
            // be held at this state and move forward only
            // after user input.

            PropertyChanges {
                target: header_image
                visible: true
                anchors.leftMargin: 60
                source: "qrc:/img/process_successful.png"
            }

            PropertyChanges {
                target: loadingIcon
                visible: false
            }

            PropertyChanges {
                target: title
                width: 390
                text: "ASSISTED LEVELING COMPLETE"
                anchors.topMargin: 55
                font.pixelSize: 25
            }

            PropertyChanges {
                target: subtitle
                text: ""
            }

            PropertyChanges {
                target: startDoneButton
                anchors.topMargin: -10
                buttonWidth: 100
                label: "DONE"
                opacity: 1
                disable_button: false
            }

            PropertyChanges {
                target: levelingDirections
                visible: false
            }
        }
    ]
}
