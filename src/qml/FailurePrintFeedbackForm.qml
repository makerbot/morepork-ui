import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

LoggingItem {
    id: failurePrintFeedback

    ListModel {
        // These elements can be found in a dictionary in AcknowledgePrintFinishedForm.qml
        // the key here corresponds to the key there, so if more options need to be added
        // make sure to add the key in both places.
        id: options
        ListElement { name: qsTr("WARPING FROM BUILDPLATE")
                      key: "warping_from_buildplate"}
        ListElement { name: qsTr("STRINGINESS")
                      key: "stringiness"}
        ListElement { name: qsTr("GAPS IN WALLS")
                      key: "gaps_in_walls"}
        ListElement { name: qsTr("BAD LAYER ALIGNMENT")
                      key: "bad_layer_alignment"}
        ListElement { name: qsTr("SMALL FEATURE DEFECTS")
                      key: "small_feature_defects"}
        ListElement { name: qsTr("FREQUENT EXTRUDER JAMS")
                      key: "frequent_extruder_jams"}
        ListElement { name: qsTr("OTHER")
                      key: "other"}
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    ColumnLayout {
        id: colums
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: 15
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 10

        TextBody {
            id: instructionText
            color: "#cbcbcb"
            text: qsTr("Select any noticeable print defects.")
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
        spacing: 28
        anchors.top : colums.bottom
        anchors.topMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 30
        anchors.right: parent.right
        anchors.rightMargin: 5
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        model: options
        orientation: ListView.Vertical
        flickableDirection: Flickable.VerticalFlick

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AlwaysOn
        }
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
                    Image {
                        id: checkboxContent
                        sourceSize.width: 36
                        sourceSize.height: 36
                        source: selected ? "qrc:/img/feedback_selected_box.png" : "qrc:/img/feedback_checkbox.png"
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
