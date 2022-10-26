import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0
import ErrorTypeEnum 1.0

Item {
    id: settingsPage
    property alias settingsSwipeView: settingsSwipeView
    property alias advancedSettingsPage: advancedSettingsPage
    property alias cleanAirSettingsPage: cleanAirSettingsPage

    property alias buttonPrinterInfo: buttonPrinterInfo

    property alias buttonChangePrinterName: buttonChangePrinterName
    property alias namePrinter: namePrinter

    property alias buttonWiFi: buttonWiFi
    property alias koreaDFSScreen: koreaDFSScreen

    property alias buttonAuthorizeAccounts: buttonAuthorizeAccounts
    property alias authorizeAccountPage: authorizeAccountPage

    property alias buttonFirmwareUpdate: buttonFirmwareUpdate
    property alias firmwareUpdatePage: firmwareUpdatePage

    property alias buttonCalibrateToolhead: buttonCalibrateToolhead
    property alias calibrateErrorScreen: calibrateErrorScreen

    property alias buttonChangeLanguage: buttonChangeLanguage
    property alias languageSelector: languageSelectorPage

    property alias buttonTime: buttonTime
    property alias timePage: timePage

    property alias buttonAdvancedSettings: buttonAdvancedSettings

    property alias buttonCleanAirSettings: buttonCleanAirSettings

    property alias buttonShutdown: buttonShutdown
    property alias shutdownPopup: shutdownPopup

    property alias wifiPage: wifiPage
    property string lightBlue: "#3183af"
    property string otherBlue: "#45a2d3"

    smooth: false

    enum SwipeIndex {
        BasePage,                   // 0
        PrinterInfoPage,            // 1
        ChangePrinterNamePage,      // 2
        WifiPage,                   // 3
        AuthorizeAccountsPage,      // 4
        FirmwareUpdatePage,         // 5
        CalibrateExtrudersPage,     // 6
        TimePage,                   // 7
        AdvancedSettingsPage,       // 8
        ChangeLanguagePage,         // 9
        KoreaDFSSecretPage,         // 10
        CleanAirSettingsPage
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
                        id: buttonPrinterInfo
                        buttonImage.source: "qrc:/img/icon_printer_info.png"
                        buttonText.text: qsTr("PRINTER INFO")
                    }

                    MenuButton {
                        id: buttonChangePrinterName
                        buttonImage.source: "qrc:/img/icon_change_printer_name.png"
                        buttonText.text: qsTr("CHANGE PRINTER NAME")
                    }

                    MenuButton {
                        id: buttonWiFi
                        buttonImage.source: "qrc:/img/icon_wifi.png"
                        buttonText.text: qsTr("WiFi")

                        SlidingSwitch {
                            id: switchWifi
                            checked: bot.net.wifiEnabled
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 50

                            onClicked: {
                                if(switchWifi.checked) {
                                    bot.toggleWifi(true)
                                }
                                else if(!switchWifi.checked) {
                                    bot.toggleWifi(false)
                                }
                            }
                        }
                    }

                    MenuButton {
                        id: buttonAuthorizeAccounts
                        buttonImage.source: "qrc:/img/icon_authorize_account.png"
                        buttonText.text: qsTr("ACCOUNT AUTHORIZATION")
                    }

                    MenuButton {
                        id: buttonFirmwareUpdate
                        buttonImage.source: "qrc:/img/icon_software_update.png"
                        buttonText.text: qsTr("FIRMWARE UPDATE")
                        buttonAlertImage.visible: isfirmwareUpdateAvailable
                    }

                    MenuButton {
                        id: buttonCalibrateToolhead
                        buttonImage.source: "qrc:/img/icon_calibrate_toolhead.png"
                        buttonText.text: qsTr("CALIBRATE EXTRUDERS")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonChangeLanguage
                        buttonImage.source: "qrc:/img/icon_choose_language.png"
                        buttonText.text: qsTr("CHOOSE LANGUAGE")
                    }

                    MenuButton {
                        id: buttonTime
                        buttonImage.source: "qrc:/img/icon_time_and_date.png"
                        buttonText.text: qsTr("TIME AND DATE")
                    }

                    MenuButton {
                        id: buttonAdvancedSettings
                        buttonImage.source: "qrc:/img/icon_preheat.png"
                        buttonText.text: qsTr("ADVANCED")
                    }

                    MenuButton {
                        id: buttonCleanAirSettings
                        buttonImage.source: "qrc:/img/hepa_filter.png"
                        buttonImage.anchors.leftMargin: 30
                        buttonText.text: qsTr("CLEAN AIR SETTINGS")
                        buttonText.anchors.leftMargin: 38
                        buttonAlertImage.visible: bot.hepaFilterChangeRequired
                    }


                    MenuButton {
                        id: buttonShutdown
                        buttonImage.source: "qrc:/img/icon_power.png"
                        buttonText.text: qsTr("SHUT DOWN")
                    }
                }
            }
        }

        // SettingsPage.PrinterInfoPage
        Item {
            id: printerInfoItem
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            smooth: false
            visible: false

            InfoPage {

            }
        }

        // SettingsPage.ChangePrinterNamePage
        Item {
            id: namePrinterItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                namePrinter.nameField.clear()
                if(!inFreStep) {
                    settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            NamePrinterPage {
                id: namePrinter
            }
        }

        // SettingsPage.WifiPage
        Item {
            id: wifiItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            smooth: false
            visible: false
            property bool hasAltBack: true

            function altBack() {
                if(!inFreStep) {
                    settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            WiFiPage {
                id: wifiPage

            }
        }

        // SettingsPage.AuthorizeAccountsPage
        Item {
            id: accountsItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                authorizeAccountPage.backToSettings()
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            AuthorizeAccountPage {
                id: authorizeAccountPage
            }
        }

        // SettingsPage.FirmwareUpdatePage
        Item {
            id: firmwareUpdateItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            property bool hasAltBack: true
            property alias firmwareUpdatePage: firmwareUpdatePage
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    if(firmwareUpdatePage.state == "install_from_usb") {
                        if(isfirmwareUpdateAvailable) {
                            firmwareUpdatePage.state = "firmware_update_available"
                        }
                        else {
                            firmwareUpdatePage.state = "no_firmware_update_available"
                        }
                    }
                    else if (firmwareUpdatePage.state == "select_firmware_file") {
                        var backDir = storage.backStackPop()
                        if(backDir !== "") {
                            storage.updateFirmwareFileList(backDir)
                        }
                        else {
                            firmwareUpdatePage.state = "install_from_usb"
                        }
                    }
                    else if (firmwareUpdatePage.state == "firmware_update_failed") {
                        firmwareUpdatePage.state = "no_firmware_update_available"
                        settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                    }
                    else {
                        settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                    }
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                bot.cancel()
                settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            FirmwareUpdatePage {
                id: firmwareUpdatePage

            }
        }

        // SettingsPage.CalibrateExtrudersPage
        Item {
            id: calibrateToolheadsItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
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
                        toolheadCalibration.resetStates()
                    }
                }
                else {
                    if(calibrateErrorScreen.lastReportedErrorType ==
                                                        ErrorType.NoError) {
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
                settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            ToolheadCalibration {
                id: toolheadCalibration
                visible: !calibrateErrorScreen.visible
                onProcessDone: {
                    resetStates()
                }

                function resetStates() {
                    state = "base state"
                    // Dont go back if an error happened
                    if(calibrateErrorScreen.lastReportedErrorType ==
                                                        ErrorType.NoError) {
                        if(settingsSwipeView.currentIndex != SettingsPage.BasePage) {
                            settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                        }
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

        // SettingsPage.TimePage
        Item {
            id: timeItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            TimePage {
                id: timePage

            }
        }

        // SettingsPage.AdvancedSettingsPage
        Item {
            id: advancedSettingsItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            smooth: false
            visible: false

            AdvancedSettingsPage {
                id: advancedSettingsPage
            }
        }

        // SettingsPage.ChangeLanguagePage
        Item {
            id: changeLanguageItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            smooth: false
            visible: false

            LanguageSelector {
                id: languageSelectorPage
            }
        }

        // SettingsPage.KoreaDFSSecretPage
        Item {
            id: koreaDFSScreenItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            smooth: false
            visible: false

            KoreaDFSScreenForm {
                id: koreaDFSScreen
            }
        }

        // SettingsPage.CleanAirSettingsPage
        Item {
            id: cleanAirSettingsItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            smooth: false
            visible: false

            CleanAirSettingsPageForm {
                id: cleanAirSettingsPage
            }
        }
    }

    Timer {
        id: closeDeauthorizeAccountsPopupTimer
        interval: 1500
        onTriggered: deauthorizeAccountsPopup.close()
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
