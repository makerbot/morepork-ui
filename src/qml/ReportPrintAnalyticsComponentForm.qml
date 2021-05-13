import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: element
    width: 400
    height: 100

    Text {
        id: titleText
        color: "#cbcbcb"
        text: qsTr("DID THE PRINT SUCCEED?")
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

        RoundedButton {
            id: successButton
            buttonWidth: 100
            buttonHeight: 50
            label: qsTr("SUCCESS")
            button_mouseArea.onClicked: {
                printFeedbackAcknowledgementPopup.open()
                printFeedbackAcknowledgementPopup.feedbackGood = true
                bot.submitPrintFeedback(true, print_defects)
            }
        }

        RoundedButton {
            id: failedButton
            buttonWidth: 100
            buttonHeight: 50
            label: qsTr("FAILURE")
            button_mouseArea.onClicked: {
                failureFeedbackSelected = true
                // Make a deep copy of the print defects dict. template which will
                // be updated in the print feedback component with the selected
                // defects.
                // This is absolutely uneccessary, if only the analytics guys
                // don't insist on sending the full defects dict. even for print
                // success feedback.
                printFeedback.defects = JSON.parse(JSON.stringify(print_defects))
            }
        }
    }
}
