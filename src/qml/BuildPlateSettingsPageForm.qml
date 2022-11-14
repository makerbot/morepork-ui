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

    property alias buttonAssistedLeveling: buttonAssistedLeveling

    property alias buttonRaiseLowerBuildPlate: buttonRaiseLowerBuildPlate


    enum SwipeIndex {
        BasePage,
        RaiseLowerBuildPlatePage,
        AssistedLevelingPage
    }

    LoggingSwipeView {
        id: buildPlateSettingsSwipeView
        logName: "buildPlateSettingsSwipeView"
        currentIndex: BuildPlateSettingsPage.BasePage

        // BuildPlateSettingsPage.BasePage
        Item {
            id: itemBuildPlateSettings
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: settingsPage.settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage

            smooth: false

            Flickable {
                id: flickableBuildPlateSettings
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnBuildPlateSettings.height

                Column {
                    id: columnBuildPlateSettings
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MenuButton {
                        id: buttonRaiseLowerBuildPlate
                        buttonImage.source: "qrc:/img/icon_advanced_info.png"
                        buttonText.text: qsTr("RAISE/LOWER BUILD PLATE")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonAssistedLeveling
                        buttonImage.source: "qrc:/img/icon_assisted_leveling.png"
                        buttonText.text: qsTr("ASSISTED LEVELING")
                        enabled: !isProcessRunning()
                    }
                }
            }
        }

        // BuildPlateSettingsPage.RaiseLowerBuildPlatePage
        Item {
            id: raiseLowerBuildPlateItem
            property var backSwiper: buildPlateSettingsSwipeView
            property int backSwipeIndex: BuildPlateSettingsPage.BasePage
            smooth: false
            visible: false

            RaiseLowerBuildPlateItem {
                id: raiseLowerBuildPlate
            }
        }

        // BuildPlateSettingsPage.AssistedLevelingPage
        Item {
            id: itemAssistedLeveling
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: buildPlateSettingsSwipeView
            property int backSwipeIndex: BuildPlateSettingsPage.BasePage
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
                        if(buildPlateSettingsSwipeView.currentIndex != BuildPlateSettingsPage.BasePage) {
                            buildPlateSettingsSwipeView.swipeToItem(BuildPlateSettingsPage.BasePage)
                        }
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
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            AssistedLeveling {
                id: assistedLevel
                currentHES: bot.process.currentHes
                targetHESLower: bot.process.targetHesLower
                targetHESUpper: bot.process.targetHesUpper

                onProcessDone: {
                    state = "base state"
                    if(buildPlateSettingsSwipeView.currentIndex != BuildPlateSettingsPage.BasePage) {
                        buildPlateSettingsSwipeView.swipeToItem(BuildPlateSettingsPage.BasePage)
                    }
                }
            }
        }
    }
}

