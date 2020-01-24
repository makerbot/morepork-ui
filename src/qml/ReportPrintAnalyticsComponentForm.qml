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
                bot.submitPrintFeedback(true)
            }
        }

        RoundedButton {
            id: failedButton
            buttonWidth: 100
            buttonHeight: 50
            label: qsTr("FAILURE")
            button_mouseArea.onClicked: {
                printFeedbackAcknowledgementPopup.open()
                printFeedbackAcknowledgementPopup.feedbackGood = false
                bot.submitPrintFeedback(false)
            }
        }
    }
}
