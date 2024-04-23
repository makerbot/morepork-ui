import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import MachineTypeEnum 1.0
import FreStepEnum 1.0

Item {
    id: systemSettingsPage
    smooth: false
    anchors.fill: parent

    property alias systemSettingsSwipeView: systemSettingsSwipeView

    property alias buttonPrinterInfo: buttonPrinterInfo

    property alias buttonAdvancedInfo: buttonAdvancedInfo

    property alias wifiPage: wifiPage
    property alias buttonWiFi: buttonWiFi
    property alias koreaDFSScreen: koreaDFSScreen

    property alias buttonAuthorizeAccounts: buttonAuthorizeAccounts
    property alias authorizeAccountPage: authorizeAccountPage

    property alias buttonFirmwareUpdate: buttonFirmwareUpdate
    property alias firmwareUpdatePage: firmwareUpdatePage

    property alias buttonSetupProcedures: buttonSetupProcedures
    property alias setupProceduresPage: setupProceduresPage

    property alias buttonCopyLogs: buttonCopyLogs
    property alias copyingLogsPopup: copyingLogsPopup

    property alias buttonCopyTimelapseImages: buttonCopyTimelapseImages
    property alias copyingTimelapseImagesPopup: copyingTimelapseImagesPopup

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
    property bool isFactoryResetDone: false
    property bool isFinalResetProceduresDone: false
    property alias buttonResetToFactory: buttonResetToFactory
    property alias resetToFactoryPopup: resetToFactoryPopup
    property bool isFactoryResetProcess: bot.process.type === ProcessType.FactoryResetProcess
    property bool doneFactoryReset: bot.process.type === ProcessType.FactoryResetProcess &&
                                    bot.process.stateType === ProcessStateType.Done

    property string lightBlue: "#3183af"
    property string otherBlue: "#45a2d3"

    Timer {
        id: doFinalResetProceduresTimer
        interval: 2500
        onTriggered: {
            // Reset all screen positions
            fre.setFreStep(FreStep.Welcome)
            settings.resetPreferences()
            isFinalResetProceduresDone = true
        }
    }

    Timer {
        id: rebootPrinterTimer
        interval: 5000
        onTriggered: {
            // Reboot Printer
            bot.reboot()
        }
    }

    onIsFactoryResetProcessChanged: {
        if(isFactoryResetProcess){
            isResetting = true
        }
    }

    onDoneFactoryResetChanged: {
        if(doneFactoryReset) {
            isResetting = false
            isFactoryResetDone = true
        }
    }

    enum SwipeIndex {
        BasePage,               // 0
        PrinterInfoPage,        // 1
        AdvancedInfoPage,       // 2
        WifiPage,               // 3
        AuthorizeAccountsPage,  // 4
        FirmwareUpdatePage,     // 5
        SetupProceduresPage,    // 6
        ShareAnalyticsPage,     // 7
        ChangePrinterNamePage,  // 8
        TimePage,               // 9
        ChangeLanguagePage,     // 10
        SpoolInfoPage,          // 11
        ColorSwatchPage,        // 12
        TouchTestPage,          // 13
        KoreaDFSSecretPage      // 14
    }

    LoggingStackLayout {
        id: systemSettingsSwipeView
        logName: "systemSettingsSwipeView"
        currentIndex: SystemSettingsPage.BasePage

        // SystemSettingsPage.BasePage
        Item {
            id: itemSystemSettings
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: settingsPage.settingsSwipeView
            property int backSwipeIndex: SettingsPage.BasePage
            property string topBarTitle: qsTr("System Settings")
            smooth: false

            FlickableMenu {
                id: flickableSystemSettings
                contentHeight: columnSystemSettings.height

                Column {
                    id: columnSystemSettings
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
                        buttonAlertImage.visible: isOffline
                        slidingSwitch.checked: bot.net.wifiEnabled
                        slidingSwitch.visible: true

                        slidingSwitch.onClicked: {
                            if(slidingSwitch.checked) {
                                bot.toggleWifi(true)
                            }
                            else if(!slidingSwitch.checked) {
                                bot.toggleWifi(false)
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
                        id: buttonSetupProcedures
                        buttonImage.source: "qrc:/img/icon_setup_procedures.png"
                        buttonText.text: qsTr("SETUP PROCEDURES")
                        openMenuItemArrow.visible: true
                        visible: bot.machineType == MachineType.Magma
                    }

                    MenuButton {
                        id: buttonCopyLogs
                        buttonImage.source: "qrc:/img/icon_copy_logs.png"
                        buttonText.text: qsTr("COPY LOGS TO USB")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonCopyTimelapseImages
                        buttonImage.source: "qrc:/img/icon_copy_logs.png"
                        buttonText.text: qsTr("COPY TIMELAPSE IMAGES TO USB")
                        enabled: !isProcessRunning()
                        visible: settings.getCaptureTimelapseImages()
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
                        id: buttonChangeLanguage
                        buttonImage.source: "qrc:/img/icon_choose_language.png"
                        buttonText.text: qsTr("CHOOSE LANGUAGE")
                        visible: (bot.machineType != MachineType.Magma) //BW-5871
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
                        buttonImage.source: "qrc:/img/icon_fingerprint.png"
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

        // SystemSettingsPage.PrinterInfoPage
        Item {
            id: printerInfoItem
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            property string topBarTitle: qsTr("Printer Info")
            smooth: false
            visible: false

            InfoPage {

            }
        }

        // SystemSettingsPage.AdvancedInfoPage
        Item {
            id: advancedInfoItem
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            property string topBarTitle: qsTr("Sensor Info")
            smooth: false
            visible: false

            AdvancedInfo {

            }
        }

        // SystemSettingsPage.WifiPage
        Item {
            id: wifiItem
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            property string topBarTitle: qsTr("Wifi Settings")
            smooth: false
            visible: false
            property bool hasAltBack: true

            function altBack() {
                if(!inFreStep) {
                    systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                resetSettingsSwipeViewPages()
            }

            WiFiPage {
                id: wifiPage

            }
        }

        // SystemSettingsPage.AuthorizeAccountsPage
        Item {
            id: accountsItem
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            property string topBarTitle: qsTr("Choose Authorization Method")
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
            }

            AuthorizeAccountPage {
                id: authorizeAccountPage
            }
        }


        // SystemSettingsPage.FirmwareUpdatePage
        Item {
            id: firmwareUpdateItem
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            property string topBarTitle: qsTr("Update Firmware")
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
                        systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
                    }
                    else {
                        systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
                    }
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                bot.cancel()
                systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
                settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            FirmwareUpdatePage {
                id: firmwareUpdatePage
            }
        }

        // SystemSettingsPage.SetupProceduresPage
        Item {
            id: setupProceduresItem
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            property string topBarTitle: qsTr("Setup Procedures")
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                settingsPage.systemSettingsPage.systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
            }

            SetupProceduresPage {
                id: setupProceduresPage

            }
        }

        // SystemSettingsPage.ShareAnalyticsPage
        Item {
            id: analyticsItem
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            property string topBarTitle: qsTr("Analytics Settings")
            smooth: false
            visible: false

            AnalyticsScreen {
                id: analyticsScreen
            }
        }

        // SystemSettingsPage.ChangePrinterNamePage
        Item {
            id: namePrinterItem
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            property string topBarTitle: qsTr("Change Printer Name")
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                namePrinter.nameField.clear()
                if(!inFreStep) {
                    systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
                settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            NamePrinterPage {
                id: namePrinter
            }
        }

        // SystemSettingsPage.TimePage
        Item {
            id: timeItem
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            property string topBarTitle: qsTr("Time and Date")
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
                settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            TimePage {
                id: timePage
            }
        }

        // SystemSettingsPage.ChangeLanguagePage
        Item {
            id: changeLanguageItem
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            property string topBarTitle: qsTr("Set Language")
            smooth: false
            visible: false

            LanguageSelector {
                id: languageSelectorPage
            }
        }

        // SystemSettingsPage.SpoolInfoPage
        Item {
            id: spoolInfoItem
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            smooth: false
            visible: false

            SpoolInfoPage {
                id: spoolInfoPage
            }
        }

        // SystemSettingsPage.ColorSwatchPage
        Item {
            id: colorSwatchItem
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            smooth: false
            visible: false

            ColorSwatchPage {
                id: colorSwatch
            }
        }

        // SystemSettingsPage.TouchTestPage
        Item {
            id: touchTestItem
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            property string topBarTitle: qsTr("Touchscreen Test")
            property bool hasAltBack: true
            smooth: false
            visible: false

             function altBack() {
                 touchTest.resetTouchTest()
                 if(systemSettingsSwipeView.currentIndex != SystemSettingsPage.BasePage) {
                     systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
                 }
             }

            TouchTestScreen {
                id: touchTest
            }
        }

        // SystemSettingsPage.KoreaDFSSecretPage
        Item {
            id: koreaDFSScreenItem
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            smooth: false
            visible: false

            KoreaDFSScreenForm {
                id: koreaDFSScreen
            }
        }
    }

    Timer {
        id: closeDeauthorizeAccountsPopupTimer
        interval: 1500
        onTriggered: deauthorizeAccountsPopup.close()
    }

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
            if(showButton) {
                columnLayout_copy_logs.height+145
            }
            else {

                columnLayout_copy_logs.height+70
            }
        }

        property string popupState: "no_usb_detected"
        showOneButton: showButton
        fullButtonText: {
            if (popupState == "copy_logs_state") {
                qsTr("CANCEL")
            }
            else {
                qsTr("CLOSE")
            }
        }
        fullButton.onClicked: {
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
            height: children.height
            anchors.top: copyingLogsPopup.popupContainer.top
            anchors.topMargin: 35
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
                },
                State {
                    name: "no_usb_detected"
                    when: copyingLogsPopup.popupState == "no_usb_detected"

                    PropertyChanges {
                        target: error_image
                        source: "qrc:/img/process_error_small.png"
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
                },
                State {
                    name: "failed_copied_logs"
                    when: copyingLogsPopup.popupState == "failed_copied_logs"

                    PropertyChanges {
                        target: error_image
                        source: "qrc:/img/process_error_small.png"
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
                                   "support through %1 to identify your issue.").arg("<b>makerbot.com</b>") + "<br><br>" +
                              qsTr("CODE: %1").arg(copyingLogsPopup.errorcode)
                    }
                }
            ]
        }
    }

    CustomPopup {
        popupName: "CopyingTimelapseImages"
        property bool initialized: false
        property bool cancelled: false
        property string timelapseBundlePath: ""
        property int errorcode: 0
        property bool showButton: true

        id: copyingTimelapseImagesPopup
        visible: false
        popupWidth: 750
        popupHeight: {
            if(popupState == "failed_copied_timelapse_images") {
                350
            }
            else if(popupState == "cancelling_copy_timelapse_images") {
                250
            }
            else {
                300
            }
        }

        property string popupState: "no_usb_detected"
        showOneButton: showButton
        fullButtonText: {
            if (popupState == "copy_timelapse_images_state") {
                qsTr("CANCEL")
            }
            else {
                qsTr("CLOSE")
            }
        }
        fullButton.onClicked: {
            if(popupState == "copy_timelapse_images_state") {
                bot.cancel()
                showButton = false
                cancelled = true
                errorcode = 0
                popupState = "cancelling_copy_timelapse_images"
            }
            else {
                initialized = false
                cancelled = false
                errorcode = 0
                copyingTimelapseImagesPopup.close()
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
            id: columnLayout_copy_timelapse_images
            width: 650
            height: parent.height
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Image {
                id: timelapse_error_image
                width: sourceSize.width - 10
                height: sourceSize.height -10
                Layout.alignment: Qt.AlignHCenter
            }

            BusySpinner {
                id: timelapse_busy_spinner_img
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                spinnerSize: 64
            }

            TextHeadline {
                id: timelapse_title
                Layout.alignment: Qt.AlignHCenter
            }

            TextBody {
                id: timelapse_description
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
            }

            states: [
                State {
                    name: "copy_timelapse_images_state"
                    when: copyingTimelapseImagesPopup.popupState == "copy_timelapse_images_state"

                    PropertyChanges {
                        target: timelapse_error_image
                        visible: false
                    }
                    PropertyChanges {
                        target: timelapse_busy_spinner_img
                        visible: true
                    }
                    PropertyChanges {
                        target: timelapse_title
                        text: qsTr("COPYING TIMELAPSE IMAGES TO USB")
                    }
                    PropertyChanges {
                        target: timelapse_description
                        text: qsTr("%1").arg(bot.process.printPercentage) + "%"
                        visible: true
                    }
                    PropertyChanges {
                        target: columnLayout_copy_timelapse_images
                        height: 100
                        anchors.topMargin: 120
                        spacing: 25
                    }
                },
                State {
                    name: "no_usb_detected"
                    when: copyingTimelapseImagesPopup.popupState == "no_usb_detected"

                    PropertyChanges {
                        target: timelapse_error_image
                        source: "qrc:/img/process_error_small.png"
                        visible: true
                    }
                    PropertyChanges {
                        target: timelapse_busy_spinner_img
                        visible: false
                    }
                    PropertyChanges {
                        target: timelapse_title
                        text: qsTr("NO USB DETECTED")
                    }
                    PropertyChanges {
                        target: timelapse_description
                        text: qsTr("You need to insert a USB to use this feature.")
                        visible: true
                    }
                    PropertyChanges {
                        target: columnLayout_copy_timelapse_images
                        height: 100
                        anchors.topMargin: 110
                    }
                },
                State {
                    name: "cancelling_copy_timelapse_images"
                    when: copyingTimelapseImagesPopup.popupState == "cancelling_copy_timelapse_images"

                    PropertyChanges {
                        target: timelapse_error_image
                        visible: false
                    }
                    PropertyChanges {
                        target: timelapse_busy_spinner_img
                        visible: true
                    }
                    PropertyChanges {
                        target: timelapse_title
                        text: qsTr("CANCELLING...")
                    }
                    PropertyChanges {
                        target: timelapse_description
                        text: qsTr("Do not remove USB.")
                        visible: true
                    }
                    PropertyChanges {
                        target: columnLayout_copy_timelapse_images
                        height: 100
                        anchors.topMargin: 140
                        spacing: 25
                    }
                },
                State {
                    name: "successfully_copied_timelapse_images"
                    when: copyingTimelapseImagesPopup.popupState == "successfully_copied_timelapse_images"

                    PropertyChanges {
                        target: timelapse_error_image
                        source: "qrc:/img/process_complete_small.png"
                        visible: true
                    }
                    PropertyChanges {
                        target: timelapse_busy_spinner_img
                        visible: false
                    }
                    PropertyChanges {
                        target: timelapse_title
                        text: qsTr("COPY TIMELAPSE IMAGES TO USB - COMPLETE")
                    }
                    PropertyChanges {
                        target: timelapse_description
                        visible: false
                    }
                    PropertyChanges {
                        target: columnLayout_copy_timelapse_images
                        height: 100
                        anchors.topMargin: 140
                        spacing: 35
                    }
                },
                State {
                    name: "failed_copied_timelapse_images"
                    when: copyingTimelapseImagesPopup.popupState == "failed_copied_timelapse_images"

                    PropertyChanges {
                        target: timelapse_error_image
                        source: "qrc:/img/process_error_small.png"
                        visible: true
                    }
                    PropertyChanges {
                        target: timelapse_busy_spinner_img
                        visible: false
                    }
                    PropertyChanges {
                        target: timelapse_title
                        text: qsTr("COPY LOGS TO USB - FAILED")
                    }
                    PropertyChanges {
                        target: timelapse_description
                        visible: true
                        text: qsTr("There was an error during this procedure. If this reoccurs, Please contact our "+
                                   "support through %1 to identify your issue.").arg("<b>makerbot.com</b>") + "<br><br>" +
                              qsTr("CODE: %1").arg(copyingTimelapseImagesPopup.errorcode)
                    }
                    PropertyChanges {
                        target: columnLayout_copy_timelapse_images
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
        property bool hideButton: false
        popupHeight: factoryResetColumnLayout.height
                     + ((isResetting || hideButton) ? 90 : 145)
        visible: false
        showTwoButtons: !isResetting && !isFactoryResetDone
        showOneButton: !isResetting && isFactoryResetDone && !hideButton
                       && isFinalResetProceduresDone
        leftButtonText: qsTr("BACK")
        leftButton.onClicked: {
            resetToFactoryPopup.close()
        }
        rightButtonText: qsTr("CONFIRM")
        rightButton.onClicked: {
            isResetting = true
            // Don't allow popups checking that we are not in FRE to
            // display while we are doing the reset.
            isFreComplete = false
            bot.resetToFactory(true)
            doFinalResetProceduresTimer.start()
        }
        fullButtonText: qsTr("CONFIRM")
        fullButton.onClicked: {
            hideButton = true
            // Wait before Reboot
            rebootPrinterTimer.start()
        }

        onClosed: {
            hideButton = false
            isResetting = false
            isFactoryResetDone = false
            isFinalResetProceduresDone = false
        }

        ColumnLayout {
            id: factoryResetColumnLayout
            width: resetToFactoryPopup.popupContainer.width
            height: children.height
            anchors.top: resetToFactoryPopup.popupContainer.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 35
            spacing: 20

            Image {
                id: factory_reset_error_image
                width: sourceSize.width
                Layout.preferredWidth: sourceSize.width
                Layout.preferredHeight: sourceSize.height
                source: "qrc:/img/popup_error.png"
                Layout.alignment: Qt.AlignHCenter
                visible: !isResetting
            }

            BusySpinner {
                id: factory_reset_busy
                Layout.alignment: Qt.AlignHCenter
                visible: isResetting
            }

            TextHeadline {
                id: alert_text
                width: parent.width
                Layout.preferredWidth: parent.width
                text: {
                    if(isResetting) {
                        qsTr("RESTORING FACTORY SETTINGS")
                    } else {
                        (isFactoryResetDone && isFinalResetProceduresDone)
                                ? qsTr("RESTART PRINTER")
                                : qsTr("RESTORE FACTORY SETTINGS?")
                    }
                }
                horizontalAlignment: Text.AlignHCenter
            }

            TextBody {
                id: descritpion_text
                width: parent.width
                Layout.preferredWidth: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: {
                    if(isResetting) {
                        qsTr("Please wait...")
                    } else {
                        (isFactoryResetDone && isFinalResetProceduresDone)
                                ? qsTr("Restart the printer to complete factory reset procedure.")
                                : qsTr("This will erase all history, preferences, account information and calibration settings.")
                    }
                }
            }
        }
    }
}
