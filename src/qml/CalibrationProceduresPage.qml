import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.12
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import MachineTypeEnum 1.0
import FreStepEnum 1.0
import ErrorTypeEnum 1.0

Item {
    id: calibrationProceduresPage
    smooth: false
    anchors.fill: parent

    property alias calibrationProceduresSwipeView: calibrationProceduresSwipeView

    property alias buttonCalibrateToolhead: buttonCalibrateToolhead
    property alias buttonCalibrateZAxisOnly: buttonCalibrateZAxisOnly
    property alias buttonManualZCalibration: buttonManualZCalibration
    property alias toolheadCalibration: toolheadCalibration
    property alias calibrateErrorScreen: calibrateErrorScreen
    property alias manualZCalibration: manualZCalibration
    property bool returnToManualCal: false

    enum SwipeIndex {
        BasePage,                  //0
        AutomaticCalibrationPage,  //1
        ManualZCalibrationPage     //2
    }

    LoggingStackLayout {
        id: calibrationProceduresSwipeView
        logName: "calibrationProceduresSwipeView"
        currentIndex: CalibrationProceduresPage.BasePage

        // CalibrationProceduresPage.BasePage
        Item {
            id: itemCalibrationProcedures
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: settingsPage.extruderSettingsPage.extruderSettingsSwipeView
            property int backSwipeIndex: ExtruderSettingsPage.BasePage
            property string topBarTitle: qsTr("Calibration Procedures")

            smooth: false

            Flickable {
                id: flickableCalibrationProcedures
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnCalibrationProcedures.height

                Column {
                    id: columnCalibrationProcedures
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MenuButton {
                        id: buttonCalibrateToolhead
                        buttonImage.source: "qrc:/img/icon_calibrate_toolheads.png"
                        buttonText.text: qsTr("AUTOMATIC CALIBRATION - X Y Z")
                        additionalInfo {
                            text: qsTr("10 Minutes")
                            visible: true
                        }

                        enabled: !isProcessRunning()

                        onClicked: {
                            calibrationProceduresSwipeView.swipeToItem(CalibrationProceduresPage.AutomaticCalibrationPage)
                        }
                    }

                    MenuButton {
                        id: buttonCalibrateZAxisOnly
                        buttonImage.source: "qrc:/img/icon_calibrate_toolheads.png"
                        buttonText.text: qsTr("AUTOMATIC CALIBRATION - Z")
                        enabled: !isProcessRunning()
                        additionalInfo {
                            text: qsTr("2 Minutes")
                            visible: true
                        }

                        onClicked: {
                            autoZCalPopup.open()
                        }
                    }

                    MenuButton {
                        id: buttonManualZCalibration
                        buttonImage.source: "qrc:/img/icon_manual_zcal.png"
                        buttonText.text: qsTr("MANUAL CALIBRATION - Z")
                        visible: bot.machineType !=  MachineType.Fire
                        enabled: !isProcessRunning()
                        additionalInfo {
                            text: qsTr("30 Minutes")
                            visible: true
                        }

                        onClicked: {
                            bot.get_calibration_offsets()
                            isInManualCalibration = true
                            calibrationProceduresSwipeView.swipeToItem(CalibrationProceduresPage.ManualZCalibrationPage)
                        }
                    }
                }
            }
        }

        // CalibrationProceduresPage.AutomaticCalibrationPage
        Item {
            id: calibrateToolheadsItem
            property var backSwiper: calibrationProceduresSwipeView
            property int backSwipeIndex: CalibrationProceduresPage.BasePage
            property string topBarTitle: qsTr("Automatic Calibration")
            property bool backIsCancel: (bot.process.type === ProcessType.CalibrationProcess &&
                                         bot.process.isProcessCancellable)
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(toolheadCalibration.chooseMaterial) {
                    toolheadCalibration.chooseMaterial = false
                    return
                }
                if(!inFreStep) {
                    if(bot.process.type === ProcessType.CalibrationProcess &&
                       bot.process.isProcessCancellable) {
                        toolheadCalibration.cancelCalibrationPopup.open()
                    } else if(bot.process.type == ProcessType.None) {
                        // If we are in the manual cal process
                        // we want to prompt the user to resume
                        // manual calibration
                        if(returnToManualCal) {
                            returnToManualCal = false
                            toolheadCalibration.resumeManualCalibrationPopup.open()
                        }
                        toolheadCalibration.state = "base state"
                        calibrationProceduresSwipeView.swipeToItem(CalibrationProceduresPage.BasePage)
                    }
                }
                else {
                    if(calibrateErrorScreen.lastReportedErrorType == ErrorType.NoError) {
                        skipFreStepPopup.open()
                    }
                }
            }

            function skipFreStepAction() {
                if(toolheadCalibration.chooseMaterial) {
                    toolheadCalibration.chooseMaterial = false
                    return
                }
                bot.cancel()
                toolheadCalibration.state = "base state"
                calibrationProceduresSwipeView.swipeToItem(CalibrationProceduresPage.BasePage)
                extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.BasePage)
                settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            ToolheadCalibration {
                id: toolheadCalibration
                visible: !calibrateErrorScreen.visible
                onProcessDone: {
                    toolheadCalibration.state = "base state"
                    if(calibrateErrorScreen.lastReportedErrorType == ErrorType.NoError) {
                        calibrationProceduresSwipeView.swipeToItem(CalibrationProceduresPage.BasePage)
                    }
                }
            }

            ErrorScreen {
                id: calibrateErrorScreen
                isActive: bot.process.type == ProcessType.CalibrationProcess
                visible: {
                    lastReportedProcessType == ProcessType.CalibrationProcess &&
                    lastReportedErrorType != ErrorType.NoError
                }
            }
        }

        // CalibrationProceduresPage.ManualZCalibrationPage
        Item {
            id: manualZCalibrationItem
            property var backSwiper: calibrationProceduresSwipeView
            property int backSwipeIndex: CalibrationProceduresPage.BasePage
            property string topBarTitle: qsTr("Manual Z-Calibration")
            property bool hasAltBack: true
            property bool backIsCancel: (manualZCalibration.state == "return_print_page" ||
                                         manualZCalibration.state == "updating_information" ||
                                         manualZCalibration.state == "success" ||
                                         manualZCalibration.state == "adjustments_complete" ||
                                         (manualZCalibration.state == "cal_issue" &&
                                          !manualZCalibration.allowReturn))

            smooth: false
            visible: false

            function altBack() {
                manualZCalibration.back()
            }

            ManualZCalibration {
                id: manualZCalibration
            }
        }
    }

    CustomPopup {
        popupName: "AutomaticZCalibration"
        id: autoZCalPopup
        popupHeight: autoZCalColumnLayout.height +145
        visible: false
        showTwoButtons: true
        leftButtonText: qsTr("BACK")
        leftButton.onClicked: {
            autoZCalPopup.close()
        }
        rightButtonText: qsTr("CONFIRM")
        rightButton.onClicked: {
            calibrationProceduresSwipeView.swipeToItem(CalibrationProceduresPage.AutomaticCalibrationPage)
            bot.calibrateToolheads(["z"])
            autoZCalPopup.close()
        }

        ColumnLayout {
            id: autoZCalColumnLayout
            height: children.height
            anchors.top: autoZCalPopup.popupContainer.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 35
            spacing: 20

            Image {
                id: autoZCalImage
                width: sourceSize.width
                Layout.preferredWidth: sourceSize.width
                Layout.preferredHeight: sourceSize.height
                source: "qrc:/img/popup_error.png"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            TextHeadline {
                id: alert_text
                text: qsTr("AUTOMATIC Z-ONLY CALIBRATION")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            TextBody {
                id: descritpion_text
                text: qsTr("Do you want to begin the automatic z-only calibration process?")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }
        }
    }
}

