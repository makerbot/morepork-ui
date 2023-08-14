import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.12
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
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
    // Is this the best place for this?
    property bool returnToManualCal: false

    enum SwipeIndex {
        BasePage,               //0
        CalibrateExtrudersPage, //1
        CleanExtrudersPage,     //2
        ManualZCalibrationPage  //3
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
                        buttonText.text: qsTr("AUTOMATIC CALIBRATION")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonCalibrateZAxisOnly
                        buttonImage.source: "qrc:/img/icon_calibrate_toolhead.png"
                        buttonText.text: qsTr("Z-ONLY CALIBRATION")
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

        // ExtruderSettingsPage.CalibrateExtrudersPage
        Item {
            id: calibrateToolheadsItem
            property var backSwiper: extruderSettingsSwipeView
            property int backSwipeIndex: ExtruderSettingsPage.BasePage
            property string topBarTitle: qsTr("Calibrate Extruders")
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
            property bool backIsCancel: (manualZCalibration.state == "remove_support" ||
                                        manualZCalibration.state == "updating_information" ||
                                        manualZCalibration.state == "success")

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

