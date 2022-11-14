import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0

Item {
    id: advancedSettingsPage
    smooth: false
    anchors.fill: parent

    property alias advancedSettingsSwipeView: advancedSettingsSwipeView

    property alias buttonPrinterInfo: buttonPrinterInfo

    property alias buttonAdvancedInfo: buttonAdvancedInfo

    property alias wifiPage: wifiPage
    property alias buttonWiFi: buttonWiFi
    property alias koreaDFSScreen: koreaDFSScreen

    property alias buttonAuthorizeAccounts: buttonAuthorizeAccounts
    property alias authorizeAccountPage: authorizeAccountPage

    property alias buttonFirmwareUpdate: buttonFirmwareUpdate
    property alias firmwareUpdatePage: firmwareUpdatePage

    property alias buttonCopyLogs: buttonCopyLogs

    property alias copyingLogsPopup: copyingLogsPopup

    property alias buttonAnalytics: buttonAnalytics

    property alias buttonChangePrinterName: buttonChangePrinterName
    property alias namePrinter: namePrinter

    property alias buttonTime: buttonTime
    property alias timePage: timePage

    property alias buttonChangeLanguage: buttonChangeLanguage
    property alias languageSelector: languageSelectorPage

    property alias spoolInfoPage: spoolInfoPage
    property alias buttonSpoolInfo: buttonSpoolInfo

    property alias buttonColorSwatch: buttonColorSwatch

    property alias buttonTouchTest: buttonTouchTest

    property bool isResetting: false
    property alias buttonResetToFactory: buttonResetToFactory
    property alias resetToFactoryPopup: resetToFactoryPopup
    property bool isFactoryResetProcess: bot.process.type === ProcessType.FactoryResetProcess
    property bool doneFactoryReset: bot.process.type === ProcessType.FactoryResetProcess &&
                                    bot.process.stateType === ProcessStateType.Done

    property string lightBlue: "#3183af"
    property string otherBlue: "#45a2d3"

    Timer {
        id: closeResetPopupTimer
        interval: 2500
        onTriggered: {
            resetToFactoryPopup.close()
            // Reset all screen positions
            if(settingsPage.settingsSwipeView.currentIndex != SettingsPage.BasePage) {
                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.BasePage)
            }
            if(settingsPage.advancedSettingsPage.advancedSettingsSwipeView.currentIndex != AdvancedSettingsPage.BasePage) {
                settingsPage.advancedSettingsPage.advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.BasePage)
            }
            if(advancedPage.advancedSettingsSwipeView.currentIndex != AdvancedSettingsPage.BasePage) {
                advancedPage.advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.BasePage)
            }
            if(mainSwipeView.currentIndex != MoreporkUI.BasePage) {
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }
            fre.setFreStep(FreStep.Welcome)
            settings.resetPreferences()
        }
    }

    onIsFactoryResetProcessChanged: {
        if(isFactoryResetProcess){
            isResetting = true
            resetToFactoryPopup.open()
        }
    }

    onDoneFactoryResetChanged: {
        if(doneFactoryReset) {
            closeResetPopupTimer.start()
        }
    }

    enum SwipeIndex {
        BasePage,
        PrinterInfoPage,
        AdvancedInfoPage,
        WifiPage,
        AuthorizeAccountsPage,
        FirmwareUpdatePage,
        // Setup?

        ShareAnalyticsPage,
        ChangePrinterNamePage,
        TimePage,
        ChangeLanguagePage,
        SpoolInfoPage,              // 4
        ColorSwatchPage,
        TouchTestPage,
        // move

        KoreaDFSSecretPage
    }

    LoggingSwipeView {
        id: advancedSettingsSwipeView
        logName: "advancedSettingsSwipeView"
        currentIndex: AdvancedSettingsPage.BasePage

        // AdvancedSettingsPage.BasePage
        Item {
            id: itemAdvancedSettings
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: {
                /*if(mainSwipeView.currentIndex == MoreporkUI.AdvancedPage) {
                    mainSwipeView
                }
                else*/
                if(mainSwipeView.currentIndex == MoreporkUI.SettingsPage) {
                    settingsPage.settingsSwipeView
                }
                else {
                    mainSwipeView
                }
            }
            property int backSwipeIndex: {
                /*if(mainSwipeView.currentIndex == MoreporkUI.AdvancedPage) {
                    MoreporkUI.BasePage
                }
                else*/
                if(mainSwipeView.currentIndex == MoreporkUI.SettingsPage) {
                    SettingsPage.BasePage
                }
                else {
                    MoreporkUI.BasePage
                }
            }

            smooth: false

            Flickable {
                id: flickableAdvancedSettings
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnAdvancedSettings.height

                Column {
                    id: columnAdvancedSettings
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
                        id: buttonAdvancedInfo
                        buttonImage.source: "qrc:/img/icon_printer_info.png"
                        buttonText.text: qsTr("SENSOR INFO")
                    }

                    MenuButton {
                        id: buttonWiFi
                        buttonImage.source: "qrc:/img/icon_wifi.png"
                        buttonText.text: qsTr("WIFI AND NETWORK")

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
                        openMenuItemArrow.visible: true
                    }

                    MenuButton {
                        id: buttonFirmwareUpdate
                        buttonImage.source: "qrc:/img/icon_software_update.png"
                        buttonText.text: qsTr("FIRMWARE UPDATE")
                        buttonAlertImage.visible: isfirmwareUpdateAvailable
                    }

                    MenuButton {
                        id: buttonCopyLogs
                        buttonImage.source: "qrc:/img/icon_copy_logs.png"
                        buttonText.text: qsTr("COPY LOGS TO USB")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonAnalytics
                        buttonImage.source: "qrc:/img/icon_analytics.png"
                        buttonText.text: qsTr("ANALYTICS")
                    }

                    MenuButton {
                        id: buttonChangePrinterName
                        buttonImage.source: "qrc:/img/icon_change_printer_name.png"
                        buttonText.text: qsTr("CHANGE PRINTER NAME")
                    }

                    MenuButton {
                        id: buttonTime
                        buttonImage.source: "qrc:/img/icon_time.png"
                        buttonText.text: qsTr("TIME AND DATE")
                    }

                    MenuButton {
                        id: buttonSupportMode
                        buttonImage.source: "qrc:/img/icon_time.png"
                        buttonText.text: qsTr("SHOW CURRENT TIME")

                        SlidingSwitch {
                            id: switchToggleSupportMode
                            checked: settings.getDateTimeTextEnabled()
                            enabled: parent.enabled
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 50
                            onClicked: {
                                if(switchToggleSupportMode.checked) {
                                    settings.setDateTimeTextEnabled(true)
                                    setDateTimeTextVisible(true)
                                }
                                else if(!switchToggleSupportMode.checked) {
                                    settings.setDateTimeTextEnabled(false)
                                    setDateTimeTextVisible(false)
                                }
                            }
                        }
                    }

                    MenuButton {
                        id: buttonChangeLanguage
                        buttonImage.source: "qrc:/img/icon_choose_language.png"
                        buttonText.text: qsTr("CHOOSE LANGUAGE")
                    }

                    MenuButton {
                        id: buttonSpoolInfo
                        buttonImage.source: "qrc:/img/icon_advanced_info.png"
                        buttonText.text: qsTr("SPOOL INFO")
                        visible: false
                    }

                    MenuButton {
                        id: buttonColorSwatch
                        buttonImage.source: "qrc:/img/icon_advanced_info.png"
                        buttonText.text: qsTr("COLOR SWATCH")
                        visible: false
                    }

                    MenuButton {
                        id: buttonTouchTest
                        buttonImage.source: "qrc:/img/icon_advanced_info.png"
                        buttonText.text: qsTr("DISPLAY TOUCH TEST")
                    }

                    MenuButton {
                        id: buttonResetToFactory
                        buttonImage.anchors.leftMargin: 23
                        buttonImage.source: "qrc:/img/icon_factory_reset.png"
                        buttonText.text: qsTr("RESTORE FACTORY SETTINGS")
                        enabled: !isProcessRunning()
                    }
                }
            }
        }

        // AdvancedSettingsPage.PrinterInfoPage
        Item {
            id: printerInfoItem
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: AdvancedSettingsPage.BasePage
            smooth: false
            visible: false

            InfoPage {

            }
        }

        // AdvancedSettingsPage.AdvancedInfoPage
        Item {
            id: advancedInfoItem
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: AdvancedSettingsPage.BasePage
            smooth: false
            visible: false

            AdvancedInfo {

            }
        }

        // AdvancedSettingsPage.WifiPage
        Item {
            id: wifiItem
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: AdvancedSettingsPage.BasePage
            smooth: false
            visible: false
            property bool hasAltBack: true

            function altBack() {
                if(!inFreStep) {
                    advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.BasePage)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            WiFiPage {
                id: wifiPage

            }
        }

        // AdvancedSettingsPage.AuthorizeAccountsPage
        Item {
            id: accountsItem
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: AdvancedSettingsPage.BasePage
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.BasePage)
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


        // AdvancedSettingsPage.FirmwareUpdatePage
        Item {
            id: firmwareUpdateItem
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: AdvancedSettingsPage.BasePage
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
                        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.BasePage)
                    }
                    else {
                        advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.BasePage)
                    }
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                bot.cancel()
                advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            FirmwareUpdatePage {
                id: firmwareUpdatePage
            }
        }

        // AdvancedSettingsPage.ShareAnalyticsPage
        Item {
            id: analyticsItem
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: AdvancedSettingsPage.BasePage
            smooth: false
            visible: false

            AnalyticsScreen {
                id: analyticsScreen
            }
        }

        // AdvancedSettingsPage.ChangePrinterNamePage
        Item {
            id: namePrinterItem
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: AdvancedSettingsPage.BasePage
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                namePrinter.nameField.clear()
                if(!inFreStep) {
                    advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.BasePage)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            NamePrinterPage {
                id: namePrinter
            }
        }

        // AdvancedSettingsPage.TimePage
        Item {
            id: timeItem
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: AdvancedSettingsPage.BasePage
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.BasePage)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            TimePage {
                id: timePage
            }
        }

        // AdvancedSettingsPage.ChangeLanguagePage
        Item {
            id: changeLanguageItem
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: AdvancedSettingsPage.BasePage
            smooth: false
            visible: false

            LanguageSelector {
                id: languageSelectorPage
            }
        }

        // AdvancedSettingsPage.SpoolInfoPage
        Item {
            id: spoolInfoItem
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: AdvancedSettingsPage.BasePage
            smooth: false
            visible: false

            SpoolInfoPage {
                id: spoolInfoPage
            }
        }

        // AdvancedSettingsPage.ColorSwatchPage
        Item {
            id: colorSwatchItem
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: AdvancedSettingsPage.BasePage
            smooth: false
            visible: false

            ColorSwatchPage {
                id: colorSwatch
            }
        }

        // AdvancedSettingsPage.TouchTestPage
        Item {
            id: touchTestItem
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: AdvancedSettingsPage.BasePage
            property bool hasAltBack: true
            smooth: false
            visible: false

             function altBack() {
                 touchTest.resetTouchTest()
                 if(advancedSettingsSwipeView.currentIndex != AdvancedSettingsPage.BasePage) {
                     advancedSettingsSwipeView.swipeToItem(AdvancedSettingsPage.BasePage)
                 }
             }

            TouchTestScreen {
                id: touchTest
            }
        }

        // AdvancedSettingsPage.KoreaDFSSecretPage
        Item {
            id: koreaDFSScreenItem
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: AdvancedSettingsPage.BasePage
            smooth: false
            visible: false

            KoreaDFSScreenForm {
                id: koreaDFSScreen
            }
        }

        ////




    }

    /*Timer {
        id: closeDeauthorizeAccountsPopupTimer
        interval: 1500
        onTriggered: deauthorizeAccountsPopup.close()
    }*/

    CustomPopup {
        popupName: "CopyingLogs"
        property bool initialized: false
        property bool cancelled: false
        property string logBundlePath: ""
        property int errorcode: 0
        property bool showButton: true

        id: copyingLogsPopup
        visible: false
        popupWidth: 750
        popupHeight: {
            if(popupState == "failed_copied_logs") {
                350
            }
            else if(popupState == "cancelling_copy_logs") {
                250
            }
            else {
                300
            }
        }

        property string popupState: "no_usb_detected"
        showOneButton: showButton
        full_button_text: {
            if (popupState =="copy_logs_state") {
                qsTr("CANCEL")
            }
            else {
                qsTr("CLOSE")
            }
        }
        full_button.onClicked: {
            if(popupState == "copy_logs_state") {
                bot.cancel()
                showButton = false
                cancelled = true
                errorcode = 0
                popupState = "cancelling_copy_logs"
            }
            else {
                initialized = false
                cancelled = false
                errorcode = 0
                copyingLogsPopup.close()
                showButton = true
            }
        }

        onClosed: {
            popupState = "no_usb_detected"
            initialized = false
            cancelled = false
            errorcode = 0
            showButton = true
        }

        ColumnLayout {
            id: columnLayout_copy_logs
            width: 650
            height: parent.height
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Image {
                id: error_image
                width: sourceSize.width - 10
                height: sourceSize.height -10
                Layout.alignment: Qt.AlignHCenter
            }

            BusySpinner {
                id: busy_spinner_img
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                spinnerSize: 64
            }

            TextHeadline {
                id: title
                Layout.alignment: Qt.AlignHCenter
            }

            TextBody {
                id: description
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
            }

            states: [
                State {
                    name: "copy_logs_state"
                    when: copyingLogsPopup.popupState == "copy_logs_state"

                    PropertyChanges {
                        target: error_image
                        visible: false
                    }
                    PropertyChanges {
                        target: busy_spinner_img
                        visible: true
                    }

                    PropertyChanges {
                        target: title
                        text: qsTr("COPYING LOGS TO USB")
                    }

                    PropertyChanges {
                        target: description
                        text: qsTr("%1").arg(bot.process.printPercentage) + "%"
                        visible: true
                    }

                    PropertyChanges {
                        target: columnLayout_copy_logs
                        height: 100
                        anchors.topMargin: 120
                        spacing: 25
                    }
                },
                State {
                    name: "no_usb_detected"
                    when: copyingLogsPopup.popupState == "no_usb_detected"

                    PropertyChanges {
                        target: error_image
                        source: "qrc:/img/extruder_material_error.png"
                        visible: true
                    }
                    PropertyChanges {
                        target: busy_spinner_img
                        visible: false
                    }

                    PropertyChanges {
                        target: title
                        text: qsTr("NO USB DETECTED")
                    }

                    PropertyChanges {
                        target: description
                        text: qsTr("You need to insert a USB to use this feature.")
                        visible: true
                    }

                    PropertyChanges {
                        target: columnLayout_copy_logs
                        height: 100
                        anchors.topMargin: 120
                    }
                },
                State {
                    name: "cancelling_copy_logs"
                    when: copyingLogsPopup.popupState == "cancelling_copy_logs"

                    PropertyChanges {
                        target: error_image
                        visible: false
                    }
                    PropertyChanges {
                        target: busy_spinner_img
                        visible: true
                    }

                    PropertyChanges {
                        target: title
                        text: qsTr("CANCELLING...")
                    }

                    PropertyChanges {
                        target: description
                        text: qsTr("Do not remove USB.")
                        visible: true
                    }

                    PropertyChanges {
                        target: columnLayout_copy_logs
                        height: 100
                        anchors.topMargin: 140
                        spacing: 25
                    }
                },
                State {
                    name: "successfully_copied_logs"
                    when: copyingLogsPopup.popupState == "successfully_copied_logs"

                    PropertyChanges {
                        target: error_image
                        source: "qrc:/img/process_complete_small.png"
                        visible: true
                    }
                    PropertyChanges {
                        target: busy_spinner_img
                        visible: false
                    }

                    PropertyChanges {
                        target: title
                        text: qsTr("COPY LOGS TO USB - COMPLETE")
                    }

                    PropertyChanges {
                        target: description
                        visible: false
                    }

                    PropertyChanges {
                        target: columnLayout_copy_logs
                        height: 100
                        anchors.topMargin: 140
                        spacing: 35
                    }
                },
                State {
                    name: "failed_copied_logs"
                    when: copyingLogsPopup.popupState == "failed_copied_logs"

                    PropertyChanges {
                        target: error_image
                        source: "qrc:/img/extruder_material_error.png"
                        visible: true
                    }
                    PropertyChanges {
                        target: busy_spinner_img
                        visible: false
                    }

                    PropertyChanges {
                        target: title
                        text: qsTr("COPY LOGS TO USB - FAILED")
                    }

                    PropertyChanges {
                        target: description
                        visible: true
                        text: qsTr("There was an error during this procedure. If this reoccurs, Please contact our "+
                                    "support through <b>makerbot.com</b> to identify your issue.<br><br>"+
                                    "CODE: %1").arg(copyingLogsPopup.errorcode)
                    }

                    PropertyChanges {
                        target: columnLayout_copy_logs
                        height: 200
                        anchors.topMargin: 80
                    }
                }
            ]
        }
    }

    CustomPopup {
        popupName: "ResetToFactory"
        id: resetToFactoryPopup
        popupWidth: 715
        popupHeight: 282
        visible: false
        showTwoButtons: true
        defaultButton: LoggingPopup.Right
        left_button_text: "BACK"
        right_button_text: "CONFIRM"
        right_button.onClicked: {
            right_button.enabled = false
            left_button.enabled = false
            isResetting = true
            bot.resetToFactory(true)
        }
        left_button.onClicked: {
            resetToFactoryPopup.close()
        }
        onClosed: {
            isResetting = false
            right_button.enabled = true
            left_button.enabled = true
        }

        Column {
            id: user_column
            width: resetToFactoryPopup.popupContainer.width
            height: resetToFactoryPopup.popupContainer.height - resetToFactoryPopup.full_button.height
            anchors.top: resetToFactoryPopup.popupContainer.top
            anchors.horizontalCenter: resetToFactoryPopup.popupContainer.horizontalCenter
            spacing: 15
            topPadding: 35

            Image {
                id: extruder_material_error
                source: "qrc:/img/extruder_material_error.png"
                sourceSize.width: 63
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: alert_text
                color: "#ffffff"
                text: isResetting ? qsTr("RESTORING FACTORY SETTINGS...") : qsTr("RESTORE FACTORY SETTINGS?")
                font.pixelSize: 20
                font.letterSpacing: 3
                font.family: defaultFont.name
                font.weight: Font.Bold
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: descritpion_text
                width: parent.width
                color: "#ffffff"
                text: isResetting ? qsTr("Please wait.") : qsTr("This will erase all history, preferences, account information and calibration settings.")
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                lineHeight: 1.3
                font.letterSpacing: 3
                font.family: defaultFont.name
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                rightPadding: 5
                leftPadding: 5
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
