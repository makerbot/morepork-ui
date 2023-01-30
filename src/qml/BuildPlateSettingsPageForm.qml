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

    property alias raiseLowerBuildPlate: raiseLowerBuildPlate
    property alias doorOpenRaiseLowerBuildPlatePopup: doorOpenRaiseLowerBuildPlatePopup

    enum SwipeIndex {
        BasePage,                   //0
        AssistedLevelingPage,       //1
        RaiseLowerBuildPlatePage    //2
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
                        id: buttonAssistedLeveling
                        buttonImage.source: "qrc:/img/icon_assisted_leveling.png"
                        buttonText.text: qsTr("ASSISTED LEVELING")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonRaiseLowerBuildPlate
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
            id: raiseLowerBuildPlateItem
            property var backSwiper: buildPlateSettingsSwipeView
            property int backSwipeIndex: BuildPlateSettingsPage.BasePage
            smooth: false
            visible: false

            RaiseLowerBuildPlate {
                id: raiseLowerBuildPlate
            }
        }
    }

    CustomPopup {
        popupName: "DoorOpenRaiseLowerBuildPlate"
        id: doorOpenRaiseLowerBuildPlatePopup
        showOneButton: true
        full_button.onClicked: doorOpenRaiseLowerBuildPlatePopup.close()
        full_button_text: qsTr("CONFIRM")

        ColumnLayout {
            spacing: 10
            anchors.top: parent.top
            anchors.topMargin: 125
            anchors.horizontalCenter: parent.horizontalCenter
            Image {
                source: "qrc:/img/process_error_small.png"
                Layout.alignment: Qt.AlignHCenter
            }
            TextHeadline {
                text: qsTr("FRONT DOOR OPEN")
                Layout.alignment: Qt.AlignHCenter
            }
            TextBody {
                text: qsTr("Close the front door to proceed.")
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}

