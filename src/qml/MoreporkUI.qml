import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.9
import ProcessTypeEnum 1.0
import ConnectionStateEnum 1.0
import FreStepEnum 1.0
import MachineTypeEnum 1.0
import ExtruderTypeEnum 1.0
import QtQuick.VirtualKeyboard 2.3

ApplicationWindow {
    id: rootAppWindow
    visible: true
    width: 800
    height: 480
    readonly property string defaultString: "default"
    readonly property string emptyString: ""
    property var currentItem: mainMenu
    property var activeDrawer
    property bool authRequest: bot.isAuthRequestPending
    property bool installUnsignedFwRequest: bot.isInstallUnsignedFwRequestPending
    property bool updatingExtruderFirmware: bot.updatingExtruderFirmware
    property bool skipAuthentication: false
    property bool isAuthenticated: false
    property bool isNetworkConnectionAvailable: (bot.net.interface == "ethernet" ||
                                                 bot.net.interface == "wifi")

    property bool safeToRemoveUsb: bot.safeToRemoveUsb
    onSafeToRemoveUsbChanged: {
        if(safeToRemoveUsb && isFreComplete) {
            safeToRemoveUsbPopup.open()
        }
    }

    property int connectionState: bot.state
    onConnectionStateChanged: {
        if(connectionState == ConnectionState.Connected) {
            fre.initialize()
            fre.setFreStep(FreStep.Welcome)
            if(isNetworkConnectionAvailable) {
                bot.firmwareUpdateCheck(false)
            }
        }
    }

    property bool inFreStep: false
    property bool isFreComplete: fre.currentFreStep == FreStep.FreComplete
    property int currentFreStep: fre.currentFreStep
    onCurrentFreStepChanged: {
        inFreStep = false
        switch(currentFreStep) {
        case FreStep.Welcome:
            freScreen.state = "base state"
            break;
        case FreStep.SetupWifi:
            freScreen.state = "wifi_setup"
            break;
        case FreStep.SoftwareUpdate:
            freScreen.state = "software_update"
            break;
        case FreStep.NamePrinter:
            freScreen.state = "name_printer"
            break;
        case FreStep.SetTimeDate:
            freScreen.state = "set_time_date"
            break;
        case FreStep.AttachExtruders:
            freScreen.state = "attach_extruders"
            break;
        case FreStep.LevelBuildPlate:
            freScreen.state = "level_build_plate"
            break;
        case FreStep.CalibrateExtruders:
            freScreen.state = "calibrate_extruders"
            break;
        case FreStep.LoadMaterial:
            freScreen.state = "load_material"
            break;
        case FreStep.TestPrint:
            freScreen.state = "test_print"
            break;
        case FreStep.LoginMbAccount:
            freScreen.state = "log_in"
            break;
        case FreStep.SetupComplete:
            freScreen.state = "setup_complete"
            break;
        case FreStep.FreComplete:
            break;
        default:
            freScreen.state = "base state"
            break;
        }
    }

    Timer {
        id: authTimeOut
        onTriggered: {
            if(authRequest) {
                bot.respondAuthRequest("timedout")
                authenticatePrinterPopup.close()
                authTimeOut.stop()
            }
            else {
                authenticatePrinterPopup.close()
                authTimeOut.stop()
            }
        }
    }

    onSkipAuthenticationChanged: {
        authenticate_rectangle.color = "#ffffff"
        authenticate_text.color = "#000000"
    }

    onAuthRequestChanged: {
        if(authRequest) {
            authenticatePrinterPopup.open()
            authTimeOut.interval = 300000
            authTimeOut.start()
        }
        else {
            authTimeOut.interval = 1500
            authTimeOut.start()
        }
    }

    onInstallUnsignedFwRequestChanged: {
        if(installUnsignedFwRequest) {
            // Open popup
            installUnsignedFwPopup.open()
        }
        else {
            // Close popup
            installUnsignedFwPopup.close()
        }

    }

    property bool isfirmwareUpdateAvailable: bot.firmwareUpdateAvailable

    property bool skipFirmwareUpdate: false
    property bool viewReleaseNotes: false

    onSkipFirmwareUpdateChanged: {
        update_rectangle.color = "#ffffff"
        update_text.color = "#000000"
    }

    function setCurrentItem(currentItem_) {
        currentItem = currentItem_
    }

    function goBack() {
        if(currentItem.hasAltBack) {
            currentItem.altBack()
        }
        else {
            currentItem.backSwiper.swipeToItem(currentItem.backSwipeIndex)
        }
    }

    function isProcessRunning() {
        return (bot.process.type != ProcessType.None)
    }

    function isFilterConnected() {
        return bot.hepaFilterConnected
    }

    FontLoader {
        id: defaultFont
        name: "Antenna"
    }

    property string productName: {
        if (bot.machineType == MachineType.Fire) {
            "Method"
        } else if (bot.machineType == MachineType.Lava) {
            "Method X"
        } else if (bot.machineType == MachineType.Magma) {
            "Method XL"
        }
    }

    enum SwipeIndex {
        BasePage,       // 0
        PrintPage,      // 1
        ExtruderPage,   // 2
        SettingsPage,   // 3
        InfoPage,       // 4
        MaterialPage    // 5
    }

    Item {
        id: rootItem
        smooth: false
        rotation: 0
        anchors.fill: parent
        objectName: "morepork_main_qml"
        z: 0

        Rectangle {
            id: rectangle
            color: "#000000"
            smooth: false
            z: -1
            anchors.fill: parent
        }

        Item {
            id: inputPanelContainer
            z: 10
            smooth: false
            antialiasing: false
            visible: {
                (dayOneUpdateScreen.state == "connect_to_wifi" &&
                 dayOneUpdateScreen.wifiPageDayOneUpdate.wifiSwipeView.currentIndex == WiFiPage.EnterPassword)
            }
            x: -30
            y: parent.height - inputPanel.height + 22
            width: 860
            height: inputPanel.height
            InputPanel {
                id: inputPanel
                antialiasing: false
                smooth: false
                anchors.fill: parent
                active: true
            }
            onVisibleChanged: {
                if (visible) {
                    bot.pause_touchlog()
                } else {
                    bot.resume_touchlog()
                }
            }
        }

        StartupSplashScreen {
            id: startupSplashScreen
            anchors.fill: parent
            z: 3
            visible: connectionState != ConnectionState.Connected
        }

        DayOneUpdateScreen {
            id: dayOneUpdateScreen
            anchors.fill: parent
            z: 2
            visible: true
        }

        FirmwareUpdateSuccessfulScreen {
            anchors.fill: parent
            z: 2
            visible: fre.isFirstBoot &&
                     connectionState == ConnectionState.Connected
        }

        FrePage {
            id: freScreen
            visible: connectionState == ConnectionState.Connected &&
                     !isFreComplete && !inFreStep
        }

        LoggingPopup {
            popupName: "AuthenticatePrinter"
            id: authenticatePrinterPopup
            width: 800
            height: 480
            modal: true
            dim: false
            focus: true
            closePolicy: Popup.CloseOnPressOutside
            parent: overlay
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
            onOpened: {
                authenticate_rectangle.color = "#ffffff"
                authenticate_text.color = "#000000"
                isAuthenticated = false
                skipAuthentication = false
            }
            onClosed: {
                isAuthenticated = false
                skipAuthentication = false
            }

            Rectangle {
                id: basePopupItem
                color: "#000000"
                rotation: rootItem.rotation == 180 ? 180 : 0
                width: 740
                height: skipAuthentication ? 225 : 410
                radius: 10
                border.width: 2
                border.color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                Item {
                    id: columnLayout
                    width: 600
                    height: 300
                    anchors.top: parent.top
                    anchors.topMargin: isAuthenticated ? 60 : 35
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        id: authenticate_header_text
                        color: "#cbcbcb"
                        text: isAuthenticated ? qsTr("AUTHENTICATION COMPLETE") : skipAuthentication ? qsTr("CANCEL AUTHENTICATION") : qsTr("AUTHENTICATION REQUEST")
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.letterSpacing: 5
                        font.family: defaultFont.name
                        font.weight: Font.Bold
                        font.pixelSize: 22
                    }

                    Image {
                        id: authImage
                        width: sourceSize.width * 0.517
                        height: sourceSize.height * 0.517
                        anchors.topMargin: 17
                        anchors.top: authenticate_header_text.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: skipAuthentication ? "" : isAuthenticated ? "qrc:/img/auth_success.png" : "qrc:/img/auth_waiting.png"
                        visible: !skipAuthentication
                    }

                    Text {
                        id: authenticate_description_text1
                        color: isAuthenticated ? "#ffffff" : "#cbcbcb"
                        text: isAuthenticated ? bot.username : skipAuthentication ? qsTr("Are you sure you want to cancel?") : qsTr("Would you like to authenticate")
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 17
                        anchors.top: authImage.bottom
                        horizontalAlignment: Text.AlignLeft
                        font.weight: isAuthenticated ? Font.Bold : Font.Light
                        font.family: defaultFont.name
                        font.pixelSize: 18
                        font.letterSpacing: isAuthenticated ? 3 : 1
                        font.capitalization: isAuthenticated ? Font.AllUppercase : Font.MixedCase
                    }

                    RowLayout {
                        id: item2
                        width: children.width
                        height: 20
                        anchors.topMargin: 17
                        anchors.top: authenticate_description_text1.bottom
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            id: authenticate_description_text2
                            color: "#ffffff"
                            text: skipAuthentication ? "" : bot.username
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            font.weight: Font.Bold
                            font.capitalization: Font.AllUppercase
                            font.family: defaultFont.name
                            font.pixelSize: 18
                            font.letterSpacing: 3
                            visible: !isAuthenticated
                        }

                        Text {
                            id: authenticate_description_text3
                            color: "#cbcbcb"
                            text: isAuthenticated ? qsTr("is now authenticated to this printer") : qsTr("to this printer?")
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            font.weight: Font.Light
                            font.family: defaultFont.name
                            font.pixelSize: 18
                            font.letterSpacing: 1
                            visible: !skipAuthentication
                        }
                    }
                }

                Rectangle {
                    id: horizontal_divider
                    width: parent.width
                    height: 2
                    color: "#ffffff"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 72
                    visible: !isAuthenticated
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
                    visible: !isAuthenticated
                }

                Item {
                    id: item1
                    width: parent.width
                    height: 72
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    visible: !isAuthenticated

                    Rectangle {
                        id: dismiss_rectangle
                        x: 0
                        y: 0
                        width: parent.width * 0.5
                        height: 72
                        color: "#00000000"
                        radius: 10

                        Text {
                            id: dismiss_text
                            color: "#ffffff"
                            text: skipAuthentication ? qsTr("BACK") : qsTr("DISMISS")
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
                            logText: "authenticatePrinterPopup: [_" + dismiss_text.text + "|]"
                            id: dismiss_mouseArea
                            anchors.fill: parent
                            onPressed: {
                                dismiss_text.color = "#000000"
                                dismiss_rectangle.color = "#ffffff"
                                authenticate_text.color = "#ffffff"
                                authenticate_rectangle.color = "#00000000"
                            }
                            onReleased: {
                                dismiss_text.color = "#ffffff"
                                dismiss_rectangle.color = "#00000000"
                            }
                            onClicked: {
                                if(skipAuthentication == false) {
                                    skipAuthentication = true
                                }
                                else if(skipAuthentication == true) {
                                    skipAuthentication = false
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: authenticate_rectangle
                        x: parent.width * 0.5
                        y: 0
                        width: parent.width * 0.5
                        height: 72
                        color: "#00000000"
                        radius: 10

                        Text {
                            id: authenticate_text
                            color: "#ffffff"
                            text: skipAuthentication ? qsTr("CONTINUE") : qsTr("AUTHENTICATE")
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.letterSpacing: 3
                            font.weight: Font.Bold
                            font.family: defaultFont.name
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        LoggingMouseArea {
                            logText: "authenticatePrinterPopup: [|" + authenticate_text.text + "_]"
                            id: authenticate_mouseArea
                            anchors.fill: parent
                            onPressed: {
                                authenticate_text.color = "#000000"
                                authenticate_rectangle.color = "#ffffff"
                            }
                            onReleased: {
                                authenticate_text.color = "#ffffff"
                                authenticate_rectangle.color = "#00000000"
                            }
                            onClicked: {
                                if(skipAuthentication == false) {
                                    bot.respondAuthRequest("accepted")
                                    isAuthenticated = true
                                }
                                else if(skipAuthentication == true) {
                                    bot.respondAuthRequest("rejected")
                                    authenticatePrinterPopup.close()
                                }
                            }
                        }
                    }
                }
            }
        }

        LoggingPopup {
            popupName: "InstallUnsignedFirmware"
            id: installUnsignedFwPopup
            width: 800
            height: 480
            modal: true
            dim: false
            focus: true
            closePolicy: Popup.CloseOnPressOutside
            parent: overlay
            background: Rectangle {
                id: installUnsignedFwPopupBackgroundDim
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
            onOpened: {
                cancel_rectangle.color = "#ffffff"
                cancel_text.color = "#000000"
            }
            onClosed: {
            }

            Rectangle {
                id: installUnsignedFwBasePopupItem
                color: "#000000"
                rotation: rootItem.rotation == 180 ? 180 : 0
                width: 740
                height: 250
                radius: 10
                border.width: 2
                border.color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                Item {
                    id: installUnsignedFwColumnLayout
                    width: 600
                    height: 300
                    anchors.top: parent.top
                    anchors.topMargin: 35
                    anchors.horizontalCenter: parent.horizontalCenter
                    // Title of Popup
                    Text {
                        id: install_unsigned_fw_header_text
                        color: "#cbcbcb"
                        text: qsTr("UNKNOWN FIRMWARE")
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.letterSpacing: 5
                        font.family: defaultFont.name
                        font.weight: Font.Bold
                        font.pixelSize: 22
                    }
                    // Main question that appears in the popup
                    Text {
                        id: install_unsigned_fw_description_text1
                        color: "#cbcbcb"
                        text: qsTr("You are installing an unknown firmware, this can damage your printer and void your warranty. Are you sure you want to proceed?")
                        // To specify a WordWrap property, the width must be defined
                        width: parent.width
                        wrapMode: Text.WordWrap
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 17
                        anchors.top: install_unsigned_fw_header_text.bottom
                        horizontalAlignment: Text.AlignHCenter
                        font.weight: Font.Light
                        font.family: defaultFont.name
                        font.pixelSize: 18
                        font.letterSpacing: 3
                        font.capitalization: Font.MixedCase
                    }
                }

                Rectangle {
                    id: install_unsigned_fw_horizontal_divider
                    width: parent.width
                    height: 2
                    color: "#ffffff"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 72
                    visible: true
                }

                Rectangle {
                    id: install_unsigned_fw_vertical_divider
                    x: 359
                    y: 328
                    width: 2
                    height: 72
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: true
                }

                Item {
                    id: install_unsigned_fw_item1
                    width: parent.width
                    height: 72
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    visible: true

                    Rectangle {
                        id: install_rectangle
                        x: 0
                        y: 0
                        width: parent.width * 0.5
                        height: 72
                        color: "#00000000"
                        radius: 10

                        Text {
                            id: install_text
                            color: "#ffffff"
                            text: qsTr("INSTALL")
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
                            logText: "installUnsignedFwBasePopupItem: [_" + install_text.text + "|]"
                            id: install_mouseArea
                            anchors.fill: parent
                            onPressed: {
                                install_text.color = "#000000"
                                install_rectangle.color = "#ffffff"
                                cancel_text.color = "#ffffff"
                                cancel_rectangle.color = "#00000000"
                            }
                            onReleased: {
                                install_text.color = "#ffffff"
                                install_rectangle.color = "#00000000"
                            }
                            onClicked: {
                                bot.respondInstallUnsignedFwRequest("allow")
                                installUnsignedFwPopup.close()
                            }
                        }
                    }

                    Rectangle {
                        id: cancel_rectangle
                        x: parent.width * 0.5
                        y: 0
                        width: parent.width * 0.5
                        height: 72
                        color: "#00000000"
                        radius: 10

                        Text {
                            id: cancel_text
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
                            logText: "installUnsignedFwBasePopupItem: [|" + cancel_text.text + "_]"
                            id: cancel_mouseArea
                            anchors.fill: parent
                            onPressed: {
                                cancel_text.color = "#000000"
                                cancel_rectangle.color = "#ffffff"
                            }
                            onReleased: {
                                cancel_text.color = "#ffffff"
                                cancel_rectangle.color = "#00000000"
                            }
                            onClicked: {
                                bot.respondInstallUnsignedFwRequest("rejected")
                                installUnsignedFwPopup.close()
                            }
                        }
                    }
                }
            }
        }

        LoggingPopup {
            popupName: "SafeToRemoveUsb"
            id: safeToRemoveUsbPopup
            width: 800
            height: 480
            modal: true
            dim: false
            focus: true
            parent: overlay
            closePolicy: Popup.CloseOnPressOutside
            background: Rectangle {
                id: popupBackgroundDim_remove_usb_popup
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

            Rectangle {
                id: basePopupItem_remove_usb_popup
                color: "#000000"
                rotation: rootItem.rotation == 180 ? 180 : 0
                width: 720
                height: 220
                radius: 10
                border.width: 2
                border.color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    id: horizontal_divider_remove_usb_popup
                    width: 720
                    height: 2
                    color: "#ffffff"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 72
                }

                Item {
                    id: buttonBar_remove_usb_popup
                    width: 720
                    height: 72
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0

                    Rectangle {
                        id: ok_rectangle_remove_usb_popup
                        x: 0
                        y: 0
                        width: 720
                        height: 72
                        color: "#00000000"
                        radius: 10

                        Text {
                            id: ok_text_remove_usb_popup
                            color: "#ffffff"
                            text: qsTr("OK")
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
                            logText: "safeToRemoveUsbPopup [" + ok_text_remove_usb_popup.text + "]"
                            id: ok_mouseArea_remove_usb_popup
                            anchors.fill: parent
                            onPressed: {
                                ok_text_remove_usb_popup.color = "#000000"
                                ok_rectangle_remove_usb_popup.color = "#ffffff"
                            }
                            onReleased: {
                                ok_text_remove_usb_popup.color = "#ffffff"
                                ok_rectangle_remove_usb_popup.color = "#00000000"
                            }
                            onClicked: {
                                bot.acknowledgeSafeToRemoveUsb()
                                safeToRemoveUsbPopup.close()
                            }
                        }
                    }
                }

                ColumnLayout {
                    id: columnLayout_remove_usb_popup
                    width: 590
                    height: 100
                    anchors.top: parent.top
                    anchors.topMargin: 25
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        id: remove_usb_text_remove_usb_popup
                        color: "#cbcbcb"
                        text: qsTr("YOU CAN NOW SAFELY REMOVE THE USB")
                        font.letterSpacing: 3
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.family: defaultFont.name
                        font.weight: Font.Bold
                        font.pixelSize: 20
                    }
                }
            }
        }
    }
}
