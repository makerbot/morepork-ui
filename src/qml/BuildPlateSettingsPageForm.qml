import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0
import ErrorTypeEnum 1.0

Item {
    id: buildPlateSettingsPage
    smooth: false
    anchors.fill: parent

    property alias buildPlateSettingsSwipeView: buildPlateSettingsSwipeView

    property alias assistedLevel: assistedLevel
    property alias buttonAssistedLeveling: buttonAssistedLeveling

    property alias moveBuildPlatePage: moveBuildPlatePage
    property alias buttonMoveBuildPlatePage: buttonMoveBuildPlatePage

    property alias meshCalibration: meshCalibration
    property alias meshErrorScreen: meshErrorScreen
    property alias buttonMeshCalibration: buttonMeshCalibration

    enum SwipeIndex {
        BasePage,                   //0
        AssistedLevelingPage,       //1
        RaiseLowerBuildPlatePage,   //2
        MeshCalibrationPage         //3
    }

    LoggingStackLayout {
        id: buildPlateSettingsSwipeView
        logName: "buildPlateSettingsSwipeView"
        currentIndex: BuildPlateSettingsPage.BasePage

        // BuildPlateSettingsPage.BasePage
        Item {
            id: itemBuildPlateSettings
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: settingsPage.settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            property string topBarTitle: qsTr("Build Plate Settings")

            smooth: false

            FlickableMenu {
                id: flickableBuildPlateSettings
                contentHeight: columnBuildPlateSettings.height

                Column {
                    id: columnBuildPlateSettings
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MenuButton {
                        id: buttonAssistedLeveling
                        buttonImage.source: "qrc:/img/icon_assisted_leveling.png"
                        buttonText.text: qsTr("ASSISTED LEVELING")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonMoveBuildPlatePage
                        buttonImage.source: "qrc:/img/icon_raise_lower_bp.png"
                        buttonText.text: qsTr("RAISE/LOWER BUILD PLATE")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonMeshCalibration
                        buttonImage.source: "qrc:/img/icon_mesh.png"
                        buttonText.text: qsTr("MESH BED LEVELING")
                        enabled: !isProcessRunning()
                        slidingSwitch.checked: bot.meshCalEnabled
                        slidingSwitch.checkable: bot.meshCalAvailable
                        slidingSwitch.visible: true

                        slidingSwitch.onClicked: {
                            if (!bot.meshCalAvailable) {
                                buildPlateSettingsSwipeView.swipeToItem(
                                    BuildPlateSettingsPage.MeshCalibrationPage);
                            } else if (!slidingSwitch.checked) {
                                bot.enableMesh(false);
                            } else {
                                bot.enableMesh(true);
                            }
                        }
                    }
                }
            }
        }

        // BuildPlateSettingsPage.AssistedLevelingPage
        Item {
            id: itemAssistedLeveling
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: buildPlateSettingsSwipeView
            property int backSwipeIndex: BuildPlateSettingsPage.BasePage
            property string topBarTitle: qsTr("Assisted Leveling")
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    if(bot.process.type == ProcessType.AssistedLeveling) {
                        assistedLevel.cancelAssistedLevelingPopup.open()
                    }
                    else {
                        assistedLevel.state = "base state"
                        buildPlateSettingsSwipeView.swipeToItem(BuildPlateSettingsPage.BasePage)
                        assistedLevel.needsZCalFlag = false
                    }
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                bot.cancel()
                assistedLevel.state = "cancelling"
                buildPlateSettingsSwipeView.swipeToItem(BuildPlateSettingsPage.BasePage)
                settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            AssistedLeveling {
                id: assistedLevel
                currentHES: bot.process.currentHes
                targetHESLower: bot.process.targetHesLower
                targetHESUpper: bot.process.targetHesUpper

                onProcessDone: {
                    state = "base state"
                    buildPlateSettingsSwipeView.swipeToItem(BuildPlateSettingsPage.BasePage)
                }
            }
        }

        // BuildPlateSettingsPage.RaiseLowerBuildPlatePage
        Item {
            id: moveBuildPlatePageItem
            property var backSwiper: buildPlateSettingsSwipeView
            property int backSwipeIndex: BuildPlateSettingsPage.BasePage
            property string topBarTitle: qsTr("Raise/Lower Build Plate")
            smooth: false
            visible: false

            MoveBuildPlatePage {
                id: moveBuildPlatePage
            }
        }

        // BuildPlateSettingsPage.MeshCalibrationPage
        Item {
            id: meshCalibrationPageItem
            property var backSwiper: buildPlateSettingsSwipeView
            property int backSwipeIndex: BuildPlateSettingsPage.BasePage
            property string topBarTitle: qsTr("Calibrate Bed Mesh")
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if (meshCalibration.chooseMaterial) {
                    meshCalibration.chooseMaterial = false;
                } else if (bot.process.type == ProcessType.MeshCalibrationProcess) {
                    meshCalibration.cancelCalibrationPopup.open()
                } else if (meshCalibration.state == "install_build_plate") {
                    meshCalibration.state = "base state"
                } else if (meshCalibration.state == "secure_build_plate") {
                    meshCalibration.state = "install_build_plate"
                } else {
                    meshCalibration.state = "base state"
                    meshErrorScreen.acknowledgeError()
                    buildPlateSettingsSwipeView.swipeToItem(BuildPlateSettingsPage.BasePage)
                }
            }

            MeshCalibration {
                id: meshCalibration
                visible: !meshErrorScreen.visible
                onProcessDone: {
                    state = "base state"
                    if (meshErrorScreen.lastReportedErrorType == ErrorType.NoError) {
                        buildPlateSettingsSwipeView.swipeToItem(BuildPlateSettingsPage.BasePage)
                    }
                }
            }

            ErrorScreen {
                id: meshErrorScreen
                isActive: bot.process.type == ProcessType.MeshCalibrationProcess
                visible: {
                    lastReportedProcessType == ProcessType.MeshCalibrationProcess &&
                    lastReportedErrorType != ErrorType.NoError
                }
            }
        }
    }
}

