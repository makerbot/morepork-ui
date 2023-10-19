import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0

LoggingItem {
    itemName: "ManualZCalibration"
    id: manualZCalibrationPage
    anchors.fill: parent

    property alias z_cal_button: contentRightSide.buttonPrimary
    property alias retry_button: contentRightSide.buttonSecondary1
    property alias manual_calibration_issue_popup: manual_calibration_issue_popup
    property alias cancelManualZCalPopup: cancelManualZCalPopup
    property alias calValueItem1: calValueItem1
    property alias calValueItem2: calValueItem2
    property alias calValueItem3: calValueItem3
    property alias calValueItem4: calValueItem4
    property bool printSuccess: false

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
        buttonSecondary1 {
            text: qsTr("RETRY")
            visible: false
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
                target: contentRightSide.textBody1
                text: qsTr("Tools Required: Calipers, Sharp Tool")
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                text: qsTr("START")
                visible: true
                style: ButtonRectangleBaseForm.ButtonWithHelp
            }

            PropertyChanges {
                target: contentRightSide.buttonSecondary1
                visible: false
            }
        },
        State {
            name: "z_cal_qr_code"

            PropertyChanges {
                target: contentLeftSide
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.image
                source: ("qrc:/img/qr_method_calibration.png")
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
                text: qsTr("Refer To Support Page During Following Steps")
                style: TextHeadline.Base
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("We highly recommend having the video content on this page accessible " +
                           "for additional help and troubleshooting tips as you are running the " +
                           "calibration procedure.")
                visible: true
            }


            PropertyChanges {
                target: contentRightSide.textBody1
                text: qsTr("ultimaker.com/method-calibration")
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                text: qsTr("NEXT")
                visible: true
                style: ButtonRectangleBaseForm.Button
            }

            PropertyChanges {
                target: contentRightSide.buttonSecondary1
                visible: false
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

            PropertyChanges {
                target: contentRightSide.buttonSecondary1
                visible: false
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
                text: qsTr("Use the flats of the calipers to take a measurement from the center of each side of the square.<br><br>" +
                           "The thickness of your printed line will determine how much of your calibration needs to be adjusted.<br><br>" +
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

            PropertyChanges {
                target: contentRightSide.buttonSecondary1
                visible: false
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

            PropertyChanges {
                target: contentRightSide.buttonSecondary1
                visible: false
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

            PropertyChanges {
                target: contentRightSide.buttonSecondary1
                visible: false
            }
        },
        State {
            name: "adjustments_complete"

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
                source: ("qrc:/img/coarse_adj_step.png")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("STEP 1 COMPLETE")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("The printer has made adjustments based on your inputs. The printer will re-run this procedure to " +
                           "make additional improvements and do a final check.")
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

            PropertyChanges {
                target: contentRightSide.buttonSecondary1
                visible: false
            }
        },
        State {
            name: "insert_build_plate"

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
                source: ("qrc:/img/%1.gif").arg(getImageForPrinter("insert_build_plate"))
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("REMOVE PRINT + INSERT BUILD PLATE")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("Insert the build plate by first placing the rear edge down and sliding it back until it fits snug and looks aligned.")
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
                style: ButtonRectangleBaseForm.Button
            }

            PropertyChanges {
                target: contentRightSide.buttonSecondary1
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

            PropertyChanges {
                target: contentRightSide.buttonSecondary1
                visible: false
            }
        },
        State {
            name: "cal_issue"

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
                icon_image: LoadingIcon.Failure
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("PROCEDURE FAILED")
                style: TextHeadline.Base
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("If you are experiencing issues with the calibration print we recommend "+
                           "running the clean + auto-calibrate procedure.")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody1
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                text: qsTr("CLEAN + AUTO-CALIBRATE")
                visible: true
                style: ButtonRectangleBaseForm.Button
            }

            PropertyChanges {
                target: contentRightSide.buttonSecondary1
                text: qsTr("RETRY")
                visible: true
            }
        },
        State {
            name: "return_print_page"

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
                icon_image: printSuccess ? LoadingIcon.Success : LoadingIcon.Failure
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: printSuccess ? qsTr("PRINT COMPLETE") : qsTr("PRINT FAILED")
                style: TextHeadline.Base
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("Z-CALIBRATION PRINT")
                opacity: 0.5
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody1
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                text: printSuccess ? qsTr("NEXT") : qsTr("RETRY")
                visible: true
                style: ButtonRectangleBaseForm.Button
            }

            PropertyChanges {
                target: contentRightSide.buttonSecondary1
                text: qsTr("PRINT FAILED")
                visible: true
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
            extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.AutomaticCalibrationPage)
            returnToManualCal = true

            // Button action in 'base state'
            bot.calibrateToolheads(["x","y"])
            resetProcess(false)
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
            // Return to Start Page
            resetProcess(false)

            // If we are cancelling calibration in the middle of a print, we need
            // to make sure we exit out of the print process, which means waiting
            // for the print to reach a terminal state, then acknowleging that state
            if (bot.process.type == ProcessType.Print) {
                bot.cancel();
                waitingForCancel = true;
                if (cancelWaitDone) completeCancelWait();
            }

            cancelManualZCalPopup.close()
        }
        right_button_text: qsTr("CONTINUE")
        right_button.onClicked: {
            // Continue
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
