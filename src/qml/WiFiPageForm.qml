import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import WifiStateEnum 1.0
import WifiErrorEnum 1.0
import FreStepEnum 1.0

Item {
    id: wifiPage
    width: 800
    height: 440
    smooth: false
    antialiasing: false
    property alias wifiSwipeView: wifiSwipeView
    property int wifiError: bot.net.wifiError
    property bool isWifiConnected: bot.net.interface == "wifi"
    property string currentWifiName: bot.net.name
    property string selectedWifiPath: ""
    property string selectedWifiName: ""
    property bool selectedWifiSaved: false
    property bool isForgetEnabled: false

    onIsWifiConnectedChanged: {
        if(isWifiConnected) {
            bot.net.setWifiState(WifiState.Connected)

            if(wifiSwipeView.currentIndex != WiFiPage.ChooseWifi) {
                wifiSwipeView.swipeToItem(WiFiPage.ChooseWifi)
            }
            bot.scanWifi(true)
            passwordField.clear()

            if(inFreStep && currentFreStep == FreStep.SetupWifi) {
                wifiFreStepComplete.start()
                bot.firmwareUpdateCheck(false)
            }
        }
        else {
            if (bot.net.wifiState != WifiState.Connecting) {
                bot.net.setWifiState(WifiState.NotConnected)
            }
        }
    }

    onWifiErrorChanged: {
        if(bot.net.wifiError != WifiError.NoError) {
            bot.net.setWifiState(WifiState.NotConnected)
        }
    }

    Timer {
        id: wifiFreStepComplete
        interval: 2000
        onTriggered: {
            settingsPage.systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage)
            mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            if(isfirmwareUpdateAvailable) {
                fre.gotoNextStep(currentFreStep)
            }
            else {
                fre.setFreStep(FreStep.NamePrinter)
            }
        }
    }

    enum SwipeIndex {
        ChooseWifi,
        EnterPassword
    }

    LoggingSwipeView {
        id: wifiSwipeView
        logName: "wifiSwipeView"
        currentIndex: WiFiPage.ChooseWifi

        // WiFiPage.ChooseWIFI
        Item {
            id: itemChooseWifi
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: systemSettingsSwipeView
            property int backSwipeIndex: SystemSettingsPage.BasePage
            property bool hasAltBack: true
            smooth: false
            visible: true

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
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            ColumnLayout {
                id: ethernetInfoId
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10
                spacing: 15

                Image {
                    id: ethernet_image
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    Layout.alignment: Qt.AlignHCenter
                    source: {
                        if(bot.net.interface == "ethernet") {
                            "qrc:/img/process_complete_small.png"
                        } else {
                            "qrc:/img/ethernet_connected.png"
                        }
                    }
                }
                TextBody {
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap

                    Layout.preferredWidth: 400
                    text: {
                        if(bot.net.interface == "ethernet") {
                            "You’re connected to the internet through the ethernet port."
                        } else {
                            "Plug an ethernet cable into the rear of the machine to use a wired connection."
                        }
                    }
                }
                ButtonRectangleSecondary {
                    width: 750
                    Layout.preferredWidth: 750
                    text: "SCAN WI-FI NETWORKS"
                    Layout.alignment: Qt.AlignHCenter
                    enabled: (bot.net.wifiState !== WifiState.Searching)

                    onClicked: {
                        bot.scanWifi(true)
                        bot.net.setWifiState(WifiState.Searching)
                    }
                }

                // When the bot is not connected to wifi and the user
                // performs a wifi scan. In this case a deep scan happens
                // and it takes sometime to return the results. Once the
                // results are returned the bot goes into one of
                // 'Not Connected' or 'NoWifiFound' states.
                TextBody {
                    style: TextBody.Large
                    text: {
                        if(!bot.net.wifiEnabled) {
                            qsTr("Turn on WiFi and try again.")
                        } else if ((wifiList.count == 0) && (bot.net.wifiState == WifiState.Searching)) {
                            qsTr("Searching...")
                        } else if (bot.net.wifiState == WifiState.NoWifiFound) {
                            qsTr("No wireless networks found.")
                        } else if (bot.net.wifiState == WifiState.NotConnected &&
                                bot.net.wifiError != WifiError.NoError) {
                            qsTr("Search for wireless networks failed.")
                        } else {
                            emptyString
                        }
                    }
                    Layout.alignment: Qt.AlignCenter
                    Layout.topMargin: 60
                    visible: (wifiList.count == 0 && bot.net.wifiState == WifiState.Searching) ||
                             bot.net.wifiState == WifiState.NoWifiFound ||
                             (bot.net.wifiState == WifiState.NotConnected &&
                              (bot.net.wifiError == WifiError.ScanFailed ||
                               bot.net.wifiError == WifiError.UnknownError))
                }
            }

            // When the bot is already connected to the wifi and
            // the user performs a wifi scan, conman returns an old
            // wifi list but it still takes some time during which we
            // remain in the 'Connected' state and not in 'Searching'
            // unlike the deep scan. Since we dont have a unique state
            // for this case we use the busy indicator below to display
            // progress to the user using a combination of conditions.
            // We also use the condition that the wifi list isn't
            // populated yet by the backend.
            BusySpinner {
                id: wifiBusyIndicator
                spinnerActive: wifiList.count == 0 &&
                        (isWifiConnected ||
                         bot.net.wifiState == WifiState.Connected)
                spinnerSize: 64
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 30
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // The wifi list shows up when the scan retuns atleast
            // one wifi network or the bot is connected to a WiFi
            // network.
            ListView {
                id: wifiList
                smooth: false
                antialiasing: false
                anchors.top: ethernetInfoId.bottom
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                boundsBehavior: Flickable.DragOverBounds
                spacing: 1
                orientation: ListView.Vertical
                flickableDirection: Flickable.VerticalFlick
                clip: true
                visible: (bot.net.wifiState == WifiState.Connected ||
                         isWifiConnected ||
                         (bot.net.wifiState == WifiState.NotConnected &&
                                bot.net.wifiError != WifiError.ScanFailed &&
                                bot.net.wifiError != WifiError.UnknownError) ||
                         (bot.net.wifiState === WifiState.Searching && count != 0))
                model: bot.net.WiFiList

                delegate:
                    WiFiButton {
                    antialiasing: false
                    wifiName: model.modelData.name
                    isSecured: model.modelData.secured
                    isSaved: model.modelData.saved
                    signalStrength: model.modelData.sig_strength
                    isConnected: currentWifiName == wifiName

                    onClicked: {
                        if(isConnected) {
                            bot.net.setWifiState(WifiState.Disconnecting)
                            selectedWifiPath = model.modelData.path
                            selectedWifiName = model.modelData.name
                            wifiPopup.open()
                        }
                        else {
                            selectedWifiName = model.modelData.name
                            selectedWifiPath = model.modelData.path
                            selectedWifiSaved = model.modelData.saved

                            if(selectedWifiSaved || !isSecured) {
                                bot.net.setWifiState(WifiState.Connecting)
                                wifiPopup.open()
                                bot.connectWifi(selectedWifiPath,
                                                "", selectedWifiName)
                            }
                            else if(!selectedWifiSaved) {
                                wifiSwipeView.swipeToItem(WiFiPage.EnterPassword)
                                passwordField.forceActiveFocus()
                            }
                        }
                    }

                    onPressAndHold: {
                        if(isSaved || isConnected) {
                            isForgetEnabled = true
                            selectedWifiPath = model.modelData.path
                            selectedWifiName = model.modelData.name
                            wifiPopup.open()
                        }
                    }
                }
            }
        }

        // WiFiPage.EnterPassword
        Item {
            id: itemEnterPassword
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: wifiSwipeView
            property int backSwipeIndex: WiFiPage.ChooseWifi
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                passwordField.clear()
                showPassword.checked = false
                wifiSwipeView.swipeToItem(WiFiPage.ChooseWifi)
            }

            Item {
                id: appContainer
                anchors.fill: parent.fill
                smooth: false
                antialiasing: false

                TextSubheader {
                    text: qsTr("ENTER PASSWORD FOR %1").arg(selectedWifiName)
                    anchors.left: passwordInput.left
                    anchors.bottom: passwordInput.top
                    anchors.bottomMargin: 10
                }
                RowLayout {
                    id: passwordInput
                    width: 700
                    height: 50
                    anchors.left: parent.left
                    anchors.leftMargin: 50
                    anchors.top: parent.top
                    anchors.topMargin: 48
                    spacing: 30

                    TextField {
                        id: passwordField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        Layout.alignment: Qt.AlignVCenter
                        smooth: false
                        antialiasing: false
                        background:
                            Rectangle {
                                radius: 2
                                anchors.fill: parent
                                color: "#f7f7f7"
                            }
                        color: "#000000"
                        font.family: defaultFont.name
                        font.weight: Font.Light
                        font.pointSize: (showPassword.checked ||
                                        text == "") ? 14 : 24
                        placeholderText: "Enter WiFi password"
                        passwordCharacter: "•"
                        echoMode: {
                            showPassword.checked ?
                                        TextField.Normal:
                                        TextField.Password
                        }
                    }

                    ButtonRectangleSecondaryForm {
                        id: connectButton
                        Layout.preferredWidth: 160
                        Layout.preferredHeight: 50
                        Layout.alignment: Qt.AlignVCenter
                        text: qsTr("CONNECT")
                        onClicked: {
                            bot.net.setWifiState(WifiState.Connecting)
                            wifiPopup.open()
                            bot.connectWifi(selectedWifiPath,
                                            passwordField.text,
                                            selectedWifiName)
                        }
                    }
                }

                RowLayout {
                    id: rowLayout
                    anchors.leftMargin: -3
                    anchors.top: passwordInput.bottom
                    anchors.topMargin: 10
                    anchors.left: passwordInput.left
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    CheckBox {
                        id: showPassword
                        checked: false
                        onPressed: passwordField.forceActiveFocus()
                        indicator: Rectangle {
                                implicitWidth: 26
                                implicitHeight: 26
                                x: showPassword.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 3
                                border.color: showPassword.down ? lightBlue : otherBlue

                                Rectangle {
                                    width: 14
                                    height: 14
                                    x: 6
                                    y: 6
                                    radius: 2
                                    color: showPassword.down ? lightBlue : otherBlue
                                    visible: showPassword.checked
                                }
                            }
                    }

                    TextBody {
                        id: show_password_text
                        text: qsTr("Show Password")
                    }
                }
            }
        }
    }

    CustomPopup {
        popupName: "Wifi"
        id: wifiPopup
        closePolicy: Popup.CloseOnPressOutside
        popupHeight: columnLayout.height + 100

        // Full Button Bar
        showOneButton: !(isForgetEnabled ||
                       bot.net.wifiState == WifiState.Disconnecting) &&
                       (bot.net.wifiState == WifiState.Connecting ||
                       bot.net.wifiState == WifiState.NotConnected ||
                       bot.net.wifiError == WifiError.ConnectFailed ||
                       bot.net.wifiError == WifiError.InvalidPassword)

        full_button_text: {
            if(bot.net.wifiState == WifiState.Connecting) {
                qsTr("CANCEL")
            }
            else if(bot.net.wifiState == WifiState.NotConnected) {
                if(bot.net.wifiError == WifiError.ConnectFailed) {
                    qsTr("RETRY")
                }
                else if(bot.net.wifiError == WifiError.InvalidPassword) {
                    qsTr("CLOSE")
                }
                else {
                    qsTr("CLOSE")
                }
            } else {
                emptyString
            }
        }

        full_button.onClicked: {
            if(bot.net.wifiState == WifiState.Connecting) {
                wifiPopup.close()
            }
            else if(bot.net.wifiError == WifiError.ConnectFailed) {
                bot.net.setWifiState(WifiState.Connecting)
                bot.net.connectWifi(selectedWifiPath,
                                    passwordField.text,
                                    selectedWifiName)
            }
            else if(bot.net.wifiError == WifiError.InvalidPassword) {
                wifiPopup.close()
            }
            if(wifiPopup.opened) {
                wifiPopup.close()
            }
        }

        // Two Buttons Bar
        showTwoButtons: bot.net.wifiState == WifiState.Disconnecting ||
                        isForgetEnabled

        left_button_text: qsTr("YES")
        left_button.onClicked: {
            if(bot.net.wifiState == WifiState.Disconnecting) {
                bot.disconnectWifi(selectedWifiPath)
            }
            else if(isForgetEnabled) {
                bot.forgetWifi(selectedWifiPath)
            }
            bot.scanWifi(true)
            wifiPopup.close()
        }

        right_button_text: qsTr("CANCEL")
        right_button.onClicked: {
            if(isForgetEnabled || bot.net.wifiState == WifiState.Disconnecting) {
                wifiPopup.close()
            }
        }

        onClosed: {
            if(isForgetEnabled) {
                isForgetEnabled = false
                bot.scanWifi(true)
            }
            if(bot.net.wifiState == WifiState.Connecting) {
                bot.net.setWifiState(WifiState.NotConnected)
            }
            else if(bot.net.wifiState == WifiState.Disconnecting) {
                bot.net.setWifiState(WifiState.Connected)
            }
        }

        ColumnLayout {
            id: columnLayout
            width: 590
            height: 150
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 110
            spacing: 15

            BusySpinner {
                id: wifiConnectingBusy
                visible: true
                spinnerSize: 64
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            Image {
                id: error_image
                width: 80
                height: 80
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                visible: false

            }

            TextHeadline {
                id: header_text
                text: qsTr("CONNECTING")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            states: [
                State {
                    name: "connecting"
                    when: !isForgetEnabled && bot.net.wifiState == WifiState.Connecting

                    PropertyChanges {
                        target: error_image
                        visible: false
                    }

                    PropertyChanges {
                        target: wifiConnectingBusy
                        visible: true
                    }

                    PropertyChanges {
                        target: header_text
                        text: qsTr("CONNECTING")
                    }

                    PropertyChanges {
                        target: columnLayout
                        height: 150
                        anchors.topMargin: 110
                        spacing: 15
                    }
                },
                State {
                    name: "connected"
                    when: !isForgetEnabled
                          && bot.net.wifiState == WifiState.Connected
                            && bot.net.wifiError == WifiError.NoError

                    PropertyChanges {
                        target: error_image
                        visible: true
                        source:  "qrc:/img/popup_complete.png"
                    }

                    PropertyChanges {
                        target: wifiConnectingBusy
                        visible: false
                    }

                    PropertyChanges {
                        target: header_text
                        text: qsTr("CONNECTED SUCCESSFULLY")
                    }

                    PropertyChanges {
                        target: columnLayout
                        height: 100
                        anchors.topMargin: 160
                        spacing: 25
                    }
                },
                State {
                    name: "forget"
                    when: isForgetEnabled

                    PropertyChanges {
                        target: error_image
                        visible: false
                    }

                    PropertyChanges {
                        target: wifiConnectingBusy
                        visible: false
                    }

                    PropertyChanges {
                        target: header_text
                        text: qsTr("FORGET %1?").arg(selectedWifiName)
                    }

                    PropertyChanges {
                        target: columnLayout
                        height: 100
                        anchors.topMargin: 150
                    }
                },
                State {
                    name: "disconnected"
                    when: !isForgetEnabled && bot.net.wifiState == WifiState.Disconnecting

                    PropertyChanges {
                        target: error_image
                        visible: false
                    }

                    PropertyChanges {
                        target: wifiConnectingBusy
                        visible: false
                    }

                    PropertyChanges {
                        target: header_text
                        text: qsTr("DISCONNECT FROM %1?").arg(selectedWifiName)
                    }

                    PropertyChanges {
                        target: columnLayout
                        height: 100
                        anchors.topMargin: 150
                    }
                },
                State {
                    name: "failure"
                    when: bot.net.wifiState == WifiState.NotConnected &&
                          bot.net.wifiError !== WifiError.NoError &&
                          bot.net.wifiError !== WifiError.InvalidPassword

                    PropertyChanges {
                        target: error_image
                        visible: true
                        source: "qrc:/img/popup_error.png"
                    }

                    PropertyChanges {
                        target: wifiConnectingBusy
                        visible: false
                    }

                    PropertyChanges {
                        target: header_text
                        text: qsTr("FAILED TO CONNECT")
                    }

                    PropertyChanges {
                        target: columnLayout
                        height: 140
                        anchors.topMargin: 115
                        spacing: 10
                    }
                },
                State {
                    name: "invalid_password"
                    when: bot.net.wifiState == WifiState.NotConnected &&
                          bot.net.wifiError !== WifiError.NoError &&
                          bot.net.wifiError == WifiError.InvalidPassword

                    PropertyChanges {
                        target: error_image
                        visible: true
                        source: "qrc:/img/popup_error.png"
                    }

                    PropertyChanges {
                        target: wifiConnectingBusy
                        visible: false
                    }

                    PropertyChanges {
                        target: header_text
                        text: qsTr("INVALID PASSWORD")
                    }

                    PropertyChanges {
                        target: columnLayout
                        height: 140
                        anchors.topMargin: 115
                        spacing: 10
                    }
                }
            ]
        }
    }
}
