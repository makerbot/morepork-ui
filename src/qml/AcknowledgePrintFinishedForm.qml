import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12
import ProcessStateTypeEnum 1.0

Item {
    id: element
    width: 300
    height: 165

    property bool failureFeedbackSelected: false

    // Defects template dict. that will sent for all feedback. Even success.
    // Ideally we should be building a list of defects and just sending that.
    property var print_defects: {"warping_from_buildplate": false,
                                 "stringiness": false,
                                 "gaps_in_walls": false,
                                 "bad_layer_alignment": false,
                                 "small_feature_defects": false,
                                 "frequent_extruder_jams": false,
                                 "other": false}

    Text {
        id: titleText
        color: "#cbcbcb"
        text: qsTr("DID THE PRINT SUCCEED?")
        anchors.top: parent.top
        anchors.topMargin: 15
        antialiasing: false
        smooth: false
        font.letterSpacing: 3
        font.family: defaultFont.name
        font.weight: Font.Light
        font.pixelSize: 18
    }

    RowLayout {
        id: buttonContainer
        anchors.top: titleText.bottom
        anchors.topMargin: 20
        spacing: 35
        RowLayout {
            id: feedbackButtons
            spacing: 35
            RoundedButton {
                id: failedButton
                buttonWidth: 87
                buttonHeight: 87
                radius: Math.min(buttonHeight, buttonWidth)/2
                forceButtonWidth: true
                button_mouseArea.onClicked: {
                    failureFeedbackSelected = true
                    // Make a deep copy of the print defects dict. template which will
                    // be updated in the print feedback component with the selected
                    // defects.
                    // This is absolutely uneccessary, if only the analytics guys
                    // don't insist on sending the full defects dict. even for print
                    // success feedback.
                    failurePrintFeedback.defects = JSON.parse(JSON.stringify(print_defects))
                }

                Image {
                    id: thumbs_down
                    source: "qrc:/img/print_feedback_thumbs_down.png"
                    sourceSize: Qt.size(source.width, source.height)
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 3
                }

                ColorOverlay {
                    anchors.fill: thumbs_down
                    source: thumbs_down
                    color: failedButton.button_mouseArea.pressed ? "#000000" : "#00000000"
                }
            }

            RoundedButton {
                id: successButton
                buttonWidth: 87
                buttonHeight: 87
                radius: Math.min(buttonHeight, buttonWidth)/2
                forceButtonWidth: true

                button_mouseArea.onClicked: {
                    printFeedbackAcknowledgementPopup.open()
                    printFeedbackAcknowledgementPopup.feedbackGood = true
                    bot.submitPrintFeedback(true, print_defects)
                    acknowledgePrint()
                }

                Image {
                    id: thumbs_up
                    source: "qrc:/img/print_feedback_thumbs_up.png"
                    sourceSize: Qt.size(source.width, source.height)
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -3
                }

                ColorOverlay {
                    anchors.fill: thumbs_up
                    source: thumbs_up
                    color: successButton.button_mouseArea.pressed ? "#000000" : "#00000000"
                }
            }
        }

        RoundedButton {
            id: done_button
            buttonHeight: 50
            label: qsTr("SKIP")
            visible: true
            border.width: 0
            button_mouseArea.onClicked: {
                acknowledgePrint()
            }
        }
    }
    states: [
        State {
            name: "print_successful"
            when: bot.process.stateType == ProcessStateType.Completed &&
                  !bot.process.printFeedbackReported

            PropertyChanges {
                target: buttonContainer
                anchors.top: titleText.bottom
                anchors.topMargin: 20
            }

            PropertyChanges {
                target: done_button
                button_text.text: qsTr("SKIP")
            }
        },
        State {
            name: "print_successful_feedback_reported"
            when: bot.process.stateType == ProcessStateType.Completed &&
                  bot.process.printFeedbackReported
            extend: "print_failed"
        },
        State {
            name: "print_failed"
            when: bot.process.stateType == ProcessStateType.Failed

            PropertyChanges {
                target: done_button
                button_text.text: qsTr("DONE")
                border.width: 2
            }

            PropertyChanges {
                target: titleText
                visible: false
            }

            PropertyChanges {
                target: buttonContainer
                anchors.top: element.top
                anchors.topMargin: 0
            }

            PropertyChanges {
                target: element
                height: 50
            }

            PropertyChanges {
                target: feedbackButtons
                visible: false
            }
        }
    ]
}
