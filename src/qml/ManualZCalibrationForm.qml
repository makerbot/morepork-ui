import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: manualZCalibrationPage
    anchors.fill: parent

    property alias z_cal_button: contentRightSide.buttonPrimary
    property alias manual_calibration_issue_popup: manual_calibration_issue_popup
    property alias cancelManualZCalPopup: cancelManualZCalPopup
    property alias calValueItem1: calValueItem1
    property alias calValueItem2: calValueItem2
    property alias calValueItem3: calValueItem3
    property alias calValueItem4: calValueItem4


    ContentLeftSide {
        id: contentLeftSide
        image {
            source: "qrc:/img/manual_z_cal_start.png"
            visible: true
        }
        loadingIcon {
            visible: false
        }

        visible: true
    }

    ColumnLayout {
        id: numberValueCollectorItem
        height: children.height
        width: 400
        anchors.top: parent.top
        anchors.topMargin: 50
        anchors.left: parent.left
        anchors.leftMargin: 38
        spacing: 35
        visible: false

        NumberAddSubtractItem {
            id: calValueItem1
            Layout.preferredHeight: 50
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }

        NumberAddSubtractItem {
            id: calValueItem2
            Layout.preferredHeight: 50
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

        }
        NumberAddSubtractItem {
            id: calValueItem3
            Layout.preferredHeight: 50
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }

        NumberAddSubtractItem {
            id: calValueItem4
            Layout.preferredHeight: 50
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        }
    }

    ContentRightSide {
        id: contentRightSide
        textHeader {
            text: qsTr("MANUAL Z-CALIBRATION")
            style: TextHeadline.Base
            visible: true
        }
        textBody {
            text: qsTr("This procedure will use a 3D print to calibrate the distance between" +
                       "your model and support extruders.<br><br>" +
                       "It is recommended to run every time you attach new extruders.")
            visible: true
        }
        textBody1 {
            text: qsTr("Tools Required: Calipers, Sharp Tool")
            visible: true
        }

        buttonPrimary {
            text: qsTr("START")
            enabled: true
            visible: true
            style: ButtonRectangleBaseForm.ButtonWithHelp

            help.onClicked: {
                helpPopup.state = "method_calibration"
                helpPopup.open()
            }
        }
        visible: true
    }

    states: [
        State {
            name: "z_cal_start"

            PropertyChanges {
                target: contentLeftSide
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.image
                source: ("qrc:/img/manual_z_cal_start.png")
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.loadingIcon
                visible: false
            }

            PropertyChanges {
                target: numberValueCollectorItem
                visible: false
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("MANUAL Z-CALIBRATION")
                style: TextHeadline.Base
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("This procedure will use a 3D print to calibrate the distance between" +
                           "your model and support extruders.<br><br>" +
                           "It is recommended to run every time you attach new extruders.")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                text: qsTr("START")
                visible: true
                style: ButtonRectangleBaseForm.ButtonWithHelp
            }
        },

        State {
            name: "remove_support"

            PropertyChanges {
                target: contentLeftSide
                visible: true
            }

            PropertyChanges {
                target: numberValueCollectorItem
                visible: false
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.image
                source: ("qrc:/img/manual_z_cal_remove_support.png")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("Use a spatula or knife to gently separate the support material (might require finesse).<br><br>" +
                           "The support material will be used to take measurements which will help calibrate.<br><br>" +
                           "Click the help icon if you are experiencing any issues around removal.")
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
                style: ButtonRectangleBaseForm.ButtonWithHelp
            }
        },

        State {
            name: "measure"

            PropertyChanges {
                target: contentLeftSide
                visible: true
            }

            PropertyChanges {
                target: numberValueCollectorItem
                visible: false
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.image
                source: ("qrc:/img/manual_z_cal_measure.png")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("HOW THIS PRINT WORKS")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("Use the flats of the clipers to take a measure from the center of each side of the square.<br><br>" +
                           "The thickness of your printed line will determine how much of your calibration needs to be adjust3ed.<br><br>" +
                           "Values are measured in millimeters (mm)")
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
                style: ButtonRectangleBaseForm.ButtonWithHelp
            }
        },
        State {
            name: "z_calibration"

            PropertyChanges {
                target: contentLeftSide
                visible: false
            }

            PropertyChanges {
                target: numberValueCollectorItem
                visible: true
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("Z-CALIBRATION")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("Adjust the values for all 4 sides (order does not matter)<br><br>" +
                           "Values are measured in millimeters (mm)")
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
                style: ButtonRectangleBaseForm.ButtonWithHelp
            }
        },
        State {
            name: "updating_information"

            PropertyChanges {
                target: contentLeftSide
                visible: true
            }

            PropertyChanges {
                target: numberValueCollectorItem
                visible: false
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
                text: qsTr("UPDATING INFORMATION")
                style: TextHeadline.Large
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("Please wait...")
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
        },
        State {
            name: "success"

            PropertyChanges {
                target: contentLeftSide
                visible: true
            }

            PropertyChanges {
                target: numberValueCollectorItem
                visible: false
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
                text: qsTr("CALIBRATION SUCCESSFUL")
                style: TextHeadline.Base
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("This pair of extruders is now calibrated and can be used for printing.")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody1
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                text: qsTr("DONE")
                visible: true
                style: ButtonRectangleBaseForm.Button
            }
        }
    ]

    CustomPopup {
        id: manual_calibration_issue_popup
        popupName: "ManualCalibrationIssue"
        popupHeight: manual_cal_column_layout.height +145
        showTwoButtons: true

        left_button_text: qsTr("EXIT")
        right_button_text: qsTr("START")
        left_button.onClicked: {
            manual_calibration_issue_popup.close()
        }
        right_button.onClicked: {
            // Start Auto Cal/Clean extruders
            extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.BasePage)
            extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.CalibrateExtrudersPage)
            returnToManualCal = true
            state = "z_cal_start"
            resetManualCalValues()

            // Button action in 'base state'
            bot.calibrateToolheads(["x","y"])
            manual_calibration_issue_popup.close()
        }

        ColumnLayout {
            id: manual_cal_column_layout
            height: children.height
            anchors.top: manual_calibration_issue_popup.popupContainer.top
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Image {
                id: error_image
                width: sourceSize.width - 10
                height: sourceSize.height -10
                Layout.alignment: Qt.AlignHCenter
                source: "qrc:/img/process_error_small.png"
            }

            TextHeadline {
                text: qsTr("CLEAN + AUTO-CALIBRATE EXTRUDERS")
                Layout.alignment: Qt.AlignHCenter
            }

            TextBody {
                text: qsTr("The extrtuders need to be cleaned and auto-calibrated "+
                           "before this procedure can be completed correctly.")
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: parent.width
            }
        }
    }

    CustomPopup {
        popupName: "CancelManualZCalibration"
        id: cancelManualZCalPopup
        popupWidth: 720
        popupHeight: 250

        showTwoButtons: true
        left_button_text: qsTr("STOP PROCESS")
        left_button.onClicked: {
            state = "z_cal_start"
            cancelManualZCalPopup.close()
        }
        right_button_text: qsTr("CONTINUE")
        right_button.onClicked: {
            cancelManualZCalPopup.close()
        }

        ColumnLayout {
            id: columnLayout
            width: 590
            height: 100
            anchors.top: parent.top
            anchors.topMargin: 145
            anchors.horizontalCenter: parent.horizontalCenter

            TextHeadline {
                text: qsTr("CANCEL MANUAL Z-CALIBRATION")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            TextBody {
                text: qsTr("Are you sure you want to exit or start over manual z-calibration?")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }
        }
    }
}
