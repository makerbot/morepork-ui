import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: failurePrintFeedback
    anchors.fill: parent

    ListModel {
        id: options
        ListElement { name: "Warping from buildplate"}
        ListElement { name: "stringiness"}
        ListElement { name: "Gap in walls"}
        ListElement { name: "Bad layer alignment"}
        ListElement { name: "Small feature defects"}
        ListElement { name: "Frequent extruder jams"}
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
            text: qsTr("TAP ANY NOTICEABLE PRINT DEFECTS")
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ButtonRectanglePrimary {
            id: submitFeedbackButton
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("SUBMIT FEEDBACK")
            onClicked: {
                acknowledgePrintFinished.submitFeedbackAndAcknowledge(false)
            }
            Layout.preferredWidth: 600
            Layout.preferredHeight: 52
        }

    }

    ListView {
        id: options_list
        layoutDirection: Qt.LeftToRight
        boundsBehavior: Flickable.DragOverBounds
        spacing: 32
        orientation: ListView.Vertical
        anchors.top : colums.bottom
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.leftMargin: 34
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        model: options
        delegate:
            RadioButton {
                id: control

                indicator:
                    Rectangle {
                        width: 36
                        height: 36
                        color: control.checked ? "#ffffff" : "#000000"
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
            }
    }


}
