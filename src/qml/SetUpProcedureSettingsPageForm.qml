import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.12
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0
import ErrorTypeEnum 1.0

Item {
    id: setUpProcedureSettingsPage
    smooth: false
    anchors.fill: parent

    property alias setUpProcedureSettingsSwipeView: setUpProcedureSettingsSwipeView
    property alias buttonSetupGuide: buttonSetupGuide
    property alias buttonMaterialCase: buttonMaterialCase

    enum SwipeIndex {
        BasePage,               //0
        MaterialCaseSetup       //1
    }

    LoggingSwipeView {
        id: setUpProcedureSettingsSwipeView
        logName: "setUpProcedureSettingsSwipeView"
        currentIndex: SetUpProcedureSettingsPage.BasePage

        // SetUpProcedureSettingsPage.BasePage
        Item {
            id: itemSetUpProcedureSettings
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            property string topBarTitle: qsTr("Set Up Procedure Settings")
            smooth: false

            Flickable {
                id: flickableSetUpProcedureSettings
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnSetUpProcedureSettings.height

                Column {
                    id: columnSetUpProcedureSettings
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MenuButton {
                        id: buttonSetupGuide
                        buttonImage.visible: false
                        buttonText.text: qsTr("METHOD XL SET UP GUIDE")
                    }

                    MenuButton {
                        id: buttonMaterialCase
                        buttonImage.visible: false
                        buttonText.text: qsTr("MATERIAL CASE SET UP")
                        enabled: !isProcessRunning()
                    }
                }
            }
        }

        // SetUpProcedureSettingsPage.MaterialCaseSetup
        Item {
            id: materialCaseSetupItem
            property var backSwiper: setUpProcedureSettingsSwipeView
            property int backSwipeIndex: SetUpProcedureSettingsPage.BasePage
            property string topBarTitle: qsTr("Material Case Set Up")
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if (materialCaseSetup.state == "remove_divider") {
                    materialCaseSetup.state = "tube_2"
                } else if (materialCaseSetup.state == "tube_2") {
                    materialCaseSetup.state = "tube_1_printer"
                } else if (materialCaseSetup.state == "tube_1_printer") {
                    materialCaseSetup.state = "tube_1_case"
                } else if (materialCaseSetup.state == "tube_1_case") {
                    materialCaseSetup.state = "intro_2"
                } else if (materialCaseSetup.state == "intro_2") {
                    materialCaseSetup.state = "intro_1"
                } else {
                    setUpProcedureSettingsSwipeView.swipeToItem(SetUpProcedureSettingsPage.BasePage)
                    if (inFreStep) {
                        systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
                        settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                        mainSwipeView.swipeToItem(MoreporkUI.BasePage)
                        inFreStep = false
                    }
                }
            }

            MaterialCaseSetup {
                id: materialCaseSetup
            }
        }
    }
}


