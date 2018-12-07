import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0

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

    property alias buttonFirmwareUpdate: buttonFirmwareUpdate

    property alias buttonCalibrateToolhead: buttonCalibrateToolhead

    property alias buttonTimeAndDate: buttonTimeAndDate

    property alias buttonAdvancedSettings: buttonAdvancedSettings

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
                        Switch {
                            id: switchWifi
                            indicator: Rectangle {
                                    implicitWidth: 68
                                    implicitHeight: 35
                                    x: switchWifi.leftPadding
                                    y: parent.height / 2 - height / 2
                                    radius: 17
                                    color: switchWifi.checked ? lightBlue : "#ffffff"
                                    border.color: switchWifi.checked ? "#3183af" : "#cccccc"

                                    Rectangle {
                                        x: switchWifi.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: switchWifi.down ? "#cccccc" : "#ffffff"
                                        border.color: switchWifi.checked ? lightBlue : "#999999"
                                    }
                                }
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
                        id: buttonTimeAndDate
                        buttonImage.source: "qrc:/img/icon_time_and_date.png"
                        buttonText.text: "TIME AND DATE"
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
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    signInPage.backToSettings()
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                signInPage.backToSettings()
                mainSwipeView.swipeToItem(0)
            }

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
                    settingsSwipeView.swipeToItem(0)
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
                    if(bot.process.type == ProcessType.CalibrationProcess) {
                        toolheadCalibration.cancelCalibrationPopup.open()
                    }
                    else {
                        toolheadCalibration.state = "base state"
                        if(settingsSwipeView.currentIndex != 0) {
                            settingsSwipeView.swipeToItem(0)
                        }
                    }
                }
                else {
                    skipFreStepPopup.open()
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
                onProcessDone: {
                    state = "base state"
                    settingsSwipeView.swipeToItem(0)
                }
            }
        }

        //settingsSwipeView.index = 7
        Item {
            id: timeAndDateItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false


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
}
