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
    property alias buttonExtruderInfo: buttonExtruderInfo
    property alias buttonCalibrationProcedures: buttonCalibrationProcedures
    property alias buttonCleanExtruders: buttonCleanExtruders
    property alias buttonAdjustZOffset: buttonAdjustZOffset
    property alias calibrationProcedures: calibrationProcedures
    property alias adjustZOffset: adjustZOffset


    enum SwipeIndex {
        BasePage,                  // 0
        ExtruderInfoPage,          // 1
        CalibrationProceduresPage, // 2
        CleanExtrudersPage,        // 3
        AdjustZOffsetPage          // 4
    }

    LoggingStackLayout {
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

            FlickableMenu {
                id: flickableExtruderSettings
                contentHeight: columnExtruderSettings.height

                Column {
                    id: columnExtruderSettings
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MenuButton {
                        id: buttonExtruderInfo
                        buttonImage.source: "qrc:/img/icon_clean_extruders.png"
                        buttonText.text: qsTr("EXTRUDER INFO")
                        enabled: true
                        openMenuItemArrow.visible: false
                    }

                    MenuButton {
                        id: buttonCalibrationProcedures
                        buttonImage.source: "qrc:/img/icon_calibration_procedures.png"
                        buttonText.text: qsTr("CALIBRATION PROCEDURES")
                        enabled: !isProcessRunning()
                        openMenuItemArrow.visible: true
                    }

                    MenuButton {
                        id: buttonAdjustZOffset
                        buttonImage.source: "qrc:/img/icon_z_offset.png"
                        buttonText.text: qsTr("Z-OFFSET")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonCleanExtruders
                        buttonImage.source: "qrc:/img/icon_clean_extruders.png"
                        buttonText.text: qsTr("CLEAN EXTRUDERS")
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

        // ExtruderSettingsPage.ExtruderInfoPage
        Item {
            id: extruderInfoItem
            property var backSwiper: extruderSettingsSwipeView
            property int backSwipeIndex: ExtruderSettingsPage.BasePage
            property string topBarTitle: qsTr("Extruder Info")

            smooth: false
            visible: false

            ExtruderInfoPage {
                id: extruderInfo
            }
        }

        // ExtruderSettingsPage.CalibrationProceduresPage
        Item {
            id: calibrationProceduresItem
            property var backSwiper: extruderSettingsSwipeView
            property int backSwipeIndex: ExtruderSettingsPage.BasePage
            property string topBarTitle: qsTr("Calibration Procedures")

            smooth: false
            visible: false

            CalibrationProceduresPage {
                id: calibrationProcedures
            }
        }

        // ExtruderSettingsPage.CleanExtrudersPage
        Item {
            id: cleanExtrudersItem
            property var backSwiper: extruderSettingsSwipeView
            property int backSwipeIndex: ExtruderSettingsPage.BasePage
            property string topBarTitle: qsTr("Clean Extruders")
            property bool hasAltBack: true
            property bool backIsCancel: bot.process.type == ProcessType.NozzleCleaningProcess
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

        // ExtruderSettingsPage.AdjustZOffset
        Item {
            id: adjustZOffsetItem
            property var backSwiper: extruderSettingsSwipeView
            property int backSwipeIndex: ExtruderSettingsPage.BasePage
            property string topBarTitle: qsTr("Adjust Z-Offset")

            smooth: false
            visible: false

            AdjustZOffset {
                id: adjustZOffset
            }
        }
    }
}

