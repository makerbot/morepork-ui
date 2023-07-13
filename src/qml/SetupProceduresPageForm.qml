import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.12
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0
import ErrorTypeEnum 1.0

Item {
    id: setupProceduresPage
    smooth: false
    anchors.fill: parent

    property alias setupProceduresSwipeView: setupProceduresSwipeView
    property alias buttonSetupGuide: buttonSetupGuide
    property alias buttonMaterialCase: buttonMaterialCase

    enum SwipeIndex {
        BasePage,               //0
        MaterialCaseSetup       //1
    }

    LoggingSwipeView {
        id: setupProceduresSwipeView
        logName: "setupProceduresSwipeView"
        currentIndex: SetupProceduresPage.BasePage

        // SetupProceduresPage.BasePage
        Item {
            id: itemSetupProcedures
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            property string topBarTitle: qsTr("Setup Procedures")
            smooth: false

            Flickable {
                id: flickableSetupProcedures
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnSetupProcedures.height

                Column {
                    id: columnSetupProcedures
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

        // SetupProceduresPage.MaterialCaseSetup
        Item {
            id: materialCaseSetupItem
            property var backSwiper: setupProceduresSwipeView
            property int backSwipeIndex: SetupProceduresPage.BasePage
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
                    setupProceduresSwipeView.swipeToItem(SetupProceduresPage.BasePage)
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


