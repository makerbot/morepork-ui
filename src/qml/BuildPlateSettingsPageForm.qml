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

    enum SwipeIndex {
        BasePage,                   //0
        AssistedLevelingPage,       //1
        RaiseLowerBuildPlatePage    //2
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

        // BuildPlateSettingsPage.MoveBuildPlatePage
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
    }
}

