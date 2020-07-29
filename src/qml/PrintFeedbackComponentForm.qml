import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: element
    width: parent.width
    height: parent.height
    visible: true

    property var print_defects: {"warping_from_buildplate": warpingCheckbox.checked,
                                 "stringiness": stringinessCheckbox.checked,
                                 "gaps_in_walls": gapsCheckbox.checked,
                                 "bad_layer_alignment": badLayerAlignCheckbox.checked,
                                 "small_feature_defects": smallDefectsCheckbox.checked,
                                 "frequent_extruder_jams": jamsCheckbox.checked,
                                 "other": otherCheckbox.checked}

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Text {
        width: 648
        height: 64
        font.family: defaultFont.name
        font.letterSpacing: 3
        font.weight: Font.Bold
        font.pointSize: 14
        font.capitalization: Font.AllUppercase
        smooth: false
        color: "white"
        text: qsTr("SELECT ANY NOTICEABLE PRINT DEFECTS")
        topPadding: 40
        leftPadding: 160
        horizontalAlignment: Text.AlignHCenter
    }

    ColumnLayout {
        anchors.right: parent.right
        anchors.rightMargin: 265
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 80
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 510

        CustomCheckbox {
            id: warpingCheckbox
            checkbox_text: qsTr("WARPING FROM BUILDPLATE")
        }
        CustomCheckbox {
            id: stringinessCheckbox
            checkbox_text: qsTr("STRINGINESS")
        }
        CustomCheckbox {
            id: gapsCheckbox
            checkbox_text: qsTr("GAPS IN WALLS")
        }
        CustomCheckbox {
            id: badLayerAlignCheckbox
            checkbox_text: qsTr("BAD LAYER ALIGNMENT")
        }
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.leftMargin: 400
        anchors.top: parent.top
        anchors.topMargin: 80
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 510
        CustomCheckbox {
            id: smallDefectsCheckbox
            checkbox_text: qsTr("SMALL FEATURE DEFECTS")
        }
        CustomCheckbox {
            id: jamsCheckbox
            checkbox_text: qsTr("FREQUENT EXTRUDER JAMS")
        }
        CustomCheckbox {
            id: otherCheckbox
            checkbox_text: qsTr("OTHER")
        }
    }

    RowLayout {
        id: buttonContainer
        anchors.top: titleText.bottom
        anchors.topMargin: 20
        spacing: 35

        RoundedButton {
            id: submitFeedbackButton
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.leftMargin: 270
            Layout.bottomMargin: 0
            Layout.topMargin: 310
            button_text.horizontalAlignment: Text.AlignLeft
            buttonWidth: 100
            buttonHeight: 50
            label: qsTr("SUBMIT FEEDBACK")
            button_mouseArea.onClicked: {
                printFeedbackFailureAcknowledgementPopup.open()
                bot.submitPrintFeedback(false, print_defects)
            }
        }
    }

    CustomPopup {
        id: printFeedbackFailureAcknowledgementPopup
        popupWidth: 720
        popupHeight: 275
        showOneButton: true
        full_button_text: qsTr("DONE")
        full_button.onClicked: {
            printFeedbackFailureAcknowledgementPopup.close()
        }
        onOpened: {
            autoClosePopup.start()
        }
        onClosed: {
            printStatusView.feedbackSubmitted = true
            autoClosePopup.stop()
        }

        Timer {
            id: autoClosePopup
            interval: 7000
            onTriggered: printFeedbackFailureAcknowledgementPopup.close()
        }

        ColumnLayout {
            id: columnLayout_printFailureFeedbackAcknowledgementPopup
            width: 590
            height: children.height
            spacing: 20
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -30
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: alert_text_printFailureFeedbackAcknowledgementPopup
                color: "#cbcbcb"
                text: qsTr("THANKS FOR THE FEEDBACK")
                font.letterSpacing: 3
                Layout.alignment: Qt.AlignHCenter
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 20
            }

            Text {
                id: description_text_printFeedbackAcknowledgementPopup
                color: "#cbcbcb"
                text: qsTr("If problems still persist visit Support.Makerbot.com.")
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
