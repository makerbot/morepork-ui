import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import MachineTypeEnum 1.0

LoggingItem {

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    itemName: "AssistedLeveling"
    id: assistedLevelingPage
    width: 800
    height: 408
    smooth: false
    property alias cancelAssistedLevelingPopup: cancelAssistedLevelingPopup
    property alias contentLeftSide: contentLeftSide
    property alias contentRightSide: contentRightSide
    property alias nextButton: leveler.nextButton
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

    ContentLeftSide {
        id: contentLeftSide
        visible: true
        image {
            source: ("qrc:/img/%1.png").arg(getImageForPrinter("assisted_level"))
            visible: true
        }
        loadingIcon {
            visible: false
        }
    }

    ContentRightSide {
        id: contentRightSide
        visible: true
        textHeader {
            text: qsTr("ASSISTED LEVELING")
            visible: true
        }
        textBody {
            text: qsTr("Assisted leveling will check your build platform and prompt you to make any adjustments.")
            visible: true
        }
        textBody1 {
            text: {
                qsTr("Tools Required: %1mm Hex Key<br>(included)").arg(
                      bot.machineType == MachineType.Magma ? "3" : "2.5")
            }
            visible: true
        }
        buttonPrimary {
            text: qsTr("START LEVELING")
            visible: true
        }
        temperatureStatus {
            visible: false
        }
    }

    Item {
        id: leveler
        width: 800
        height: 408

        property alias image: image
        property alias levelerScale: levelerScale
        property alias instructionsTitle: instructionsTitle
        property alias instructionsBody: instructionsBody
        property alias nextButton: nextButton
        anchors.bottom: parent.bottom

        visible: false

        Image {
            id: image
            width: sourceSize.width
            height: sourceSize.height
            visible: false
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Item {
            id: levelerScale
            width: parent.width
            height: 100
            anchors.top: image.bottom
            anchors.horizontalCenter: image.horizontalCenter

            property alias indicatorNeedle: indicatorNeedle
            property alias levelingGoodCheckmark: levelingGoodCheckmark

            Image {
                id: baseScale
                height: sourceSize.height
                width: sourceSize.width
                source: ("qrc:/img/%1.png").arg(getImageForPrinter("leveler_scale"))
            }

            Image {
                id: indicatorNeedle
                height: sourceSize.height
                width: sourceSize.width
                anchors.horizontalCenter: baseScale.horizontalCenter
                source: "qrc:/img/leveler_indicator_orange.png"
            }

            Image {
                id: levelingGoodCheckmark
                height: sourceSize.height
                width: sourceSize.width
                anchors.horizontalCenter: baseScale.horizontalCenter
                anchors.verticalCenter: baseScale.verticalCenter
                source: "qrc:/img/leveling_good.png"
            }
        }

        ColumnLayout {
            spacing: 16
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 26
            anchors.horizontalCenter: image.horizontalCenter

            TextHeadline {
                id: instructionsTitle
                Layout.preferredWidth: 444
            }

            RowLayout {
                spacing: 40
                TextBody {
                    id: instructionsBody
                    Layout.preferredWidth: 444
                }

                ButtonRectanglePrimary {
                    id: nextButton
                    Layout.preferredWidth: 236
                    text: qsTr("NEXT")
                }
            }
        }
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
                target: contentRightSide.textBody1
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.temperatureStatus
                visible: false
            }

            PropertyChanges {
                target: leveler
                visible: false
            }
        },

        State {
            name: "remove_build_plate"
            when: bot.process.type == ProcessType.AssistedLeveling &&
                  bot.process.stateType == ProcessStateType.BuildPlateInstructions

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
                source: ("qrc:/img/%1.png").arg(getImageForPrinter("remove_build_plate"))
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.loadingIcon
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("OPEN DOOR AND REMOVE BUILD PLATE")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("The extruders need to hit precise points under the build plate.")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody1
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                text: qsTr("NEXT")
                visible: true
            }

            PropertyChanges {
                target: leveler
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
                text: {
                    switch(bot.process.stateType) {
                    case ProcessStateType.CheckLeftLevel:
                        qsTr("MOVING TO THE LEFT LEVELING POINT")
                        break;
                    case ProcessStateType.CheckRightLevel:
                        qsTr("MOVING TO THE RIGHT LEVELING POINT")
                        break;
                    default:
                        if(bot.process.stepStr == "cooling") {
                            qsTr("COOLING EXTRUDER NOZZLES")
                        }
                        else {
                            qsTr("CHECKING LEVELNESS")
                        }
                        break;
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: {
                    switch(bot.process.stateType) {
                    case ProcessStateType.CheckLeftLevel:
                    case ProcessStateType.CheckRightLevel:
                        qsTr("The system is moving into position.")
                        break;
                    default:
                        if(bot.process.stepStr == "cooling") {
                            qsTr("Leveling will continue after the nozzles cool down.")
                        }
                        else {
                            qsTr("The extruders are checking the levelness of the build platform.")
                        }
                        break;
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody1
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.temperatureStatus
                modelExtruder.customTargetTemperature: 50
                supportExtruder.customTargetTemperature: 50
                visible: bot.process.stepStr == "cooling"
            }

            PropertyChanges {
                target: leveler
                visible: false
            }
        },

        State {
            name: "locate_screws"
            when: bot.process.type == ProcessType.AssistedLeveling &&
                  bot.process.stateType == ProcessStateType.LevelingInstructions

            PropertyChanges {
                target: contentLeftSide
                visible: false
            }

            PropertyChanges {
                target: contentRightSide
                visible: false
            }

            PropertyChanges {
                target: leveler
                visible: true
            }

            PropertyChanges {
                target: leveler.image
                source: ("qrc:/img/%1.png").arg(getImageForPrinter("locate_screws"))
                visible: true
            }

            PropertyChanges {
                target: leveler.levelerScale
                visible: false
            }

            PropertyChanges {
                target: leveler.instructionsTitle
                text: qsTr("LOCATE SCREWS HIGHLIGHTED IN WHITE")
                visible: true
            }

            PropertyChanges {
                target: leveler.instructionsBody
                text: qsTr("Locate the two leveling hex screws under the part of the build platform. Pushing up with too much force on the hex key could cause false readings.")
                visible: true
            }
        },

        State {
            name: "leveling"
            // To get into this UI state, the user has to
            // press the 'acknowledgeLevelButton' while in
            // the 'unlock_knob' state. The behavior is
            // defined in the onClicked action of the button.

            PropertyChanges {
                target: contentLeftSide
                visible: false
            }

            PropertyChanges {
                target: contentRightSide
                visible: false
            }

            PropertyChanges {
                target: leveler
                visible: true
            }

            PropertyChanges {
                target: leveler.image
                source: {
                    if(currentHES >= targetHESLower && currentHES <= targetHESUpper) {
                        ("qrc:/img/%1.png").arg(getImageForPrinter("adjust_done"))
                    } else if(currentHES < targetHESLower) {
                        switch(bot.process.stateType) {
                        case ProcessStateType.LevelingLeft:
                            ("qrc:/img/%1.png").arg(getImageForPrinter("adjust_left_to_move_up_plate"))
                            break;
                        case ProcessStateType.LevelingRight:
                            ("qrc:/img/%1.png").arg(getImageForPrinter("adjust_right_to_move_up_plate"))
                            break;
                        }
                    } else if(currentHES > targetHESUpper) {
                        switch(bot.process.stateType) {
                        case ProcessStateType.LevelingLeft:
                            ("qrc:/img/%1.png").arg(getImageForPrinter("adjust_left_to_move_down_plate"))
                            break;
                        case ProcessStateType.LevelingRight:
                            ("qrc:/img/%1.png").arg(getImageForPrinter("adjust_right_to_move_down_plate"))
                            break;
                        }
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: leveler.levelerScale
                visible: true
            }

            PropertyChanges {
                target: leveler.levelerScale.indicatorNeedle
                anchors.horizontalCenterOffset:
                    (targetHESLower + targetHESUpper)*0.5 - currentHES
                source: {
                    if(currentHES <= targetHESUpper && currentHES >= targetHESLower) {
                        "qrc:/img/leveler_indicator_blue.png"
                    }
                    else {
                        "qrc:/img/leveler_indicator_orange.png"
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: leveler.levelerScale.levelingGoodCheckmark
                visible: currentHES <= targetHESUpper && currentHES >= targetHESLower
            }

            PropertyChanges {
                target: leveler.instructionsBody
                text: {
                    if(currentHES >= targetHESLower && currentHES <= targetHESUpper) {
                        switch(bot.process.stateType) {
                        case ProcessStateType.LevelingLeft:
                            qsTr("Left screw is level.")
                            break;
                        case ProcessStateType.LevelingRight:
                            qsTr("Right screw is level.")
                            break;
                        }
                    } else if(currentHES < targetHESLower) {
                        switch(bot.process.stateType) {
                        case ProcessStateType.LevelingLeft:
                            if(bot.machineType == MachineType.Magma) {
                                qsTr("Turn left screw counter clockwise.")
                            } else {
                                qsTr("Turn left screw clockwise.")
                            }
                            break;
                        case ProcessStateType.LevelingRight:
                            if(bot.machineType == MachineType.Magma) {
                                qsTr("Turn right screw counter clockwise.")
                            } else {
                                qsTr("Turn right screw clockwise.")
                            }
                            break;
                        }
                    } else if(currentHES > targetHESUpper) {
                        switch(bot.process.stateType) {
                        case ProcessStateType.LevelingLeft:
                            if(bot.machineType == MachineType.Magma) {
                                qsTr("Turn left screw clockwise.")
                            } else {
                                 qsTr("Turn left screw counter clockwise.")
                            }
                            break;
                        case ProcessStateType.LevelingRight:
                            if(bot.machineType == MachineType.Magma) {
                                qsTr("Turn right screw clockwise.")
                            } else {
                                 qsTr("Turn right screw counter clockwise.")
                            }
                            break;
                        }
                    } else {
                        emptyString
                    }
                }
                visible: true
            }

            PropertyChanges {
                target: nextButton
                enabled: (currentHES <= targetHESUpper) && (currentHES >= targetHESLower)
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
                anchors.leftMargin: 0
                source: ("qrc:/img/%1.png").arg(getImageForPrinter("insert_build_plate"))
            }

            PropertyChanges {
                target: contentLeftSide.loadingIcon
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("INSERT BUILD PLATE AND CLOSE DOOR")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("To finish leveling please insert the build plate back into the printer and close the build chamber door.")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody1
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                text: qsTr("NEXT")
                visible: true
            }

            PropertyChanges {
                target: leveler
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
                text: qsTr("BUILD PLATFORM IS LEVEL")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("Sensors indicate the build platform is level. The extruders will need to be re-calibrated.")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody1
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                text: inFreStep ? qsTr("DONE") : qsTr("BEGIN Z CALIBRATION")
                visible: true
            }

            PropertyChanges {
                target: leveler
                visible: false
            }
        },

        State {
            name: "leveling_failed"

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
                icon_image: LoadingIcon.Failure
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("ASSISTED LEVELING FAILED")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.textBody1
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                text: qsTr("DONE")
                visible: true
            }

            PropertyChanges {
                target: leveler
                visible: false
            }
        },

        State {
            name: "cancelling"

            PropertyChanges {
                target: contentLeftSide
                visible: true
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.loadingIcon
                icon_image: LoadingIcon.Loading
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.image
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("CANCELLING LEVELING")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("Please wait")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody1
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                visible: false
            }

            PropertyChanges {
                target: leveler
                visible: false
            }
        }
    ]

    CustomPopup {
        popupName: "CancelAssistedLeveling"
        id: cancelAssistedLevelingPopup
        popupWidth: 720
        popupHeight: 250
        showTwoButtons: true
        left_button_text: qsTr("CANCEL LEVELING")
        left_button.onClicked: {
            bot.cancel()
            state = "cancelling"
            cancelAssistedLevelingPopup.close()
        }

        right_button_text: qsTr("CONTINUE LEVELING")
        right_button.onClicked: {
            cancelAssistedLevelingPopup.close()
        }

        ColumnLayout {
            id: columnLayout
            width: 590
            height: 100
            anchors.top: parent.top
            anchors.topMargin: 145
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
