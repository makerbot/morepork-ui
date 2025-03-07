﻿import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12
import ProcessStateTypeEnum 1.0

LoggingItem {
    itemName: "AcknowledgePrintFinished"
    id: acknowledgePrintElement
    width: 400
    height: 165
    property bool failureFeedbackSelected: false

    // Defects template dict. that will sent for all feedback. Even success.
    // Ideally we should be building a list of defects and just sending that.
    property var print_defects_template: {"warping_from_buildplate": false,
                                 "stringiness": false,
                                 "gaps_in_walls": false,
                                 "bad_layer_alignment": false,
                                 "small_feature_defects": false,
                                 "frequent_extruder_jams": false,
                                 "other": false,
                                 "non_failure_other": false}

    property var defects: ({})

    function updateFeedbackDict(key, selected) {
        defects[key] = selected
    }

    function defectReasonAdded() {
        for (var key in defects) {
            if(defects[key] == true) {
                return true
            }
        }
        return false
    }

    function submitFeedbackAndAcknowledge(success) {
        printFeedbackAcknowledgementPopup.open()
        printFeedbackAcknowledgementPopup.feedbackGood = success
        bot.submitPrintFeedback(success,
                         (success ? print_defects_template : defects))
        acknowledgePrint()
    }

    TextSubheader {
        id: titleText
        text: qsTr("DID THE PRINT SUCCEED?")
        anchors.top: parent.top
        anchors.topMargin: 15
        width: parent.width
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignLeft
    }

    ColumnLayout {
        id: buttonContainerPrintCancelled
        anchors.top: titleText.bottom
        anchors.topMargin: 20
        anchors.bottom: done_button.top
        anchors.bottomMargin: spacing

        ButtonRectangleSecondary {
            text: qsTr("PRINT FAILURE")
            logKey: text
            onClicked: {
                failureFeedbackSelected = true
                defects = JSON.parse(JSON.stringify(print_defects_template))
            }
        }

        ButtonRectangleSecondary {
            text: qsTr("OTHER")
            logKey: text
            onClicked: {
                defects = JSON.parse(JSON.stringify(print_defects_template))
                updateFeedbackDict("non_failure_other", true)
                submitFeedbackAndAcknowledge(false)
            }
        }
    }

    RowLayout {
        id: buttonContainerPrintCompleted
        anchors.top: titleText.bottom
        anchors.topMargin: 20
        spacing: 8

        ButtonRectanglePrimary {
            id: successButton
            onClicked: {
                submitFeedbackAndAcknowledge(true)
            }
            text: ""
            Layout.preferredWidth: 178
            Image {
                id: thumbs_up
                source: "qrc:/img/thumbs_up_feedback.png"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        ButtonRectanglePrimary {
            id: failedButton
            onClicked: {
                failureFeedbackSelected = true
                // Make a deep copy of the print defects dict. template which will
                // be updated in the print feedback component with the selected
                // defects.
                // This is absolutely uneccessary, if only the analytics guys
                // don't insist on sending the full defects dict. even for print
                // success feedback.
                defects = JSON.parse(JSON.stringify(print_defects_template))
            }
            Layout.preferredWidth: 178
            text: ""
            Image {
                id: thumbs_down
                source: "qrc:/img/thumbs_down_feedback.png"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    ButtonRectangleSecondary {
        id: done_button
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        border.width: 0
        anchors.horizontalCenter: buttonContainerPrintCancelled.horizontalCenter
        text: qsTr("SKIP")
        visible: true
        onClicked: {
            acknowledgePrint()
        }
    }

    states: [
        State {
            name: "print_successful"
            when: bot.process.stateType == ProcessStateType.Completed &&
                  !bot.process.printFeedbackReported

            PropertyChanges {
                target: titleText
                visible: true
                text: qsTr("DID THE PRINT SUCCEED?")
            }

            PropertyChanges {
                target: buttonContainerPrintCompleted
                anchors.top: titleText.bottom
                anchors.topMargin: 20
                visible: true
            }

            PropertyChanges {
                target: buttonContainerPrintCancelled
                visible: false
            }

            PropertyChanges {
                target: done_button
                anchors.bottomMargin: 0
                color: "#000000"
                text: qsTr("SKIP")
                visible: true
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
                target: titleText
                visible: false
            }

            PropertyChanges {
                target: buttonContainerPrintCompleted
                visible: false
            }

            PropertyChanges {
                target: buttonContainerPrintCancelled
                visible: false
            }

            PropertyChanges {
                target: done_button
                anchors.bottomMargin: 115
                border.width: 2
                text: qsTr("DONE")
                visible: true
            }
        },
        State {
            name: "print_cancelled"
            when: bot.process.stateType == ProcessStateType.Cancelled

            PropertyChanges {
                target: titleText
                visible: true
                text: qsTr("WHY WAS THIS PRINT CANCELLED?")
                font.pixelSize: 16
            }

            PropertyChanges {
                target: buttonContainerPrintCompleted
                visible: false
            }

            PropertyChanges {
                target: buttonContainerPrintCancelled
                visible: true
            }

            PropertyChanges {
                target: done_button
                anchors.bottomMargin: -75
                color: "#000000"
                text: qsTr("SKIP")
                visible: true
            }
        }
    ]
}
