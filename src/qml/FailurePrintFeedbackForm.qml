import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: failurePrintFeedback
    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Text {
        id: instructionText
        color: "#cbcbcb"
        text: qsTr("TAP ANY NOTICEABLE PRINT DEFECTS")
        antialiasing: false
        smooth: false
        font.letterSpacing: 3
        font.family: defaultFont.name
        font.weight: Font.Light
        font.pixelSize: 20
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 25
    }


    ColumnLayout {
        width: parent.width
        anchors.top: instructionText.bottom
        anchors.topMargin: 30
        spacing: 15

        RowLayout {
            width: parent.width
            spacing: 25
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            FeedbackButton {
                label: "WARPING FROM BUILDPLATE"
                key: "warping_from_buildplate"
            }

            FeedbackButton {
                label: "STRINGINESS"
                key: "stringiness"
            }
        }

        RowLayout {
            width: parent.width
            spacing: 25
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            FeedbackButton {
                label: "GAPS IN WALLS"
                key: "gaps_in_walls"
            }

            FeedbackButton {
                label: "BAD LAYER ALIGNMENT"
                key: "bad_layer_alignment"
            }
        }

        RowLayout {
            width: parent.width
            spacing: 25
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            FeedbackButton {
                label: "SMALL FEATURE DEFECTS"
                key: "small_feature_defects"
            }

            FeedbackButton {
                label: "OTHER"
                key: "other"
            }
        }

        RowLayout {
            width: parent.width
            spacing: 25
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            FeedbackButton {
                label: "FREQUENT EXTRUDER JAMS"
                key: "frequent_extruder_jams"
            }
        }
    }

    RoundedButton {
        id: submitFeedbackButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 35
        buttonHeight: 50
        label: qsTr("SUBMIT FEEDBACK")
        button_mouseArea.onClicked: {
            acknowledgePrintFinished.submitFeedbackAndAcknowledge(false)
        }
    }
}
