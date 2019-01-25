import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ConnectionStateEnum 1.0
import FreStepEnum 1.0

ApplicationWindow {
    id: rootAppWindow
    visible: true
    width: 800
    height: 480
    property alias mainSwipeView: mainSwipeView
    property alias topBar: topBar
    property var currentItem: mainMenu
    property var activeDrawer
    property bool authRequest: bot.isAuthRequestPending
    property bool installUnsignedFwRequest: bot.isInstallUnsignedFwRequestPending
    property bool updatingExtruderFirmware: bot.updatingExtruderFirmware
    property int extruderFirmwareUpdateProgressA: bot.extruderFirmwareUpdateProgressA
    property int extruderFirmwareUpdateProgressB: bot.extruderFirmwareUpdateProgressB
    property bool skipAuthentication: false
    property bool isAuthenticated: false
    property bool isBuildPlateClear: bot.process.isBuildPlateClear
    property bool updatedExtruderFirmwareA: false
    property bool updatedExtruderFirmwareB: false

    property bool safeToRemoveUsb: bot.safeToRemoveUsb
    onSafeToRemoveUsbChanged: {
        if(safeToRemoveUsb) {
            safeToRemoveUsbPopup.open()
        }
    }

    property int connectionState: bot.state
    onConnectionStateChanged: {
        if(connectionState == ConnectionState.Connected) {
            fre.initialize()
            if(bot.net.interface == "ethernet" ||
               bot.net.interface == "wifi") {
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
        case FreStep.LoginMbAccount:
            freScreen.state = "log_in"
            break;
        case FreStep.AttachExtruders:
            freScreen.state = "attach_extruders"
            break;
        case FreStep.LoadMaterial:
            freScreen.state = "load_material"
            break;
        case FreStep.TestPrint:
            freScreen.state = "test_print"
            break;
        case FreStep.SetupComplete:
            freScreen.state = "setup_complete"
            break;
        case FreStep.FreComplete:
            break;
        default:
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

    onUpdatingExtruderFirmwareChanged: {
        if(updatingExtruderFirmware) {
            updatingExtruderFirmwarePopup.open()
        }
        else {
            updatingExtruderFirmwarePopup.close()
        }
    }

    // When firmware is finished updating for an extruder, the progress doesn't
    // go to 100 and instead returns to 0. In a situation where both extruders are
    // programming, one could finish before the other and when it finishes, 0% will
    // display instead of 100%. Here we check to see if the percentage passed an
    // arbitrary 90% and if it did, we toggle the updatedExtruderFirmwareA flag so
    // the text will display 100% instead of 0%. We reset this flag when the
    // popups onClosed function is called
    onExtruderFirmwareUpdateProgressAChanged: {
        if(extruderFirmwareUpdateProgressA > 90 && !updatedExtruderFirmwareA) {
            updatedExtruderFirmwareA = true
        }
    }

    // See onExtruderFirmwareUpdateProgressAChanged comment
    onExtruderFirmwareUpdateProgressBChanged: {
        if(extruderFirmwareUpdateProgressB > 90 && !updatedExtruderFirmwareB) {
            updatedExtruderFirmwareB = true
        }
    }
        
    property bool isfirmwareUpdateAvailable: bot.firmwareUpdateAvailable
    
    onIsfirmwareUpdateAvailableChanged: {
        if(isfirmwareUpdateAvailable && isFreComplete) {
            if(settingsPage.settingsSwipeView.currentIndex != 3) {
                firmwareUpdatePopup.open()
            }
        }
    }
    
    property bool skipFirmwareUpdate: false
    property bool viewReleaseNotes: false

    onSkipFirmwareUpdateChanged: {
        update_rectangle.color = "#ffffff"
        update_text.color = "#000000"
    }

    onIsBuildPlateClearChanged: {
        if(isBuildPlateClear) {
            buildPlateClearPopup.open()
        }
    }

    function setDrawerState(state) {
        topBar.imageDrawerArrow.visible = state
        if(activeDrawer == printPage.printingDrawer ||
           activeDrawer == materialPage.materialPageDrawer ||
           activeDrawer == printPage.sortingDrawer) {
            activeDrawer.interactive = state
            if(state) {
                topBar.drawerDownClicked.connect(activeDrawer.open)
            }
            else {
                activeDrawer.close()
                topBar.drawerDownClicked.disconnect(activeDrawer.open)
            }
        }
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

    function disableDrawer() {
        topBar.imageDrawerArrow.visible = false
        if(activeDrawer == printPage.printingDrawer ||
           activeDrawer == materialPage.materialPageDrawer ||
           activeDrawer == printPage.sortingDrawer) {
            activeDrawer.interactive = false
            topBar.drawerDownClicked.disconnect(activeDrawer.open)
        }
    }

    function isProcessRunning() {
        return (bot.process.type != ProcessType.None)
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

        StartupSplashScreen {
            id: startupSplashScreen
            anchors.fill: parent
            z: 2
            visible: connectionState != ConnectionState.Connected
        }

        FirmwareUpdateSuccessfulScreen {
            anchors.fill: parent
            z: 2
            visible: fre.isFirstBoot &&
                     connectionState == ConnectionState.Connected
        }

        Drawer {
            id: backSwipe
            width: rootAppWindow.width
            height: rootAppWindow.height
            edge: rootItem.rotation == 180 ? Qt.RightEdge : Qt.LeftEdge
            dim: false
            opacity: 0
            interactive: mainSwipeView.currentIndex
            onOpened: {
                position = 0
                goBack()
                close()
            }
        }

        TopBarForm {
            id: topBar
            z: 1
            width: parent.width
            smooth: false
            backButton.visible: false
            imageDrawerArrow.visible: false
            visible: mainSwipeView.visible

            onBackClicked: {
                goBack()
            }
        }

        FrePage {
            id: freScreen
            visible: connectionState == ConnectionState.Connected &&
                     !isFreComplete && !inFreStep
        }

        SwipeView {
            id: mainSwipeView
            anchors.fill: parent
            anchors.topMargin: topBar.barHeight
            interactive: false
            transform: Translate {
                x: backSwipe.position * mainSwipeView.width * 1.5
            }
            property alias materialPage: materialPage
            smooth: false
            visible: connectionState == ConnectionState.Connected &&
                     !freScreen.visible

            function swipeToItem(itemToDisplayDefaultIndex) {
                var prevIndex = mainSwipeView.currentIndex
                mainSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
                if(itemToDisplayDefaultIndex === 0) {
                    mainSwipeView.setCurrentIndex(0)
                    topBar.backButton.visible = false
                    if(!printPage.isPrintProcess) {
                        disableDrawer()
                    }
                }
                else {
                    mainSwipeView.itemAt(itemToDisplayDefaultIndex).defaultItem.visible = true
                    setCurrentItem(mainSwipeView.itemAt(itemToDisplayDefaultIndex).defaultItem)
                    mainSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
                    topBar.backButton.visible = true
                }
                mainSwipeView.itemAt(prevIndex).visible = false
            }

            // mainSwipeView.index = 0
            Item {
                smooth: false
                MainMenu {
                    id: mainMenu
                    anchors.fill: parent

                    mainMenuIcon_print.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(1)
                    }

                    mainMenuIcon_extruder.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(2)
                    }

                    mainMenuIcon_settings.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(3)
                    }

                    mainMenuIcon_info.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(4)
                    }

                    mainMenuIcon_material.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(5)
                    }

                    mainMenuIcon_advanced.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(6)
                    }
                }
            }

            // mainSwipeView.index = 1
            Item {
                property alias defaultItem: printPage.defaultItem
                smooth: false
                visible: false
                PrintPage {
                    id: printPage
                    smooth: false
                    anchors.fill: parent
                }
            }

            // mainSwipeView.index = 2
            Item {
                property int defaultIndex: 2
                property alias defaultItem: extruderPage.defaultItem
                smooth: false
                visible: false
                ExtruderPage {
                    id: extruderPage
                    anchors.fill: parent
                }
            }

            // mainSwipeView.index = 3
            Item {
                property int defaultIndex: 3
                property alias defaultItem: settingsPage.defaultItem
                smooth: false
                visible: false
                SettingsPage {
                    id: settingsPage
                    smooth: false
                    anchors.fill: parent
                    anchors.topMargin: topBar.topFadeIn.height - topBar.barHeight
                }
            }

            // mainSwipeView.index = 4
            Item {
                property int defaultIndex: 4
                property alias defaultItem: infoPage.defaultItem
                smooth: false
                visible: false
                InfoPage {
                    id: infoPage
                    anchors.fill: parent
                    anchors.topMargin: topBar.topFadeIn.height - topBar.barHeight
                }
            }

            // mainSwipeView.index = 5
            Item {
                property int defaultIndex: 5
                property alias defaultItem: materialPage.defaultItem
                smooth: false
                visible: false
                MaterialPage {
                    id: materialPage
                    smooth: false
                    anchors.fill: parent
                }
            }

            // mainSwipeView.index = 6
            Item {
                property int defaultIndex: 6
                property alias defaultItem: advancedPage.defaultItem
                property bool hasAltBack: true
                smooth: false
                visible: false

                function altBack() {
                    mainSwipeView.swipeToItem(0)
                }

                AdvancedSettingsPage {
                    id: advancedPage
                    anchors.topMargin: topBar.topFadeIn.height - topBar.barHeight

                }
            }
        }

        Popup {
            id: skipFreStepPopup
            width: 800
            height: 480
            modal: true
            dim: false
            focus: true
            parent: overlay
            closePolicy: Popup.CloseOnPressOutside
            background: Rectangle {
                id: popupBackgroundDimFre
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
                continue_text.color = "#000000"
                continue_rectangle.color = "#ffffff"
            }

            Rectangle {
                id: basePopupItemFre
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
                    id: horizontal_dividerFre
                    width: 720
                    height: 2
                    color: "#ffffff"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 72
                }

                Rectangle {
                    id: vertical_dividerFre
                    x: 359
                    y: 328
                    width: 2
                    height: 72
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Item {
                    id: buttonBarFre
                    width: 720
                    height: 72
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0

                    Rectangle {
                        id: skip_rectangle
                        x: 0
                        y: 0
                        width: 360
                        height: 72
                        color: "#00000000"
                        radius: 10

                        Text {
                            id: skip_text
                            color: "#ffffff"
                            text: {
                                switch(currentFreStep) {
                                case FreStep.Welcome:
                                    ""
                                    break;
                                case FreStep.SetupWifi:
                                    "SKIP WIFI"
                                    break;
                                case FreStep.SoftwareUpdate:
                                    "SKIP SOFTWARE UPDATE"
                                    break;
                                case FreStep.NamePrinter:
                                    "SKIP NAMING PRINTER"
                                    break;
                                case FreStep.LoginMbAccount:
                                    "SKIP SIGN IN"
                                    break;
                                case FreStep.AttachExtruders:
                                case FreStep.LoadMaterial:
                                    "SKIP PRINTER SETUP"
                                    break;
                                case FreStep.TestPrint:
                                    "SKIP TEST PRINT"
                                    break;
                                case FreStep.SetupComplete:
                                    ""
                                    break;
                                case FreStep.FreComplete:
                                    ""
                                    break;
                                default:
                                    ""
                                    break;
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
                            id: skip_mouseArea
                            anchors.fill: parent
                            onPressed: {
                                skip_text.color = "#000000"
                                skip_rectangle.color = "#ffffff"
                                continue_text.color = "#ffffff"
                                continue_rectangle.color = "#00000000"
                            }
                            onReleased: {
                                skip_text.color = "#ffffff"
                                skip_rectangle.color = "#00000000"
                            }
                            onClicked: {
                                skipFreStepPopup.close()
                                currentItem.skipFreStepAction()
                                if(currentFreStep == FreStep.AttachExtruders ||
                                   currentFreStep == FreStep.LoadMaterial ||
                                   currentFreStep == FreStep.TestPrint) {
                                    fre.setFreStep(FreStep.FreComplete)
                                } else {
                                    fre.gotoNextStep(currentFreStep)
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: continue_rectangle
                        x: 360
                        y: 0
                        width: 360
                        height: 72
                        color: "#00000000"
                        radius: 10

                        Text {
                            id: continue_text
                            color: "#ffffff"
                            text: "CONTINUE"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.letterSpacing: 3
                            font.weight: Font.Bold
                            font.family: "Antennae"
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        MouseArea {
                            id: continue_mouseArea
                            anchors.fill: parent
                            onPressed: {
                                continue_text.color = "#000000"
                                continue_rectangle.color = "#ffffff"
                            }
                            onReleased: {
                                continue_text.color = "#ffffff"
                                continue_rectangle.color = "#00000000"
                            }
                            onClicked: {
                                skipFreStepPopup.close()
                            }
                        }
                    }
                }

                ColumnLayout {
                    id: columnLayoutFre
                    width: 590
                    height: 100
                    anchors.top: parent.top
                    anchors.topMargin: 25
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        id: main_text
                        color: "#cbcbcb"
                        text: {
                            switch(currentFreStep) {
                            case FreStep.Welcome:
                                ""
                                break;
                            case FreStep.SetupWifi:
                                "SKIP WI-FI SETUP?"
                                break;
                            case FreStep.SoftwareUpdate:
                                "SKIP SOFTWARE UPDATE?"
                                break;
                            case FreStep.NamePrinter:
                                "SKIP NAMING PRINTER?"
                                break;
                            case FreStep.LoginMbAccount:
                                "SKIP ACCOUNT SIGN IN?"
                                break;
                            case FreStep.AttachExtruders: {
                                if(!bot.extruderAPresent ||
                                   !bot.extruderBPresent) {
                                    "SKIP ATTACHING EXTRUDERS?"
                                }
                                else {
                                    "SKIP CALIBRATING EXTRUDERS?"
                                }
                            }
                                break;
                            case FreStep.LoadMaterial:
                                "SKIP LOADING MATERIAL?"
                                break;
                            case FreStep.TestPrint:
                                "SKIP TEST PRINT?"
                                break;
                            case FreStep.SetupComplete:
                                ""
                                break;
                            case FreStep.FreComplete:
                                ""
                                break;
                            default:
                                break;
                            }
                        }
                        font.letterSpacing: 3
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.family: "Antennae"
                        font.weight: Font.Bold
                        font.pixelSize: 20
                    }

                    Text {
                        id: sub_text
                        color: "#cbcbcb"
                        text: {
                            switch(currentFreStep) {
                            case FreStep.Welcome:
                                ""
                                break;
                            case FreStep.SetupWifi:
                                "Connecting to Wi-Fi enables remote printing and monitoring from any internet connected device. An Ethernet cable can also be used."
                                break;
                            case FreStep.SoftwareUpdate:
                                "It is recommended to keep your printer updated for the latest features and quality."
                                break;
                            case FreStep.NamePrinter:
                                "You can name your printer later from the printer settings menu."
                                break;
                            case FreStep.LoginMbAccount:
                                "By signing in, this printer will automatically appear in your list of printers on any signed in device."
                                break;
                            case FreStep.AttachExtruders: {
                                    if(!bot.extruderAPresent ||
                                       !bot.extruderBPresent) {
                                        "Extruders are required to use the printer."
                                    }
                                    else {
                                        "For best print quality and dimensional accuracy, the extruders should be calibrated each time they are attached."
                                    }
                                }
                                break;
                            case FreStep.LoadMaterial:
                                "Printing requires material to be loaded into the extruders."
                                break;
                            case FreStep.TestPrint:
                                "A test print is a small print that ensures the printer is working properly."
                                break;
                            case FreStep.SetupComplete:
                                ""
                                break;
                            case FreStep.FreComplete:
                                ""
                                break;
                            default:
                                break;
                            }
                        }
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        font.family: "Antennae"
                        font.pixelSize: 18
                        lineHeight: 1.3
                    }
                }
            }
        }
        
        Popup {
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
                        text: isAuthenticated ? "AUTHENTICATION COMPLETE" : skipAuthentication ? "CANCEL AUTHENTICATION" : "AUTHENTICATION REQUEST"
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.letterSpacing: 5
                        font.family: "Antennae"
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
                        text: isAuthenticated ? bot.username : skipAuthentication ? "Are you sure you want to cancel?" : "Would you like to authenticate"
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 17
                        anchors.top: authImage.bottom
                        horizontalAlignment: Text.AlignLeft
                        font.weight: isAuthenticated ? Font.Bold : Font.Light
                        font.family: "Antennae"
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
                            font.family: "Antennae"
                            font.pixelSize: 18
                            font.letterSpacing: 3
                            visible: !isAuthenticated
                        }

                        Text {
                            id: authenticate_description_text3
                            color: "#cbcbcb"
                            text: isAuthenticated ? "is now authenticated to this printer" : "to this printer?"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            font.weight: Font.Light
                            font.family: "Antennae"
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
                            text: skipAuthentication ? "BACK" : "DISMISS"
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
                            text: skipAuthentication ? "CONTINUE" : "AUTHENTICATE"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.letterSpacing: 3
                            font.weight: Font.Bold
                            font.family: "Antennae"
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        MouseArea {
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

        Popup {
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
                        text: "UNKNOWN FIRMWARE"
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.letterSpacing: 5
                        font.family: "Antennae"
                        font.weight: Font.Bold
                        font.pixelSize: 22
                    }
                    // Main question that appears in the popup
                    Text {
                        id: install_unsigned_fw_description_text1
                        color: "#cbcbcb"
                        text: "You are installing an unknown firmware, this can damage your printer and void your warranty. Are you sure you want to proceed?"
                        // To specify a WordWrap property, the width must be defined
                        width: parent.width
                        wrapMode: Text.WordWrap
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 17
                        anchors.top: install_unsigned_fw_header_text.bottom
                        horizontalAlignment: Text.AlignHCenter
                        font.weight: Font.Light
                        font.family: "Antennae"
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
                            text: "INSTALL"
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

        Popup {
            id: firmwareUpdatePopup
            width: 800
            height: 480
            modal: true
            dim: false
            focus: true
            closePolicy: Popup.CloseOnPressOutside
            parent: overlay
            background: Rectangle {
                id: popupBackgroundDim1
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
                update_rectangle.color = "#ffffff"
                update_text.color = "#000000"
            }
            onClosed: {
                viewReleaseNotes = false
                skipFirmwareUpdate = false
            }

            Rectangle {
                id: basePopupItem1
                color: "#000000"
                rotation: rootItem.rotation == 180 ? 180 : 0
                width: 720
                height: skipFirmwareUpdate ? 220 : 275
                radius: 10
                border.width: 2
                border.color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    id: horizontal_divider1
                    width: 720
                    height: 2
                    color: "#ffffff"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 72
                }

                Rectangle {
                    id: vertical_divider1
                    x: 359
                    y: 328
                    width: 2
                    height: 72
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Item {
                    id: buttonBar
                    width: 720
                    height: 72
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0

                    Rectangle {
                        id: dismiss_rectangle1
                        x: 0
                        y: 0
                        width: 360
                        height: 72
                        color: "#00000000"
                        radius: 10

                        Text {
                            id: dismiss_text1
                            color: "#ffffff"
                            text: skipFirmwareUpdate ? "SKIP" : "NOT NOW"
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
                            id: notnow_mouseArea
                            anchors.fill: parent
                            onPressed: {
                                dismiss_text1.color = "#000000"
                                dismiss_rectangle1.color = "#ffffff"
                                update_text.color = "#ffffff"
                                update_rectangle.color = "#00000000"
                            }
                            onReleased: {
                                dismiss_text1.color = "#ffffff"
                                dismiss_rectangle1.color = "#00000000"
                            }
                            onClicked: {
                                if(skipFirmwareUpdate) {
                                    firmwareUpdatePopup.close()
                                }
                                else {
                                    skipFirmwareUpdate = true
                                    viewReleaseNotes = false
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: update_rectangle
                        x: 360
                        y: 0
                        width: 360
                        height: 72
                        color: "#00000000"
                        radius: 10

                        Text {
                            id: update_text
                            color: "#ffffff"
                            text: "UPDATE"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.letterSpacing: 3
                            font.weight: Font.Bold
                            font.family: "Antennae"
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        MouseArea {
                            id: update_mouseArea
                            anchors.fill: parent
                            onPressed: {
                                update_text.color = "#000000"
                                update_rectangle.color = "#ffffff"
                            }
                            onReleased: {
                                update_text.color = "#ffffff"
                                update_rectangle.color = "#00000000"
                            }
                            onClicked: {
                                if(mainSwipeView.currentIndex != 3 ||
                                   settingsPage.settingsSwipeView.currentIndex != 3) {
                                    mainSwipeView.swipeToItem(3)
                                    settingsPage.settingsSwipeView.swipeToItem(3)
                                }
                                firmwareUpdatePopup.close()
                            }
                        }
                    }
                }

                ColumnLayout {
                    id: columnLayout1
                    x: 130
                    width: 550
                    height: 150
                    anchors.top: parent.top
                    anchors.topMargin: 26
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        id: firmware_header_text
                        color: "#cbcbcb"
                        text: viewReleaseNotes ? "SOFTWARE " + bot.firmwareUpdateVersion + " RELEASE NOTES" : skipFirmwareUpdate ? "SKIP SOFTWARE UPDATE?" : "SOFTWARE UPDATE AVAILABLE"
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.letterSpacing: 5
                        font.family: "Antennae"
                        font.weight: Font.Bold
                        font.pixelSize: 18
                    }

                    Item {
                        id: emptyItem
                        width: 200
                        height: 10
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        visible: viewReleaseNotes ? false : skipFirmwareUpdate ? false : true
                    }

                    Text {
                        id: firmware_description_text1
                        width: 500
                        color: "#cbcbcb"
                        text: viewReleaseNotes ? bot.firmwareUpdateReleaseNotes : skipFirmwareUpdate ? "We recommend using the most up to date software for your printer." : "A new version of software is available. Do you want to update to the most recent version " + bot.firmwareUpdateVersion + " ?"
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        font.family: "Antennae"
                        font.pixelSize: 18
                        lineHeight: 1.35
                    }

                    Text {
                        id: firmware_description_text2
                        color: "#cbcbcb"
                        text: skipFirmwareUpdate ? "" : "Tap to see Release Notes"
                        font.underline: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        font.family: "Antennae"
                        font.pixelSize: 18
                        visible: viewReleaseNotes ? false : true

                        MouseArea {
                            anchors.fill: parent
                            visible: skipFirmwareUpdate ? false : true
                            onClicked: {
                                viewReleaseNotes = true
                            }
                        }
                    }
                }
            }
        }

        Popup {
            id: buildPlateClearPopup
            width: 800
            height: 480
            modal: true
            dim: false
            focus: true
            parent: overlay
            closePolicy: Popup.CloseOnPressOutside
            background: Rectangle {
                id: popupBackgroundDim2
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
                start_print_text.color = "#000000"
                start_print_rectangle.color = "#ffffff"
            }

            Rectangle {
                id: basePopupItem2
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
                    id: horizontal_divider2
                    width: 720
                    height: 2
                    color: "#ffffff"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 72
                }

                Rectangle {
                    id: vertical_divider2
                    x: 359
                    y: 328
                    width: 2
                    height: 72
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Item {
                    id: buttonBar1
                    width: 720
                    height: 72
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0

                    Rectangle {
                        id: start_print_rectangle
                        x: 0
                        y: 0
                        width: 360
                        height: 72
                        color: "#00000000"
                        radius: 10

                        Text {
                            id: start_print_text
                            color: "#ffffff"
                            text: "START PRINT"
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
                            id: start_print_mouseArea
                            anchors.fill: parent
                            onPressed: {
                                start_print_text.color = "#000000"
                                start_print_rectangle.color = "#ffffff"
                            }
                            onReleased: {
                                start_print_text.color = "#ffffff"
                                start_print_rectangle.color = "#00000000"
                            }
                            onClicked: {
                                bot.buildPlateCleared()
                                buildPlateClearPopup.close()
                                if(mainSwipeView.currentIndex != 1) {
                                    mainSwipeView.swipeToItem(1)
                                }
                                if(printPage.printSwipeView.currentIndex != 0) {
                                    printPage.printSwipeView.swipeToItem(0)
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: cancel_print_rectangle
                        x: 360
                        y: 0
                        width: 360
                        height: 72
                        color: "#00000000"
                        radius: 10

                        Text {
                            id: cancel_print_text
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
                            id: cancel_print_mouseArea
                            anchors.fill: parent
                            onPressed: {
                                cancel_print_text.color = "#000000"
                                cancel_print_rectangle.color = "#ffffff"
                            }
                            onReleased: {
                                cancel_print_text.color = "#ffffff"
                                cancel_print_rectangle.color = "#00000000"
                            }
                            onClicked: {
                                bot.cancel()
                                buildPlateClearPopup.close()
                            }
                        }
                    }
                }

                ColumnLayout {
                    id: columnLayout2
                    width: 590
                    height: 100
                    anchors.top: parent.top
                    anchors.topMargin: 25
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        id: clear_build_plate_text
                        color: "#cbcbcb"
                        text: "CLEAR BUILD PLATE"
                        font.letterSpacing: 3
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.family: "Antennae"
                        font.weight: Font.Bold
                        font.pixelSize: 20
                    }

                    Text {
                        id: clear_build_plate_desc_text
                        color: "#cbcbcb"
                        text: "Please be sure your build plate is clear."
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        font.family: "Antennae"
                        font.pixelSize: 18
                        lineHeight: 1.3
                    }
                }
            }
        }

        Popup {
            id: updatingExtruderFirmwarePopup
            width: 800
            height: 480
            modal: true
            dim: false
            focus: true
            closePolicy: Popup.NoAutoClose
            parent: overlay
            background: Rectangle {
                id: updatingExtruderFirmwareBackRect
                color: "#000000"
                rotation: rootItem.rotation == 180 ? 180 : 0
                opacity: 0.7
                anchors.fill: parent
            }
            enter: Transition {
                NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.InQuad; from: 0.0; to: 1.0 }
            }
            exit: Transition {
                NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.InQuad; from: 1.0; to: 0.0 }
            }
            onClosed: {
                updatedExtruderFirmwareA = false
                updatedExtruderFirmwareB = false
            }
            Rectangle {
                id: updatingExtruderFirmwarePopupRect
                color: "#000000"
                rotation: rootItem.rotation == 180 ? 180 : 0
                width: 720
                height: 275
                radius: 10
                border.width: 2
                border.color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter                
                anchors.horizontalCenter: parent.horizontalCenter
                ColumnLayout {
                    id: columnLayout3
                    width: 590
                    height: 165
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    BusyIndicator {
                        id: extruderBusyIndicator
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        running: updatingExtruderFirmwarePopup.opened

                        contentItem: Item {
                                implicitWidth: 64
                                implicitHeight: 64

                                Item {
                                    id: itemExtruderBusy
                                    x: parent.width / 2 - 32
                                    y: parent.height / 2 - 32
                                    width: 64
                                    height: 64
                                    opacity: extruderBusyIndicator.running ? 1 : 0

                                    Behavior on opacity {
                                        OpacityAnimator {
                                            duration: 250
                                        }
                                    }

                                    RotationAnimator {
                                        target: itemExtruderBusy
                                        running: extruderBusyIndicator.visible && extruderBusyIndicator.running
                                        from: 0
                                        to: 360
                                        loops: Animation.Infinite
                                        duration: 1500
                                    }

                                    Repeater {
                                        id: repeater1
                                        model: 6

                                        Rectangle {
                                            x: itemExtruderBusy.width / 2 - width / 2
                                            y: itemExtruderBusy.height / 2 - height / 2
                                            implicitWidth: 2
                                            implicitHeight: 16
                                            radius: 0
                                            color: "#ffffff"
                                            transform: [
                                                Translate {
                                                    y: -Math.min(itemExtruderBusy.width, itemExtruderBusy.height) * 0.5 + 5
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

                    Text {
                        id: alert_text
                        color: "#cbcbcb"
                        text: "EXTRUDERS ARE BEING PROGRAMMED..."
                        font.letterSpacing: 3
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.family: "Antennae"
                        font.weight: Font.Bold
                        font.pixelSize: 20
                    }
                }
            }
        }

        Popup {
            id: cancelPrintPopup
            width: 800
            height: 480
            modal: true
            dim: false
            focus: true
            parent: overlay
            closePolicy: Popup.CloseOnPressOutside
            background: Rectangle {
                id: popupBackgroundDim_cancel_print_popup
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
                id: basePopupItem_cancel_print_popup
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
                    id: horizontal_divider_cancel_print_popup
                    width: 720
                    height: 2
                    color: "#ffffff"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 72
                }

                Rectangle {
                    id: vertical_divider_cancel_print_popup
                    x: 359
                    y: 328
                    width: 2
                    height: 72
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Item {
                    id: buttonBar_cancel_print_popup
                    width: 720
                    height: 72
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0

                    Rectangle {
                        id: cancel_rectangle_cancel_print_popup
                        x: 0
                        y: 0
                        width: 360
                        height: 72
                        color: "#00000000"
                        radius: 10

                        Text {
                            id: cancel_text_cancel_print_popup
                            color: "#ffffff"
                            text: "CANCEL PRINT"
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
                            id: cancel_mouseArea_cancel_print_popup
                            anchors.fill: parent
                            onPressed: {
                                cancel_text_cancel_print_popup.color = "#000000"
                                cancel_rectangle_cancel_print_popup.color = "#ffffff"
                            }
                            onReleased: {
                                cancel_text_cancel_print_popup.color = "#ffffff"
                                cancel_rectangle_cancel_print_popup.color = "#00000000"
                            }
                            onClicked: {
                                bot.cancel()
                                cancelPrintPopup.close()
                            }
                        }
                    }

                    Rectangle {
                        id: continue_rectangle_cancel_print_popup
                        x: 360
                        y: 0
                        width: 360
                        height: 72
                        color: "#00000000"
                        radius: 10

                        Text {
                            id: continue_text_cancel_print_popup
                            color: "#ffffff"
                            text: "CONTINUE PRINT"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.letterSpacing: 3
                            font.weight: Font.Bold
                            font.family: "Antennae"
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        MouseArea {
                            id: continue_mouseArea_cancel_print_popup
                            anchors.fill: parent
                            onPressed: {
                                continue_text_cancel_print_popup.color = "#000000"
                                continue_rectangle_cancel_print_popup.color = "#ffffff"
                            }
                            onReleased: {
                                continue_text_cancel_print_popup.color = "#ffffff"
                                continue_rectangle_cancel_print_popup.color = "#00000000"
                            }
                            onClicked: {
                                cancelPrintPopup.close()
                            }
                        }
                    }
                }

                ColumnLayout {
                    id: columnLayout_cancel_print_popup
                    width: 590
                    height: 100
                    anchors.top: parent.top
                    anchors.topMargin: 25
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        id: cancel_title_text_cancel_print_popup
                        color: "#cbcbcb"
                        text: "CANCEL PRINT"
                        font.letterSpacing: 3
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.family: "Antennae"
                        font.weight: Font.Bold
                        font.pixelSize: 20
                    }

                    Text {
                        id: cancel_description_text_cancel_print_popup
                        color: "#cbcbcb"
                        text: "Are you sure?"
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        font.family: "Antennae"
                        font.pixelSize: 18
                        lineHeight: 1.3
                    }
                }
            }
        }

        Popup {
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
                            text: "OK"
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
                        text: "YOU CAN NOW SAFELY REMOVE THE USB"
                        font.letterSpacing: 3
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.family: "Antennae"
                        font.weight: Font.Bold
                        font.pixelSize: 20
                    }
                }
            }
        }

        Popup {
            id: startPrintErrorsPopup
            width: 800
            height: 480
            modal: true
            dim: false
            focus: true
            parent: overlay
            closePolicy: Popup.CloseOnPressOutside
            background: Rectangle {
                id: popupBackgroundDim_start_print_errors_popup
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
                if(!printPage.startPrintBuildDoorOpen && !printPage.startPrintTopLidOpen) {
                    right_text_start_print_errors_popup.color = "#000000"
                    right_rectangle_start_print_errors_popup.color = "#ffffff"
                }
            }

            onClosed: {
                printPage.startPrintBuildDoorOpen = false
                printPage.startPrintTopLidOpen = false
                printPage.startPrintWithUnknownMaterials = false
            }

            Rectangle {
                id: basePopupItem_start_print_errors_popup
                color: "#000000"
                rotation: rootItem.rotation == 180 ? 180 : 0
                width: 720
                height: {
                    (printPage.startPrintTopLidOpen ||
                     printPage.startPrintBuildDoorOpen) ? 220 : 300
                }
                radius: 10
                border.width: 2
                border.color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                Image {
                    id: close_popup_start_print_errors_popup
                    height: sourceSize.height
                    width: sourceSize.width
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    source: "qrc:/img/skip.png"
                    visible: printPage.startPrintWithUnknownMaterials &&
                             !printPage.startPrintBuildDoorOpen &&
                             !printPage.startPrintTopLidOpen

                    MouseArea {
                        id: closePopup_start_print_errors_popup
                        anchors.fill: parent
                        onClicked: startPrintErrorsPopup.close()
                    }
                }

                Rectangle {
                    id: horizontal_divider_start_print_errors_popup
                    width: 720
                    height: 2
                    color: "#ffffff"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 72
                }

                Rectangle {
                    id: vertical_divider_start_print_errors_popup
                    x: 359
                    y: 328
                    width: 2
                    height: 72
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: {
                        (!printPage.startPrintBuildDoorOpen &&
                         !printPage.startPrintTopLidOpen)
                    }
                }

                Item {
                    id: buttonBar_start_print_errors_popup
                    width: 720
                    height: 72
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0

                    Rectangle {
                        id: full_rectangle_start_print_errors_popup
                        x: 0
                        y: 0
                        width: 720
                        height: 72
                        color: "#00000000"
                        radius: 10
                        visible: {
                            (printPage.startPrintBuildDoorOpen ||
                             printPage.startPrintTopLidOpen)
                        }

                        Text {
                            id: full_text_start_print_errors_popup
                            color: "#ffffff"
                            text: {
                                "OK"
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
                            id: full_mouseArea_start_print_errors_popup
                            anchors.fill: parent
                            onPressed: {
                                full_text_start_print_errors_popup.color = "#000000"
                                full_rectangle_start_print_errors_popup.color = "#ffffff"
                            }
                            onReleased: {
                                full_text_start_print_errors_popup.color = "#ffffff"
                                full_rectangle_start_print_errors_popup.color = "#00000000"
                            }
                            onClicked: {
                                startPrintErrorsPopup.close()
                            }
                        }
                    }

                    Rectangle {
                        id: left_rectangle_start_print_errors_popup
                        x: 0
                        y: 0
                        width: 360
                        height: 72
                        color: "#00000000"
                        radius: 10
                        visible: {
                            (!printPage.startPrintBuildDoorOpen &&
                             !printPage.startPrintTopLidOpen)
                        }

                        Text {
                            id: left_text_start_print_errors_popup
                            color: "#ffffff"
                            text: {
                                if(printPage.startPrintWithUnknownMaterials) {
                                    "START ANYWAY"
                                }
                                else if(materialPage.bay1.filamentMaterialName.toLowerCase() != printPage.print_model_material ||
                                        materialPage.bay2.filamentMaterialName.toLowerCase() != printPage.print_support_material) {
                                    "OK"
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
                            id: left_mouseArea_start_print_errors_popup
                            anchors.fill: parent
                            onPressed: {
                                left_text_start_print_errors_popup.color = "#000000"
                                left_rectangle_start_print_errors_popup.color = "#ffffff"
                                right_text_start_print_errors_popup.color = "#ffffff"
                                right_rectangle_start_print_errors_popup.color = "#00000000"
                            }
                            onReleased: {
                                left_text_start_print_errors_popup.color = "#ffffff"
                                left_rectangle_start_print_errors_popup.color = "#00000000"
                            }
                            onClicked: {
                                startPrintErrorsPopup.close()
                                if(printPage.startPrintWithUnknownMaterials) {
                                    if(printPage.startPrintDoorLidCheck()) {
                                        printPage.startPrint()
                                    }
                                    else {
                                        startPrintErrorsPopup.open()
                                    }
                                }
                                else if(materialPage.bay1.filamentMaterialName.toLowerCase() != printPage.print_model_material ||
                                        materialPage.bay2.filamentMaterialName.toLowerCase() != printPage.print_support_material) {
                                    startPrintErrorsPopup.close()
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: right_rectangle_start_print_errors_popup
                        x: 360
                        y: 0
                        width: 360
                        height: 72
                        color: "#00000000"
                        radius: 10
                        visible: {
                            (!printPage.startPrintBuildDoorOpen &&
                             !printPage.startPrintTopLidOpen)
                        }

                        Text {
                            id: right_text_start_print_errors_popup
                            color: "#ffffff"
                            text: {
                                if(printPage.startPrintWithUnknownMaterials) {
                                    "CHANGE MATERIAL"
                                }
                                else if(materialPage.bay1.filamentMaterialName.toLowerCase() != printPage.print_model_material ||
                                        materialPage.bay2.filamentMaterialName.toLowerCase() != printPage.print_support_material) {
                                    "CHANGE MATERIAL"
                                }
                            }

                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.letterSpacing: 3
                            font.weight: Font.Bold
                            font.family: "Antennae"
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        MouseArea {
                            id: right_mouseArea_start_print_errors_popup
                            anchors.fill: parent
                            onPressed: {
                                right_text_start_print_errors_popup.color = "#000000"
                                right_rectangle_start_print_errors_popup.color = "#ffffff"
                            }
                            onReleased: {
                                right_text_start_print_errors_popup.color = "#ffffff"
                                right_rectangle_start_print_errors_popup.color = "#00000000"
                            }
                            onClicked: {
                                startPrintErrorsPopup.close()
                                if(printPage.startPrintWithUnknownMaterials) {
                                    printPage.resetPrintFileDetails()
                                    if(printPage.printSwipeView.currentIndex != 0) {
                                        printPage.printSwipeView.setCurrentIndex(0)
                                    }
                                    mainSwipeView.swipeToItem(5)
                                }
                                else if(materialPage.bay1.filamentMaterialName.toLowerCase() != printPage.print_model_material ||
                                        materialPage.bay2.filamentMaterialName.toLowerCase() != printPage.print_support_material) {
                                    printPage.resetPrintFileDetails()
                                    if(printPage.printSwipeView.currentIndex != 0) {
                                        printPage.printSwipeView.setCurrentIndex(0)
                                    }
                                    mainSwipeView.swipeToItem(5)
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    id: columnLayout_start_print_errors_popup
                    width: 590
                    height: {
                        (printPage.startPrintBuildDoorOpen ||
                         printPage.startPrintTopLidOpen) ? 100 : 170
                    }
                    anchors.top: parent.top
                    anchors.topMargin: 30
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        id: main_text_start_print_errors_popup
                        color: "#cbcbcb"
                        text: {
                            if(printPage.startPrintTopLidOpen) {
                                "CLOSE THE TOP LID"
                            }
                            else if(printPage.startPrintBuildDoorOpen) {
                                "CLOSE BUILD CHAMBER DOOR"
                            }
                            else if(printPage.startPrintWithUnknownMaterials) {
                                "UNKNOWN MATERIAL DETECTED"
                            }
                            else if(materialPage.bay1.filamentMaterialName.toLowerCase() != printPage.print_model_material ||
                                    materialPage.bay2.filamentMaterialName.toLowerCase() != printPage.print_support_material) {
                                "MATERIAL MISMATCH WARNING"
                            }
                        }
                        font.letterSpacing: 3
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.family: "Antennae"
                        font.weight: Font.Bold
                        font.pixelSize: 20
                    }

                    Text {
                        id: sub_text_start_print_errors_popup
                        color: "#cbcbcb"
                        text: {
                            if(printPage.startPrintTopLidOpen) {
                                "Put the top lid back on the printer to start the print."
                            }
                            else if(printPage.startPrintBuildDoorOpen) {
                                "Close the build chamber door to start the print."
                            }
                            else if(printPage.startPrintWithUnknownMaterials) {
                                "Be sure <b>" +
                                 printPage.print_model_material.toUpperCase() +
                                 "</b> is in <b>Model Extruder 1</b>" +
                                 ((printPage.print_support_material != "") ?
                                            " and <b>" + printPage.print_support_material.toUpperCase() + "</b> is in <b>Support Extruder 2</b>." :
                                            ".") +
                                  "\nThis printer is optimized for genuine MakerBot materials."
                            }
                            else if(printPage.print_support_material == "" &&
                                    materialPage.bay1.filamentMaterialName.toLowerCase() != printPage.print_model_material) {
                                "This print requires <b>" +
                                printPage.print_model_material.toUpperCase() +
                                "</b> in <b>Model Extruder 1</b>." +
                                "\nLoad the correct material to start the print or export the file again with these material settings."
                            }
                            else if(materialPage.bay1.filamentMaterialName.toLowerCase() != printPage.print_model_material ||
                                    materialPage.bay2.filamentMaterialName.toLowerCase() != printPage.print_support_material) {
                                "This print requires <b>" +
                                printPage.print_model_material.toUpperCase() +
                                "</b> in <b>Model Extruder 1</b> and <b>" +
                                printPage.print_support_material.toUpperCase() +
                                "</b> in <b>Support Extruder 2</b>.\nLoad the correct materials to start the print or export the file again with these material settings."
                            }
                        }
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        font.family: "Antennae"
                        font.pixelSize: 20
                        lineHeight: 1.35
                    }
                }
            }
        }
    }
}
