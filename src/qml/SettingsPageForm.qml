import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0
import ErrorTypeEnum 1.0
import MachineTypeEnum 1.0

Item {
    id: settingsPage
    anchors.fill: parent
    property alias settingsSwipeView: settingsSwipeView

    property alias systemSettingsPage: systemSettingsPage
    property alias buttonSystemSettings: buttonSystemSettings

    property alias extruderSettingsPage: extruderSettingsPage
    property alias buttonExtruderSettings: buttonExtruderSettings

    property alias buildPlateSettingsPage: buildPlateSettingsPage
    property alias buttonBuildPlateSettings: buttonBuildPlateSettings

    property alias cleanAirSettingsPage: cleanAirSettingsPage
    property alias buttonCleanAirSettings: buttonCleanAirSettings

    property alias buttonPreheat: buttonPreheat

    property alias buttonDryMaterial: buttonDryMaterial

    property alias buttonAnnealPrint: buttonAnnealPrint

    property alias buttonShutdown: buttonShutdown
    property alias shutdownPopup: shutdownPopup

    property string lightBlue: "#3183af"
    property string otherBlue: "#45a2d3"


    smooth: false

    enum SwipeIndex {
        BasePage,               // 0
        SystemSettingsPage,     // 1
        ExtruderSettingsPage,   // 2
        BuildPlateSettingsPage, // 3
        CleanAirSettingsPage,   // 4
        ReplaceFilterPage,      // 5
        ReplaceFilterXLPage,    // 6
        PreheatPage,            // 7
        DryMaterialPage,        // 8
        AnnealPrintPage         // 9
    }

    LoggingSwipeView {
        id: settingsSwipeView
        logName: "settingsSwipeView"
        currentIndex: SettingsPage.BasePage

        // SettingsPage.BasePage
        Item {
            id: itemSettings
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: mainSwipeView
            property int backSwipeIndex: MoreporkUI.BasePage
            property string topBarTitle: qsTr("Settings")
            smooth: false

            Flickable {
                id: flickableSettings
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnSettings.height

                Column {
                    id: columnSettings
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MenuButton {
                        id: buttonSystemSettings
                        buttonImage.source: "qrc:/img/icon_system_settings.png"
                        buttonText.text: qsTr("SYSTEM SETTINGS")
                        openMenuItemArrow.visible: true
                    }

                    MenuButton {
                        id: buttonExtruderSettings
                        buttonImage.source: "qrc:/img/icon_extruder_settings.png"
                        buttonText.text: qsTr("EXTRUDER SETTINGS")
                        openMenuItemArrow.visible: true
                        onClicked: {
                            if(isProcessRunning()){
                                printerNotIdlePopup.open()
                            }
                        }
                    }

                    MenuButton {
                        id: buttonBuildPlateSettings
                        buttonImage.source: "qrc:/img/icon_build_plate_settings.png"
                        buttonText.text: qsTr("BUILD PLATE SETTINGS")
                        openMenuItemArrow.visible: true
                        onClicked: {
                            if(isProcessRunning()){
                                printerNotIdlePopup.open()
                            }
                        }
                    }

                    MenuButton {
                        id: buttonCleanAirSettings
                        buttonImage.source: "qrc:/img/hepa_filter.png"
                        buttonText.text: qsTr("CLEAN AIR SETTINGS")
                        buttonAlertImage.visible: bot.hepaFilterChangeRequired
                    }

                    MenuButton {
                        id: buttonPreheat
                        buttonImage.source: "qrc:/img/icon_preheat.png"
                        buttonText.text: qsTr("PREHEAT")
                        enabled: !isProcessRunning()
                        visible: bot.machineType != MachineType.Magma
                    }

                    MenuButton {
                        id: buttonDryMaterial
                        buttonImage.source: "qrc:/img/icon_material.png"
                        buttonText.text: qsTr("DRY MATERIAL")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonAnnealPrint
                        buttonImage.source: "qrc:/img/icon_anneal_print.png"
                        buttonText.text: qsTr("ANNEAL PRINT")
                        enabled: !isProcessRunning()
                        visible: bot.machineType != MachineType.Magma
                    }

                    MenuButton {
                        id: buttonShutdown
                        buttonImage.source: "qrc:/img/icon_power.png"
                        buttonText.text: qsTr("SHUT DOWN")
                    }
                }
            }
        }

        // SettingsPage.SystemSettingsPage
        Item {
            id: systemSettingsItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            property string topBarTitle: qsTr("System Settings")
            smooth: false
            visible: false

            SystemSettingsPage {
                id: systemSettingsPage
            }
        }

        // SettingsPage.ExtruderSettingsPage
        Item {
            id: extruderSettingsItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            property string topBarTitle: qsTr("Extruder Settings")
            smooth: false
            visible: false

            ExtruderSettingsPage {
                id: extruderSettingsPage
            }
        }

        // SettingsPage.BuildPlateSettingsPage
        Item {
            id: buildPlateSettingsItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            property string topBarTitle: qsTr("BuildPlate Settings")
            smooth: false
            visible: false

            BuildPlateSettingsPage {
                id: buildPlateSettingsPage
            }
        }

        // SettingsPage.CleanAirSettingsPage
        Item {
            id: cleanAirSettingsItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            property string topBarTitle: qsTr("Clean Air Settings")
            smooth: false
            visible: false

            CleanAirSettingsPage {
                id: cleanAirSettingsPage
            }
        }

        // SettingsPage.ReplaceFilterPage
        Item {
            id: replaceFilterItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.CleanAirSettingsPage
            property string topBarTitle: qsTr("Replace Filter")
            smooth: false
            visible: false

            property bool hasAltBack: true

            function altBack() {
                if (replaceFilterPage.itemReplaceFilter.state == "done")
                    settingsSwipeView.swipeToItem(SettingsPage.CleanAirSettingsPage)
                else if (replaceFilterPage.itemReplaceFilter.state == "step_2")
                    replaceFilterPage.itemReplaceFilter.state = "done"
                else if (replaceFilterPage.itemReplaceFilter.state == "step_3")
                    replaceFilterPage.itemReplaceFilter.state = "step_2"
                else if (replaceFilterPage.itemReplaceFilter.state == "step_4")
                    replaceFilterPage.itemReplaceFilter.state = "step_3"
                else
                    settingsSwipeView.swipeToItem(SettingsPage.CleanAirSettingsPage)
            }

            ReplaceFilterPage {
                id: replaceFilterPage
            }
        }

        // SettingsPage.ReplaceFilterXLPage
        Item {
            id: replaceFilterXLItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.CleanAirSettingsPage
            property string topBarTitle: qsTr("Replace Filter")
            property bool backIsCancel: (replaceFilterXLPage.itemReplaceFilterXL.state == "moving_build_plate") ||
                                        (replaceFilterXLPage.itemReplaceFilterXL.state == "done" &&
                                         replaceFilterXLPage.isBuildPlateRaised)
            smooth: false
            visible: false

            property bool hasAltBack: true

            function altBack() {
                replaceFilterXLPage.goBack()

            }

            ReplaceFilterXLPage {
                id: replaceFilterXLPage
            }
        }

        // SettingsPage.PreheatPage
        Item {
            id: preheatItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            property string topBarTitle: qsTr("Preheat")
            smooth: false
            visible: false

            PreheatPage {

            }
        }

        // SettingsPage.DryMaterialPage
        Item {
            id: dryMaterialItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            property string topBarTitle: qsTr("Dry Material")
            property bool hasAltBack: true
            property bool backIsCancel: bot.process.type == ProcessType.DryingCycleProcess &&
                                        dryMaterial.state != "choose_material" &&
                                        dryMaterial.state != "custom_material" &&
                                        dryMaterial.state != "waiting_for_spool" &&
                                        dryMaterial.state != "dry_kit_instructions_2"
            smooth: false
            visible: false

            function altBack() {
                if(bot.process.type == ProcessType.DryingCycleProcess) {
                    if(dryMaterial.state == "choose_material") {
                        dryMaterial.state = "waiting_for_spool"
                        dryMaterial.doChooseMaterial = false
                    }
                    else if(dryMaterial.state == "custom_material")
                        dryMaterial.state = "choose_material"
                    else if(dryMaterial.state == "waiting_for_spool")
                        dryMaterial.state = "dry_kit_instructions_2"
                    else if(dryMaterial.state == "dry_kit_instructions_2")
                        dryMaterial.state = "dry_kit_instructions_1"
                    else
                        dryMaterial.cancelDryingCyclePopup.open()
                } else {
                    dryMaterial.state = "base state"
                    settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                }
            }

            DryMaterial {
                id: dryMaterial
                onProcessDone: {
                    state = "base state"
                    settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                }
            }
        }

        // SettingsPage.AnnealPrintPage
        Item {
            id: annealPrintItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            property string topBarTitle: qsTr("Anneal Print")
            property bool hasAltBack: true
            property bool backIsCancel: bot.process.type == ProcessType.AnnealPrintProcess
            smooth: false
            visible: false

            function altBack() {
                if(bot.process.type == ProcessType.AnnealPrintProcess) {
                    bot.cancel()
                    annealPrint.state = "cancelling"
                } else {
                    annealPrint.state = "base state"
                    settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                }
            }

            AnnealPrint {
                id: annealPrint
                onProcessDone: {
                    state = "base state"
                    settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                }
            }
        }
    }


    CustomPopup {
        popupName: "Shutdown"
        id: shutdownPopup
        popupWidth: 715
        popupHeight: 275
        visible: false
        showTwoButtons: true
        left_button_text: qsTr("BACK")
        right_button_text: qsTr("CONFIRM")
        right_button.onClicked: {
            bot.shutdown()
        }

        left_button.onClicked: {
            shutdownPopup.close()
        }

        ColumnLayout {
            id: columnLayout_shutdown_popup
            width: 650
            height: children.height
            spacing: 20
            anchors.top: parent.top
            anchors.topMargin: 125
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                width: 63
                height: 63
                source: "qrc:/img/extruder_material_error.png"
                Layout.alignment: Qt.AlignHCenter
            }

            TextHeadline {
                text: qsTr("SHUT DOWN?")
                font.weight: Font.Bold
                font.styleName: "Normal"
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
