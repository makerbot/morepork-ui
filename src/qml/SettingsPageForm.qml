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
    property alias defaultItem: itemSettings

    property alias buttonPrinterInfo: buttonPrinterInfo

    property alias buttonChangePrinterName: buttonChangePrinterName
    property alias namePrinter: namePrinter

    property alias buttonWiFi: buttonWiFi

    property alias buttonAuthorizeAccounts: buttonAuthorizeAccounts
    property alias signInPage: signInPage

    property alias buttonDeauthorizeAccounts: buttonDeauthorizeAccounts
    property alias deauthorizeAccountsPopup: deauthorizeAccountsPopup

    property alias buttonFirmwareUpdate: buttonFirmwareUpdate

    property alias buttonCalibrateToolhead: buttonCalibrateToolhead
    property alias calibrateErrorScreen: calibrateErrorScreen

    property alias buttonTime: buttonTime
    property alias timePage: timePage

    property alias buttonAdvancedSettings: buttonAdvancedSettings

    property alias buttonShutdown: buttonShutdown
    property alias shutdownPopup: shutdownPopup

    property alias wifiPage: wifiPage
    property string lightBlue: "#3183af"
    property string otherBlue: "#45a2d3"

    smooth: false

    SwipeView {
        id: settingsSwipeView
        currentIndex: 0
        smooth: false
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = settingsSwipeView.currentIndex
            if (prevIndex == itemToDisplayDefaultIndex) {
                return;
            }
            settingsSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            setCurrentItem(settingsSwipeView.itemAt(itemToDisplayDefaultIndex))
            settingsSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            settingsSwipeView.itemAt(prevIndex).visible = false
        }

        // settingsSwipeView.index = 0
        Item {
            id: itemSettings
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: mainSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

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
                        buttonText.text: "PRINTER INFO"
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonChangePrinterName
                        buttonImage.source: "qrc:/img/icon_name_printer.png"
                        buttonText.text: "CHANGE PRINTER NAME"
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonWiFi
                        buttonImage.source: "qrc:/img/icon_wifi.png"
                        buttonText.text: "WiFi"

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

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonAuthorizeAccounts
                        buttonImage.source: "qrc:/img/icon_authorize_account.png"
                        buttonText.text: "AUTHORIZE MAKERBOT ACCOUNT"
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonDeauthorizeAccounts
                        buttonImage.source: "qrc:/img/icon_deauthorize_accounts.png"
                        buttonText.text: "DEAUTHORIZE MAKERBOT ACCOUNTS"
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonFirmwareUpdate
                        buttonImage.source: "qrc:/img/icon_software_update.png"
                        buttonText.text: "SOFTWARE UPDATE"
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonCalibrateToolhead
                        buttonImage.source: "qrc:/img/icon_calibrate_toolhead.png"
                        buttonText.text: "CALIBRATE EXTRUDERS"
                        enabled: !isProcessRunning()
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonTime
                        buttonImage.source: "qrc:/img/icon_time_and_date.png"
                        buttonText.text: "TIME"
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonAdvancedSettings
                        buttonImage.source: "qrc:/img/icon_preheat.png"
                        buttonText.text: "ADVANCED"
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonShutdown
                        buttonImage.source: "qrc:/img/icon_power.png"
                        buttonText.text: "SHUT DOWN"
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }
                }
            }
        }

        // settingsSwipeView.index = 1
        Item {
            id: printerInfoItem
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            InfoPage {

            }
        }

        //settingsSwipeView.index = 2
        Item {
            id: namePrinterItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    settingsSwipeView.swipeToItem(0)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                settingsSwipeView.swipeToItem(0)
                mainSwipeView.swipeToItem(0)
            }

            NamePrinterPage {
                id: namePrinter
            }
        }

        //settingsSwipeView.index = 3
        Item {
            id: wifiItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false
            property bool hasAltBack: true

            function altBack() {
                if(!inFreStep) {
                    settingsSwipeView.swipeToItem(0)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                settingsSwipeView.swipeToItem(0)
                mainSwipeView.swipeToItem(0)
            }

            WiFiPageForm {
                id: wifiPage

            }

        }

        //settingsSwipeView.index = 4
        Item {
            id: accountsItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            SignInPage {
                id: signInPage
            }
        }

        //settingsSwipeView.index = 5
        Item {
            id: firmwareUpdateItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    if(firmwareUpdatePage.state == "install_from_usb") {
                        firmwareUpdatePage.state = "no_firmware_update_available"
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
                        settingsSwipeView.swipeToItem(0)
                    }
                    else {
                        settingsSwipeView.swipeToItem(0)
                    }
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                bot.cancel()
                settingsSwipeView.swipeToItem(0)
                mainSwipeView.swipeToItem(0)
            }

            FirmwareUpdatePage {
                id: firmwareUpdatePage

            }
        }

        //settingsSwipeView.index = 6
        Item {
            id: calibrateToolheadsItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
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
                bot.cancel()
                toolheadCalibration.state = "base state"
                settingsSwipeView.swipeToItem(0)
                mainSwipeView.swipeToItem(0)
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
                        if(settingsSwipeView.currentIndex != 0) {
                            settingsSwipeView.swipeToItem(0)
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

        //settingsSwipeView.index = 7
        Item {
            id: timeItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    settingsSwipeView.swipeToItem(0)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                settingsSwipeView.swipeToItem(0)
                mainSwipeView.swipeToItem(0)
            }

            TimePage {
                id: timePage

            }
        }

        //settingsSwipeView.index = 8
        Item {
            id: advancedSettingsItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            AdvancedSettingsPage {
                id: advancedSettingsPage
            }
        }
    }

    Timer {
        id: closeDeauthorizeAccountsPopupTimer
        interval: 1500
        onTriggered: deauthorizeAccountsPopup.close()
    }

    ModalPopup {
        id: shutdownPopup
        visible: false
        popup_contents.contentItem: Item {
            anchors.fill: parent
            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                TitleText {
                    text: "SHUT DOWN PRINTER"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                BodyText{
                    text: "Are you sure you want to shut down the printer?"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    Popup {
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
                        text: "REMOVE ACCOUNTS"
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: false
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: "Antennae"
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MouseArea {
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
                        text: "CANCEL"
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: "Antennae"
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MouseArea {
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
                    text: deauthorizeAccountsPopup.clearingAccounts ? "ALL ACCOUNTS DEAUTHORIZED" : "DEAUTHORIZE ACCOUNTS"
                    font.letterSpacing: 3
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: "Antennae"
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
                    text: "Deauthorize all accounts currently connected to this printer? You will have to reauthorize any account you wish to connect in the future."
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.weight: Font.Light
                    wrapMode: Text.WordWrap
                    font.family: "Antennae"
                    font.pixelSize: 18
                    lineHeight: 1.3
                    visible: !deauthorizeAccountsPopup.clearingAccounts
                }
            }
        }
    }
}
