import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.12
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import MachineTypeEnum 1.0
import FreStepEnum 1.0
import ErrorTypeEnum 1.0

Item {
    id: extruderSettingsPage
    smooth: false
    anchors.fill: parent

    property alias extruderSettingsSwipeView: extruderSettingsSwipeView

    property alias buttonCalibrateToolhead: buttonCalibrateToolhead
    property alias buttonCalibrateZAxisOnly: buttonCalibrateZAxisOnly
    property alias calibrateErrorScreen: calibrateErrorScreen

    property alias buttonCleanExtruders: buttonCleanExtruders
    property alias toolheadCalibration: toolheadCalibration

    property alias buttonManualZCalibration: buttonManualZCalibration
    property alias manualZCalibration: manualZCalibration
    property bool returnToManualCal: false

    enum SwipeIndex {
        BasePage,                   //0
        AutomaticCalibrationPage,   //1
        CleanExtrudersPage,         //2
        ManualZCalibrationPage      //3
    }

    LoggingSwipeView {
        id: extruderSettingsSwipeView
        logName: "extruderSettingsSwipeView"
        currentIndex: ExtruderSettingsPage.BasePage

        // ExtruderSettingsPage.BasePage
        Item {
            id: itemExtruderSettings
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: settingsPage.settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            property string topBarTitle: qsTr("Extruder Settings")
            smooth: false

            Flickable {
                id: flickableExtruderSettings
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnExtruderSettings.height

                Column {
                    id: columnExtruderSettings
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MenuButton {
                        id: buttonCalibrateToolhead
                        buttonImage.source: "qrc:/img/icon_calibrate_toolhead.png"
                        buttonText.text: qsTr("AUTOMATIC CALIBRATION - X Y Z")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonCalibrateZAxisOnly
                        buttonImage.source: "qrc:/img/icon_calibrate_toolhead.png"
                        buttonText.text: qsTr("AUTOMATIC CALIBRATION - Z")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonCleanExtruders
                        buttonImage.source: "qrc:/img/icon_clean_extruders.png"
                        buttonText.text: qsTr("CLEAN EXTRUDERS")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonManualZCalibration
                        buttonImage.source: "qrc:/img/icon_manual_zcal.png"
                        buttonText.text: qsTr("MANUAL CALIBRATION - Z")
                        visible: bot.machineType !=  MachineType.Fire
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonJamDetectionExpExtruder
                        buttonImage.source: "qrc:/img/icon_clean_extruders.png"
                        buttonText.text: "LABS " + qsTr("EXTRUDER JAM DETECTION")
                        enabled: bot.extruderAPresent &&
                                 materialPage.bay1.usingExperimentalExtruder

                        slidingSwitch.checked:!bot.extruderAJamDetectionDisabled
                        slidingSwitch.enabled: parent.enabled
                        slidingSwitch.visible: true

                        slidingSwitch.onClicked: {
                            if(slidingSwitch.checked) {
                                bot.ignoreError(0,[81],false)
                            }
                            else if(!slidingSwitch.checked) {
                                bot.ignoreError(0,[81],true)
                            }
                        }
                    }
                }
            }
        }

        // ExtruderSettingsPage.AutomaticCalibrationPage
        Item {
            id: calibrateToolheadsItem
            property var backSwiper: extruderSettingsSwipeView
            property int backSwipeIndex: ExtruderSettingsPage.BasePage
            property string topBarTitle: qsTr("Automatic Calibration")
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
                        extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.BasePage)
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
                        extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.BasePage)
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

        // ExtruderSettingsPage.CleanExtrudersPage
        Item {
            id: cleanExtrudersItem
            property var backSwiper: extruderSettingsSwipeView
            property int backSwipeIndex: ExtruderSettingsPage.BasePage
            property string topBarTitle: qsTr("Clean Extruders")
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(bot.process.type == ProcessType.NozzleCleaningProcess) {
                    cleanExtruders.cancelCleanExtrudersPopup.open()
                } else {
                    cleanExtruders.state = "base state"
                    extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.BasePage)
                }
            }

            CleanExtruders {
                id: cleanExtruders
                onProcessDone: {
                    state = "base state"
                    extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.BasePage)
                }
            }
        }

        // ExtruderSettingsPage.ManualZCalibrationPage
        Item {
            id: manualZCalibrationItem
            property var backSwiper: extruderSettingsSwipeView
            property int backSwipeIndex: ExtruderSettingsPage.BasePage
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
}

