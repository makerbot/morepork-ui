import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.VirtualKeyboard 2.3
import WifiStateEnum 1.0
import WifiErrorEnum 1.0
import FreStepEnum 1.0

Item {
    width: 800
    height: 440
    smooth: false
    antialiasing: false
    property alias defaultItem: itemChooseWifi
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
            if(wifiPopup.opened){
                wifiPopup.close()
            }
            if(wifiSwipeView.currentIndex != 0) {
                wifiSwipeView.swipeToItem(0)
            }
            bot.scanWifi(true)
            passwordField.clear()
            if(inFreStep) {
                wifiFreStepComplete.start()
                bot.firmwareUpdateCheck(false)
            }
        }
        else {
            bot.net.setWifiState(WifiState.NotConnected)
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
            settingsPage.settingsSwipeView.swipeToItem(0)
            mainSwipeView.swipeToItem(0)
            if(isfirmwareUpdateAvailable) {
                fre.gotoNextStep(currentFreStep)
            }
            else {
                fre.setFreStep(FreStep.NamePrinter)
            }
        }
    }

    SwipeView {
        id: wifiSwipeView
        smooth: false
        currentIndex: 0 // Should never be non zero
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = wifiSwipeView.currentIndex
            wifiSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            setCurrentItem(wifiSwipeView.itemAt(itemToDisplayDefaultIndex))
            wifiSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            wifiSwipeView.itemAt(prevIndex).visible = false
        }

        // settingsSwipeView.index = 0
        Item {
            id: itemChooseWifi
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: true

            // When the bot is not connected to wifi and the user
            // performs a wifi scan. In this case a deep scan happens
            // and it takes sometime to return the results. Once the
            // results are returned the bot goes into one of
            // 'Not Connected' or 'NoWifiFound' states.
            Text {
                color: "#ffffff"
                font.family: "Antennae"
                font.weight: Font.Light
                text: {
                    if(!bot.net.wifiEnabled) {
                        "Turn on WiFi and try again."
                    } else if (bot.net.wifiState == WifiState.Searching) {
                        "Searching..."
                    } else if (bot.net.wifiState == WifiState.NoWifiFound) {
                        "No wireless networks found."
                    } else if (bot.net.wifiState == WifiState.NotConnected &&
                            bot.net.wifiError != WifiError.NoError) {
                        "Search for wireless networks failed."
                    }
                }
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -20
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 20
                visible: bot.net.wifiState == WifiState.Searching ||
                         bot.net.wifiState == WifiState.NoWifiFound ||
                         (bot.net.wifiState == WifiState.NotConnected &&
                                (bot.net.wifiError == WifiError.ScanFailed ||
                                 bot.net.wifiError == WifiError.UnknownError))
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
            BusyIndicator {
                id: wifiBusyIndicator
                running: true
                visible: wifiList.count == 0 &&
                        (isWifiConnected ||
                         bot.net.wifiState == WifiState.Connected)
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -20
                anchors.horizontalCenter: parent.horizontalCenter


                contentItem: Item {
                        implicitWidth: 64
                        implicitHeight: 64

                        Item {
                            id: item
                            x: parent.width / 2 - 32
                            y: parent.height / 2 - 32
                            width: 64
                            height: 64
                            opacity: wifiBusyIndicator.running ? 1 : 0

                            Behavior on opacity {
                                OpacityAnimator {
                                    duration: 250
                                }
                            }

                            RotationAnimator {
                                target: item
                                running: wifiBusyIndicator.visible && wifiBusyIndicator.running
                                from: 0
                                to: 360
                                loops: Animation.Infinite
                                duration: 1500
                            }

                            Repeater {
                                id: repeater
                                model: 6

                                Rectangle {
                                    x: item.width / 2 - width / 2
                                    y: item.height / 2 - height / 2
                                    implicitWidth: 2
                                    implicitHeight: 16
                                    radius: 0
                                    color: "#ffffff"
                                    transform: [
                                        Translate {
                                            y: -Math.min(item.width, item.height) * 0.5 + 5
                                        },
                                        Rotation {
                                            angle: index / repeater.count * 360
                                            origin.x: 1
                                            origin.y: 8
                                        }
                                    ]
                                }
                            }
                        }
                    }
            }

            // The wifi list shows up when the scan retuns atleast
            // one wifi network or the bot is connected to a WiFi
            // network.
            ListView {
                id: wifiList
                smooth: false
                antialiasing: false
                anchors.fill: parent
                boundsBehavior: Flickable.DragOverBounds
                spacing: 1
                orientation: ListView.Vertical
                flickableDirection: Flickable.VerticalFlick
                visible: bot.net.wifiState == WifiState.Connected ||
                         bot.net.wifiState == WifiState.NotConnected ||
                         isWifiConnected
                model: bot.net.WiFiList

                delegate:
                    WiFiButton {
                    smooth: false
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
                                wifiSwipeView.swipeToItem(1)
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

        // settingsSwipeView.index = 1
        Item {
            id: itemEnterPassword
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: wifiSwipeView
            property int backSwipeIndex: 0
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                passwordField.clear()
                showPassword.checked = false
                wifiSwipeView.swipeToItem(0)
            }

            Item {
                id: appContainer
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: inputPanelContainer.top
                smooth: false
                antialiasing: false

                Text {
                    text: "ENTER PASSWORD FOR " + selectedWifiName
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 1.5
                    font.wordSpacing: 1
                    font.pointSize: 12
                    color: "#ffffff"
                    anchors.left: passwordField.left
                    anchors.bottom: passwordField.top
                    anchors.bottomMargin: 10
                    font.family: "Antennae"
                    font.weight: Font.Light
                }

                TextField {
                    id: passwordField
                    width: 440
                    height: 44
                    smooth: false
                    antialiasing: false
                    anchors.top: parent.top
                    anchors.topMargin: 50
                    anchors.left: parent.left
                    anchors.leftMargin: 50
                    background:
                        Rectangle {
                            radius: 2
                            anchors.fill: parent
                            color: "#f7f7f7"
                        }
                    color: "#000000"
                    font.family: "Antennae"
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

                RoundedButton {
                    id: connectButton
                    anchors.left: passwordField.right
                    anchors.leftMargin: 20
                    anchors.top: parent.top
                    anchors.topMargin: 48
                    label_width: 150
                    label: "CONNECT"
                    buttonWidth: 160
                    buttonHeight: 50
                    button_mouseArea.onClicked: {
                        bot.net.setWifiState(WifiState.Connecting)
                        wifiPopup.open()
                        bot.connectWifi(selectedWifiPath,
                                        passwordField.text,
                                        selectedWifiName)
                    }
                }

                RowLayout {
                    id: rowLayout
                    anchors.leftMargin: -3
                    anchors.top: passwordField.bottom
                    anchors.topMargin: 10
                    anchors.left: passwordField.left
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

                    Text {
                        id: show_password_text
                        color: "#ffffff"
                        text: "Show Password"
                        font.letterSpacing: 2
                        font.family: "Antennae"
                        font.weight: Font.Light
                        font.pixelSize: 18
                    }
                }
            }

            Item {
                id: inputPanelContainer
                smooth: false
                antialiasing: false
                visible: settingsSwipeView.currentIndex == 3 &&
                         wifiSwipeView.currentIndex == 1
                x: -30
                y: parent.height - inputPanel.height
                width: 860
                height: inputPanel.height
                InputPanel {
                    id: inputPanel
                    //y: Qt.inputMethod.visible ? parent.height - inputPanel.height : parent.height
                    antialiasing: false
                    smooth: false
                    anchors.fill: parent
                }
            }
        }
    }

    Popup {
        id: wifiPopup
        width: 800
        height: 480
        modal: true
        dim: false
        focus: true
        parent: overlay
        closePolicy: Popup.CloseOnPressOutside
        background: Rectangle {
            id: popupBackgroundDim
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

        Rectangle {
            id: basePopupItem
            color: "#000000"
            rotation: rootItem.rotation == 180 ? 180 : 0
            width: 720
            height: ((bot.net.wifiState == WifiState.Connecting ||
                     bot.net.wifiState == WifiState.Connected ||
                     bot.net.wifiError != WifiError.NoError) &&
                        !isForgetEnabled) ? 320 : 220
            radius: 10
            border.width: 2
            border.color: "#ffffff"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                id: horizontal_divider
                width: 720
                height: 2
                color: "#ffffff"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 72
            }

            Rectangle {
                id: vertical_divider
                x: 359
                y: 328
                width: 2
                height: 72
                color: "#ffffff"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.horizontalCenter: parent.horizontalCenter
                visible: bot.net.wifiState == WifiState.Disconnecting ||
                         isForgetEnabled
            }

            Item {
                id: buttonBar
                width: 720
                height: 72
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                Rectangle {
                    id: left_rectangle
                    x: 0
                    y: 0
                    width: 360
                    height: 72
                    color: "#00000000"
                    radius: 10
                    visible: bot.net.wifiState == WifiState.Disconnecting ||
                             isForgetEnabled

                    Text {
                        id: left_text
                        color: "#ffffff"
                        text: "YES"
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
                        id: left_mouseArea
                        anchors.fill: parent
                        onPressed: {
                            left_rectangle.color = "#ffffff"
                            left_text.color = "#000000"
                        }
                        onReleased: {
                            left_rectangle.color = "#00000000"
                            left_text.color = "#ffffff"
                        }
                        onClicked: {
                            if(bot.net.wifiState == WifiState.Disconnecting) {
                                bot.disconnectWifi(selectedWifiPath)
                            }
                            else if(isForgetEnabled) {
                                bot.forgetWifi(selectedWifiPath)
                            }
                            bot.scanWifi(true)
                            wifiPopup.close()
                        }
                    }
                }

                Rectangle {
                    id: right_rectangle
                    x: 360
                    y: 0
                    width: 360
                    height: 72
                    color: "#00000000"
                    radius: 10
                    visible: bot.net.wifiState == WifiState.Disconnecting ||
                             isForgetEnabled

                    Text {
                        id: right_text
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
                        id: right_mouseArea
                        anchors.fill: parent
                        onPressed: {
                            right_rectangle.color = "#ffffff"
                            right_text.color = "#000000"
                        }
                        onReleased: {
                            right_rectangle.color = "#00000000"
                            right_text.color = "#ffffff"
                        }
                        onClicked: {
                            if(isForgetEnabled || bot.net.wifiState == WifiState.Disconnecting) {
                                wifiPopup.close()
                            }
                        }
                    }
                }

                Rectangle {
                    id: full_button_rectangle
                    x: 0
                    y: 0
                    width: 720
                    height: 72
                    color: "#00000000"
                    radius: 10
                    visible: !isForgetEnabled &&
                             (bot.net.wifiState == WifiState.Connecting ||
                             bot.net.wifiState == WifiState.NotConnected ||
                             bot.net.wifiError == wifiError.ConnectFailed ||
                             bot.net.wifiError == wifiError.InvalidPassword)

                    Text {
                        id: full_button_text
                        color: "#ffffff"
                        text: {
                            if(bot.net.wifiState == WifiState.Connecting) {
                                "CANCEL"
                            }
                            else {
                                if(bot.net.wifiError == WifiError.ConnectFailed) {
                                    "RETRY"
                                }
                                else if(bot.net.wifiError == WifiError.InvalidPassword) {
                                    "CLOSE"
                                }
                                else {
                                    "CLOSE"
                                }
                            }
                        }

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
                        id: full_button_mouseArea
                        anchors.fill: parent
                        onPressed: {
                            full_button_rectangle.color = "#ffffff"
                            full_button_text.color = "#000000"
                        }
                        onReleased: {
                            full_button_rectangle.color = "#00000000"
                            full_button_text.color = "#ffffff"
                        }
                        onClicked: {
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
                            else if(bot.net.wifiState == WifiState.NotConnected) {
                                wifiPopup.close()
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                id: columnLayout
                width: 590
                height: ((bot.net.wifiState == WifiState.Connecting ||
                         bot.net.wifiState == WifiState.Connected ||
                         bot.net.wifiError != WifiError.NoError) &&
                            !isForgetEnabled) ? 150 : 100
                anchors.top: parent.top
                anchors.topMargin: ((bot.net.wifiState == WifiState.Connecting ||
                                    bot.net.wifiState == WifiState.Connected ||
                                    bot.net.wifiError != WifiError.NoError) &&
                                        !isForgetEnabled)? 60 : 25
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: header_text
                    color: "#cbcbcb"
                    text: {
                        if(isForgetEnabled) {
                            "FORGET " + selectedWifiName + "?"
                        }
                        else if(bot.net.wifiState == WifiState.Connecting ||
                                bot.net.wifiState == WifiState.Connected ||
                                bot.net.wifiState == WifiState.Connected) {
                            "CONNECTING TO " + selectedWifiName
                        }
                        else if(bot.net.wifiState == WifiState.Disconnecting) {
                            "DISCONNECT FROM " + selectedWifiName + "?"
                        }
                        else {
                            if(bot.net.wifiError == WifiError.InvalidPassword) {
                                "INVALID PASSWORD"
                            }
                            else if(bot.net.wifiError == WifiError.ConnectFailed) {
                                "FAILED TO CONNECT TO " + selectedWifiName
                            }
                            else if(bot.net.wifiState == WifiState.NotConnected) {
                                "CONNECTION FAILED"
                            }
                        }
                    }
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 3
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: "Antennae"
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                BusyIndicator {
                    id: wifiConnectingBusy
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    running: true
                    visible: (bot.net.wifiState == WifiState.Connecting ||
                             bot.net.wifiState == WifiState.Connected) &&
                             !isForgetEnabled

                    contentItem: Item {
                            implicitWidth: 64
                            implicitHeight: 64

                            Item {
                                id: item1
                                x: parent.width / 2 - 32
                                y: parent.height / 2 - 32
                                width: 64
                                height: 64
                                opacity: wifiConnectingBusy.running ? 1 : 0

                                Behavior on opacity {
                                    OpacityAnimator {
                                        duration: 250
                                    }
                                }

                                RotationAnimator {
                                    target: item1
                                    running: wifiConnectingBusy.visible && wifiConnectingBusy.running
                                    from: 0
                                    to: 360
                                    loops: Animation.Infinite
                                    duration: 1500
                                }

                                Repeater {
                                    id: repeater1
                                    model: 6

                                    Rectangle {
                                        x: item1.width / 2 - width / 2
                                        y: item1.height / 2 - height / 2
                                        implicitWidth: 2
                                        implicitHeight: 16
                                        radius: 0
                                        color: "#ffffff"
                                        transform: [
                                            Translate {
                                                y: -Math.min(item1.width, item1.height) * 0.5 + 5
                                            },
                                            Rotation {
                                                angle: index / repeater1.count * 360
                                                origin.x: 1
                                                origin.y: 8
                                            }
                                        ]
                                    }
                                }
                            }
                        }
                }

                Item {
                    id: errorImageContainer
                    width: 80
                    height: 80
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    visible: bot.net.wifiError != WifiError.NoError &&
                             bot.net.wifiState == WifiState.NotConnected

                    Image {
                        id: error_image
                        anchors.fill: parent
                        source: "qrc:/img/error.png"
                    }
                }
            }
        }
    }
}
