import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: failurePrintFeedback
    anchors.fill: parent

    ListModel {
        // These elements can be found in a dictionary in AcknowledgePrintFinishedForm.qml
        // the key here corresponds to the key there, so if more options need to be added
        // make sure to add the key in both places.
        id: options
        ListElement { name: "Warping from buildplate"
                      key: "warping_from_buildplate"}
        ListElement { name: "Stringiness"
                      key: "stringiness"}
        ListElement { name: "Gap in walls"
                      key: "gap_in_walls"}
        ListElement { name: "Bad layer alignment"
                      key: "bad_layer_alignment"}
        ListElement { name: "Small feature defects"
                      key: "small_feature_defects"}
        ListElement { name: "Frequent extruder jams"
                      key: "frequent_extruder_jams"}
    }
    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    ColumnLayout {
        id: colums
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: 25
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 20

        TextBody {
            id: instructionText
            color: "#cbcbcb"
            text: "Select any noticable print defects."
            Layout.alignment: Qt.AlignHCenter
        }

        ButtonRectanglePrimary {
            id: submitFeedbackButton
            text: qsTr("SUBMIT FEEDBACK")
            enabled: acknowledgePrintFinished.defectReasonAdded()
            onClicked: {
                acknowledgePrintFinished.submitFeedbackAndAcknowledge(false)
            }
            Layout.preferredWidth: 600
            Layout.preferredHeight: 52
            Layout.alignment: Qt.AlignHCenter
        }

    }

    ListView {
        id: options_list
        smooth: false
        antialiasing: false
        highlightRangeMode: ListView.ApplyRange
        spacing: 32
        anchors.top : colums.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 34
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 36
        anchors.right: parent.right
        anchors.rightMargin: 34
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        model: options
        orientation: ListView.Vertical
        flickableDirection: Flickable.VerticalFlick
        delegate:
            RadioButton {
                id: control
                property bool selected: false
                height: 40

                property bool resetState: acknowledgePrintFinished.failureFeedbackSelected
                onResetStateChanged: {
                    if(resetState) {
                        selected = false
                        acknowledgePrintFinished.updateFeedbackDict(key, selected)
                    }
                }
                indicator:
                    Rectangle {
                        width: 36
                        height: 36
                        color:  selected ? "#ffffff" : "#000000"
                        border.width: 2
                        border.color: "#ffffff"

                   }
                contentItem: TextBody {
                    style: TextBody.Large
                    font.weight: Font.Bold
                    text: name
                    color: "#ffffff"
                    anchors.left: indicator.left
                    anchors.leftMargin: 50

                }
                onClicked: {
                    if(selected) { selected = false }
                    else { selected = true }
                    acknowledgePrintFinished.updateFeedbackDict(key, selected)
                    submitFeedbackButton.enabled = acknowledgePrintFinished.defectReasonAdded()
                }
            }
    }


}
