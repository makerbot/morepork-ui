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

    property alias buttonDeauthorizeAccounts: buttonDeauthorizeAccounts
    property alias deauthorizeAccountsPopup: deauthorizeAccountsPopup

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
                        buttonImage.source: "qrc:/img/icon_name_printer.png"
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
                        buttonText.text: qsTr("AUTHORIZE MAKERBOT ACCOUNT")
                    }

                    MenuButton {
                        id: buttonDeauthorizeAccounts
                        buttonImage.source: "qrc:/img/icon_deauthorize_accounts.png"
                        buttonText.text: qsTr("DEAUTHORIZE MAKERBOT ACCOUNTS")
                    }

                    MenuButton {
                        id: buttonFirmwareUpdate
                        buttonImage.source: "qrc:/img/icon_software_update.png"
                        buttonText.text: qsTr("FIRMWARE UPDATE")
                        buttonNeedsAction: isfirmwareUpdateAvailable
                    }

                    MenuButton {
                        id: buttonCalibrateToolhead
                        buttonImage.source: "qrc:/img/icon_calibrate_toolhead.png"
                        buttonText.text: qsTr("CALIBRATE EXTRUDERS")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonChangeLanguage
                        buttonImage.source: "qrc:/img/icon_change_language.png"
                        buttonText.text: qsTr("CHANGE LANGUAGE")
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
                        alertImage: "qrc:/img/filter_change_required.png"
                        buttonNeedsAction: bot.hepaFilterChangeRequired
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

    LoggingPopup {
        popupName: "DeauthorizeAccounts"
        id: deauthorizeAccountsPopup
        width: 800
        height: 480
        modal: true
        dim: false
        focus: true
        parent: overlay
        closePolicy: Popup.NoAutoClose
        background: Rectangle {
            id: popupBackgroundDim_deauth_accounts
            color: "#000000"
            rotation: rootItem.rotation == 180 ? 180 : 0
            opacity: 0.5
            anchors.fill: parent
        }
        enter: Transition {
            NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.InQuad; from: 0.0; to: 1.0 }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.InQuad; from: 1.0; to: 0.0 }
        }

        onClosed: {
            clearingAccounts = false
        }

        property bool clearingAccounts: false

        Rectangle {
            id: basePopupItem_deauth_accounts
            color: "#000000"
            rotation: rootItem.rotation == 180 ? 180 : 0
            width: 720
            height: 265
            radius: 10
            border.width: 2
            border.color: "#ffffff"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                id: horizontal_divider_deauth_accounts
                width: 720
                height: 2
                color: "#ffffff"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 72
                visible: !deauthorizeAccountsPopup.clearingAccounts
            }

            Rectangle {
                id: vertical_divider_deauth_accounts
                x: 359
                y: 328
                width: 2
                height: 72
                color: "#ffffff"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !deauthorizeAccountsPopup.clearingAccounts
            }

            Item {
                id: buttonBar_deauth_accounts
                width: 720
                height: 72
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                visible: !deauthorizeAccountsPopup.clearingAccounts

                Rectangle {
                    id: remove_accounts_rectangle_deauth_accounts
                    x: 0
                    y: 0
                    width: 360
                    height: 72
                    color: "#00000000"
                    radius: 10

                    Text {
                        id: remove_accounts_text_deauth_accounts
                        color: "#ffffff"
                        text: qsTr("REMOVE ACCOUNTS")
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: false
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: defaultFont.name
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    LoggingMouseArea {
                        logText: "deauth_accounts: [_" + remove_accounts_text_deauth_accounts.text + "|]"
                        id: remove_accounts_mouseArea_deauth_accounts
                        anchors.fill: parent
                        onPressed: {
                            remove_accounts_text_deauth_accounts.color = "#000000"
                            remove_accounts_rectangle_deauth_accounts.color = "#ffffff"
                        }
                        onReleased: {
                            remove_accounts_text_deauth_accounts.color = "#ffffff"
                            remove_accounts_rectangle_deauth_accounts.color = "#00000000"
                        }
                        onClicked: {
                            bot.deauthorizeAllAccounts()
                            deauthorizeAccountsPopup.clearingAccounts = true
                            closeDeauthorizeAccountsPopupTimer.start()
                        }
                    }
                }

                Rectangle {
                    id: cancel_rectangle_deauth_accounts
                    x: 360
                    y: 0
                    width: 360
                    height: 72
                    color: "#00000000"
                    radius: 10

                    Text {
                        id: cancel_text_deauth_accounts
                        color: "#ffffff"
                        text: qsTr("CANCEL")
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: defaultFont.name
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    LoggingMouseArea {
                        logText: "deauth_accounts: [|" + cancel_text_deauth_accounts.text + "_]"
                        id: cancel_mouseArea_deauth_accounts
                        anchors.fill: parent
                        onPressed: {
                            cancel_text_deauth_accounts.color = "#000000"
                            cancel_rectangle_deauth_accounts.color = "#ffffff"
                        }
                        onReleased: {
                            cancel_text_deauth_accounts.color = "#ffffff"
                            cancel_rectangle_deauth_accounts.color = "#00000000"
                        }
                        onClicked: {
                            deauthorizeAccountsPopup.close()
                        }
                    }
                }
            }

            ColumnLayout {
                id: columnLayout_deauth_accounts
                width: 590
                height: 160
                spacing: 0
                anchors.top: parent.top
                anchors.topMargin: deauthorizeAccountsPopup.clearingAccounts ? 50 : 25
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: alert_text_deauth_accounts
                    color: "#cbcbcb"
                    text: deauthorizeAccountsPopup.clearingAccounts ? qsTr("ALL ACCOUNTS DEAUTHORIZED") : qsTr("DEAUTHORIZE ACCOUNTS")
                    font.letterSpacing: 3
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: defaultFont.name
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Item {
                    id: emptyItem_deauth_accounts
                    width: 10
                    height: 5
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    visible: !deauthorizeAccountsPopup.clearingAccounts
                }

                Text {
                    id: description_text_deauth_accounts
                    color: "#cbcbcb"
                    text: qsTr("Deauthorize all accounts currently connected to this printer? You will have to reauthorize any account you wish to connect in the future.")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.weight: Font.Light
                    wrapMode: Text.WordWrap
                    font.family: defaultFont.name
                    font.pixelSize: 18
                    lineHeight: 1.3
                    visible: !deauthorizeAccountsPopup.clearingAccounts
                }
            }
        }
    }
}
