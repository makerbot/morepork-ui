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
    minimumWidth: 800
    minimumHeight: 480
    width: 800
    height: 480
    readonly property string defaultString: "default"
    readonly property string emptyString: ""
    property alias mainSwipeView: mainSwipeView
    property alias topBar: topBar
    property var currentItem: mainMenu
    property var activeDrawer
    property bool authRequest: bot.isAuthRequestPending
    property bool installUnsignedFwRequest: bot.isInstallUnsignedFwRequestPending
    property bool updatingExtruderFirmware: bot.updatingExtruderFirmware
    property int extruderFirmwareUpdateProgressA: bot.extruderFirmwareUpdateProgressA
    property int extruderFirmwareUpdateProgressB: bot.extruderFirmwareUpdateProgressB
    property bool extruderAToolTypeCorrect: bot.extruderAToolTypeCorrect
    property bool extruderBToolTypeCorrect: bot.extruderBToolTypeCorrect
    property bool extruderAPresent: bot.extruderAPresent
    property bool extruderBPresent: bot.extruderBPresent
    property bool extrudersPresent: extruderAPresent && extruderBPresent
    property bool extrudersCalibrated: bot.extrudersCalibrated
    property bool skipAuthentication: false
    property bool isAuthenticated: false
    property bool isBuildPlateClear: bot.process.isBuildPlateClear
    property bool updatedExtruderFirmwareA: false
    property bool updatedExtruderFirmwareB: false
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

    onUpdatingExtruderFirmwareChanged: {
        if(updatingExtruderFirmware) {
            updatingExtruderFirmwarePopup.open()
        }
        else {
            updatingExtruderFirmwarePopup.close()
        }
    }

    function calibratePopupDeterminant() {
        if(extrudersCalibrated || !extrudersPresent) {
            extNotCalibratedPopup.close()
        }
        // Do not open popup in FRE and both extruders must
        // be present for this popup to open
        if (!extrudersCalibrated && isFreComplete && extrudersPresent) {
            extNotCalibratedPopup.open()
        }
    }

    onExtrudersCalibratedChanged: {
        calibratePopupDeterminant()
    }

    onExtrudersPresentChanged: {
        calibratePopupDeterminant()
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
        else {
            buildPlateClearPopup.close()
        }
    }

    function setDrawerState(state) {
        topBar.imageDrawerArrow.visible = state
        if(activeDrawer == printPage.printingDrawer ||
           activeDrawer == materialPage.materialPageDrawer ||
           activeDrawer == printPage.sortingDrawer) {
            // Patch to disable swiping of the drawer, which appears
            // to eliminate glitchy back button issues that present
            // themselves on some units.
            // activeDrawer.interactive = state
            if(state) {
                topBar.drawerDownClicked.connect(activeDrawer.open)
            }
            else {
                activeDrawer.close()
                topBar.drawerDownClicked.disconnect(activeDrawer.open)
            }
        }
    }

    function showTime(state) {
        topBar.textDateTime.visible = state
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

    function isFilterConnected() {
        return bot.hepaFilterConnected
    }

    // Update the NPS survey due date to 3 months from now
    function updateNPSSurveyDueDate() {
        var due = new Date()
        due.setMonth(due.getMonth() + 3)
        bot.setNPSSurveyDueDate(due)
    }

    //Reset settings swipe view pages (nested pages)
    function resetSettingsSwipeViewPages() {
        console.info("Resetting Settings Pages to their Base Pages...")
        settingsPage.systemSettingsPage.timePage.timeSwipeView.swipeToItem(TimePage.BasePage, false)
        settingsPage.buildPlateSettingsPage.buildPlateSettingsSwipeView.swipeToItem(BuildPlateSettingsPage.BasePage, false)
        settingsPage.extruderSettingsPage.extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.BasePage, false)
        settingsPage.systemSettingsPage.systemSettingsSwipeView.swipeToItem(SystemSettingsPage.BasePage, false)
        settingsPage.settingsSwipeView.swipeToItem(SettingsPage.BasePage, false)
        // After resetting the pages we generally navigate to the desired
        // page from the base page, so we allow the base page to be set as
        // the current item in case this is our destination page.
        mainSwipeView.swipeToItem(MoreporkUI.BasePage)
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

    // Machine/Kaiten doesn't evaluate extruder combos, they just
    // check if an extruder is valid on the installed slot for that
    // machine. So the 'tool_type_correct' flag cannot be used to
    // show the extruder combo warning.
    //
    // This is required now to cover a specific case described
    // in BW-4975 (https://makerbot.atlassian.net/browse/BW-4975)
    // or atleast until single extruder support is launched to public?
    property bool extruderComboMismatch: {
        (bot.extruderAPresent && bot.extruderBPresent) && (
        (bot.extruderAType == ExtruderType.MK14 && bot.extruderBType == ExtruderType.MK14_HOT) ||
        (bot.extruderAType == ExtruderType.MK14_HOT && bot.extruderBType == ExtruderType.MK14))
    }

    property bool experimentalExtruderInstalled: {
        (materialPage.bay1.usingExperimentalExtruder ||
         materialPage.bay2.usingExperimentalExtruder)
    }
    property bool experimentalExtruderAcknowledged: false

    property bool hepaErrorAcknowledged: false
    property bool hepaConnected: bot.hepaFilterConnected

    onHepaConnectedChanged: {
        hepaErrorAcknowledged = false
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
                settingsPage.systemSettingsPage.systemSettingsSwipeView.currentIndex == SystemSettingsPage.ChangePrinterNamePage ||
                settingsPage.systemSettingsPage.systemSettingsSwipeView.currentIndex == SystemSettingsPage.KoreaDFSSecretPage ||
                (settingsPage.systemSettingsPage.systemSettingsSwipeView.currentIndex == SystemSettingsPage.AuthorizeAccountsPage &&
                 (settingsPage.systemSettingsPage.authorizeAccountPage.signInPage.signInSwipeView.currentIndex == SignInPage.UsernamePage ||
                  settingsPage.systemSettingsPage.authorizeAccountPage.signInPage.signInSwipeView.currentIndex == SignInPage.PasswordPage)) ||
                (settingsPage.systemSettingsPage.systemSettingsSwipeView.currentIndex == SystemSettingsPage.WifiPage &&
                 settingsPage.systemSettingsPage.wifiPage.wifiSwipeView.currentIndex == WiFiPage.EnterPassword)
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
            z: 2
            visible: connectionState != ConnectionState.Connected
        }

        FirmwareUpdateSuccessfulScreen {
            anchors.fill: parent
            z: 2
            visible: fre.isFirstBoot &&
                     connectionState == ConnectionState.Connected
        }

        HeatShieldInstructions {
            anchors.fill: parent
            z: 2
        }

        Flickable {
            id: backSwipeHandler
            z: 1
            height: 420
            width: 20
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            flickableDirection: Flickable.HorizontalFlick
            interactive:  mainSwipeView.currentIndex
            onFlickStarted: {
                if (horizontalVelocity < 0) {
                    returnToBounds()
                    goBack()
                }
            }

            boundsMovement: Flickable.StopAtBounds
            pressDelay: 0

            rebound: Transition {
                NumberAnimation {
                    duration: 0
                }
            }
        }

        TopBarForm {
            id: topBar
            z: 1
            backButton.visible: false
            imageDrawerArrow.visible: false
            visible: mainSwipeView.visible
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            onBackClicked: {
                goBack()
            }
        }

        FrePage {
            id: freScreen
            visible: connectionState == ConnectionState.Connected &&
                     !isFreComplete && !inFreStep
        }

        Item {
            id: contentContainer
            width: 800
            height: 408
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            LoggingSwipeView {
                id: mainSwipeView
                itemWithEnum: rootAppWindow
                logName: "mainSwipeView"

                property alias materialPage: materialPage
                visible: connectionState == ConnectionState.Connected &&
                         !freScreen.visible

                function customEntryCheck(swipeToIndex) {
                    if(swipeToIndex === MoreporkUI.BasePage) {
                        topBar.backButton.visible = false
                        if(!printPage.isPrintProcess) disableDrawer()
                    } else {
                        topBar.backButton.visible = true
                    }
                }

                // MoreporkUI.BasePage
                Item {
                    property string topBarTitle: qsTr("Home")
                    smooth: false
                    MainMenu {
                        id: mainMenu
                        anchors.fill: parent

                        mainMenuIcon_print.mouseArea.onClicked: {
                            mainSwipeView.swipeToItem(MoreporkUI.PrintPage)
                        }

                        mainMenuIcon_material.mouseArea.onClicked: {
                            mainSwipeView.swipeToItem(MoreporkUI.MaterialPage)
                        }

                        mainMenuIcon_settings.mouseArea.onClicked: {
                            mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                        }
                    }
                }

                // MoreporkUI.PrintPage
                Item {
                    property var backSwiper: mainSwipeView
                    property int backSwipeIndex: MoreporkUI.BasePage
                    property string topBarTitle: qsTr("Choose a File")
                    property bool hasAltBack: true
                    smooth: false
                    visible: false

                    function altBack() {
                        if(!inFreStep) {
                            if(printPage.printStatusView.acknowledgePrintFinished.failureFeedbackSelected) {
                                printPage.printStatusView.acknowledgePrintFinished.failureFeedbackSelected = false
                                return
                            }
                            mainSwipeView.swipeToItem(MoreporkUI.BasePage)
                        }
                        else {
                            skipFreStepPopup.open()
                        }
                    }

                    function skipFreStepAction() {
                        printPage.printStatusView.testPrintComplete = false
                        bot.cancel()
                        mainSwipeView.swipeToItem(MoreporkUI.BasePage)
                    }
                    PrintPage {
                        id: printPage
                    }
                }


                // MoreporkUI.ExtruderPage
                Item {
                    property var backSwiper: mainSwipeView
                    property int backSwipeIndex: MoreporkUI.BasePage
                    smooth: false
                    visible: false
                    MaterialPage {
                        id: extruderPage
                        anchors.fill: parent
                    }
                }
                // MoreporkUI.SettingsPage
                Item {
                    property var backSwiper: mainSwipeView
                    property int backSwipeIndex: MoreporkUI.BasePage
                    property string topBarTitle: qsTr("Settings")
                    smooth: false
                    visible: false
                    SettingsPage {
                        id: settingsPage
                    }
                }

                // MoreporkUI.InfoPage
                Item {
                    property var backSwiper: mainSwipeView
                    property int backSwipeIndex: MoreporkUI.BasePage
                    smooth: false
                    visible: false
                    InfoPage {
                        id: infoPage
                    }
                }

                // MoreporkUI.MaterialPage
                Item {
                    property var backSwiper: mainSwipeView
                    property int backSwipeIndex: MoreporkUI.BasePage
                    property string topBarTitle: qsTr("Material")
                    smooth: false
                    visible: false
                    MaterialPage {
                        id: materialPage
                    }
                }
            }
        }

        LoggingPopup {
            popupName: "SkipFreStep"
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
                                    qsTr("SKIP WIFI")
                                    break;
                                case FreStep.SoftwareUpdate:
                                    qsTr("SKIP FIRMWARE UPDATE")
                                    break;
                                case FreStep.NamePrinter:
                                    qsTr("SKIP NAMING PRINTER")
                                    break;
                                case FreStep.SetTimeDate:
                                    qsTr("SKIP SETTING TIME")
                                    break;
                                case FreStep.LoginMbAccount:
                                    qsTr("SKIP SIGN IN")
                                    break;
                                case FreStep.AttachExtruders:
                                case FreStep.LevelBuildPlate:
                                case FreStep.CalibrateExtruders:
                                case FreStep.LoadMaterial:
                                    qsTr("SKIP PRINTER SETUP")
                                    break;
                                case FreStep.TestPrint:
                                    qsTr("SKIP TEST PRINT")
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
                            font.family: defaultFont.name
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        LoggingMouseArea {
                            logText: "buttonBarFre: [" + skip_text.text + "]"
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
                                // Login step has a flow within the FRE screen unlike
                                // other steps, so it doesnt require the skip function
                                // like the other steps. The skip function brings the
                                // user back to the main FRE screen, undoing the UI
                                // navigations, resetting states etc.
                                if(currentFreStep != FreStep.LoginMbAccount) {
                                    currentItem.skipFreStepAction()
                                }
                                if(currentFreStep == FreStep.AttachExtruders ||
                                   currentFreStep == FreStep.LevelBuildPlate ||
                                   currentFreStep == FreStep.CalibrateExtruders ||
                                   currentFreStep == FreStep.LoadMaterial ||
                                   currentFreStep == FreStep.TestPrint) {
                                    fre.setFreStep(FreStep.FreComplete)
                                }
                                else if(currentFreStep == FreStep.SetupWifi) {
                                    if(isNetworkConnectionAvailable &&
                                       isfirmwareUpdateAvailable) {
                                        // Go to software update step only if
                                        // network connection is available
                                        fre.gotoNextStep(currentFreStep)
                                    }
                                    else {
                                        fre.setFreStep(FreStep.NamePrinter)
                                    }
                                }
                                else {
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
                            text: qsTr("CONTINUE")
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.letterSpacing: 3
                            font.weight: Font.Bold
                            font.family: defaultFont.name
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        LoggingMouseArea {
                            logText: "buttonBarFre: [" + continue_text.text + "]"
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
                                qsTr("SKIP WI-FI SETUP?")
                                break;
                            case FreStep.SoftwareUpdate:
                                qsTr("SKIP FIRMWARE UPDATE?")
                                break;
                            case FreStep.NamePrinter:
                                qsTr("SKIP NAMING PRINTER?")
                                break;
                            case FreStep.SetTimeDate:
                                qsTr("SKIP SETTING TIME?")
                                break;
                            case FreStep.AttachExtruders:
                                qsTr("SKIP ATTACHING EXTRUDERS?")
                                break;
                            case FreStep.LevelBuildPlate:
                                qsTr("SKIP LEVELING BUILD PLATE?")
                                break;
                            case FreStep.CalibrateExtruders:
                                qsTr("SKIP CALIBRATING EXTRUDERS?")
                                break;
                            case FreStep.LoadMaterial:
                                qsTr("SKIP LOADING MATERIAL?")
                                break;
                            case FreStep.TestPrint:
                                qsTr("SKIP TEST PRINT?")
                                break;
                            case FreStep.LoginMbAccount:
                                qsTr("SKIP ACCOUNT SIGN IN?")
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
                        font.family: defaultFont.name
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
                                qsTr("Connecting to Wi-Fi enables remote printing and monitoring from any internet connected device. An Ethernet cable can also be used.")
                                break;
                            case FreStep.SoftwareUpdate:
                                qsTr("It is recommended to keep your printer updated for the latest features and quality.")
                                break;
                            case FreStep.NamePrinter:
                                qsTr("You can name your printer later from the printer settings menu.")
                                break;
                            case FreStep.SetTimeDate:
                                qsTr("You can set the time later from the printer settings menu.")
                                break;
                            case FreStep.AttachExtruders:
                                qsTr("Extruders are required to use the printer.")
                                break;
                            case FreStep.LevelBuildPlate:
                                qsTr("For best print quality and dimensional accuracy, the build plate should be leveled.")
                                break;
                            case FreStep.CalibrateExtruders:
                                qsTr("For best print quality and dimensional accuracy, the extruders should be calibrated each time they are attached.")
                                break;
                            case FreStep.LoadMaterial:
                                qsTr("Printing requires material to be loaded into the extruders.")
                                break;
                            case FreStep.TestPrint:
                                qsTr("A test print is a small print that ensures the printer is working properly.")
                                break;
                            case FreStep.LoginMbAccount:
                                qsTr("By signing in, this printer will automatically appear in your list of printers on any signed in device.")
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
                        font.family: defaultFont.name
                        font.pixelSize: 18
                        lineHeight: 1.3
                    }
                }
            }
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
            popupName: "FirmwareUpdateNotification"
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
                            text: skipFirmwareUpdate ? qsTr("SKIP") : qsTr("NOT NOW")
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
                            logText: "firmwareUpdatePopup [_" + dismiss_text1.text + "|]"
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
                            text: qsTr("UPDATE")
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.letterSpacing: 3
                            font.weight: Font.Bold
                            font.family: defaultFont.name
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        LoggingMouseArea {
                            logText: "firmwareUpdatePopup [|" + update_text.text + "_]"
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
                                mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.SystemSettingsPage)
                                settingsPage.systemSettingsPage.systemSettingsSwipeView.swipeToItem(SystemSettingsPage.FirmwareUpdatePage)
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
                        text: viewReleaseNotes ? qsTr("FIRMWARE %1 RELEASE NOTES").arg(bot.firmwareUpdateVersion) : skipFirmwareUpdate ? qsTr("SKIP FIRMWARE UPDATE?") : qsTr("FIRMWARE UPDATE AVAILABLE")
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.letterSpacing: 5
                        font.family: defaultFont.name
                        font.weight: Font.Bold
                        font.pixelSize: 18
                    }

                    Item {
                        id: emptyItem
                        width: 200
                        height: 10
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        visible: skipFirmwareUpdate ? false : true
                    }

                    Text {
                        id: firmware_description_text1
                        width: 500
                        color: "#cbcbcb"
                        text: skipFirmwareUpdate ? qsTr("We recommend using the most up to date firmware for your printer.") : qsTr("A new version of firmware is available. Do you want to update to the most recent version %1?").arg(bot.firmwareUpdateVersion)
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        font.family: defaultFont.name
                        font.pixelSize: 18
                        lineHeight: 1.35
                        visible: !viewReleaseNotes
                    }

                    ListView {
                        width: 600
                        height: 120
                        clip: true
                        spacing: 1
                        orientation: ListView.Vertical
                        boundsBehavior: Flickable.DragOverBounds
                        flickableDirection: Flickable.VerticalFlick
                        model: bot.firmwareReleaseNotesList
                        visible: viewReleaseNotes
                        smooth: false
                        delegate:
                            Text {
                                id: firmware_release_notes_text
                                width: 600
                                color: "#ffffff"
                                text: model.modelData
                                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                Layout.fillWidth: true
                                font.weight: Font.Light
                                wrapMode: Text.WordWrap
                                font.family: defaultFont.name
                                font.pixelSize: 18
                                lineHeight: 1.35
                            }
                        ScrollBar.vertical: ScrollBar {
                            orientation: Qt.Vertical
                            policy: ScrollBar.AsNeeded
                        }
                    }

                    Text {
                        id: firmware_description_text2
                        color: "#cbcbcb"
                        text: skipFirmwareUpdate ? "" : qsTr("Tap to see Release Notes")
                        font.underline: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        font.family: defaultFont.name
                        font.pixelSize: 18
                        visible: viewReleaseNotes ? false : true

                        LoggingMouseArea {
                            logText: "firmwareUpdatePopup [" + firmware_description_text2.text + "]"
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

        LoggingPopup {
            popupName: "ClearBuildPlate"
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
                            text: qsTr("START PRINT")
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
                            logText: "buildPlateClearPopup [_" + start_print_text.text + "|]"
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
                                mainSwipeView.swipeToItem(MoreporkUI.PrintPage)
                                printPage.printSwipeView.swipeToItem(PrintPage.BasePage)
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
                            logText: "buildPlateClearPopup [|" + cancel_print_text.text + "_]"
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
                        text: qsTr("CLEAR BUILD PLATE")
                        font.letterSpacing: 3
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.family: defaultFont.name
                        font.weight: Font.Bold
                        font.pixelSize: 20
                    }

                    Text {
                        id: clear_build_plate_desc_text
                        color: "#cbcbcb"
                        text: qsTr("Please be sure your build plate is clear.")
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        font.family: defaultFont.name
                        font.pixelSize: 18
                        lineHeight: 1.3
                    }
                }
            }
        }

        CustomPopup {
            id: wrongExtruderPopup
            popupName: "ExtruderMismatch"
            popupHeight: wrongExtColumnLayout.height+70
            // tool_type_correct flag is sent in system notification by
            // kaiten which determines the "correctness" by looking through
            // printer settings.json under 'supported_tool_types' key.
            // Since the UI just knows whether the attached tool is correct
            // or not and nothing about the type of mismatch, the messaging
            // to user is determined below based on the printer type. It is
            // the machine/kaiten's responsibility to tell the UI about
            // the mismatch.

            property bool modelExtWrong: extruderAPresent &&
                                         !extruderAToolTypeCorrect
            property bool supportExtWrong: extruderBPresent &&
                                         !extruderBToolTypeCorrect
            visible: modelExtWrong || supportExtWrong || extruderComboMismatch

            ColumnLayout {
                id: wrongExtColumnLayout
                height: children.height
                width: 630
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 20
                //height: 150

                Image {
                    source: "qrc:/img/process_error_small.png"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                TextHeadline {
                    text: qsTr("WRONG EXTRUDER TYPE DETECTED")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                TextBody{
                    text: {
                        if (extruderComboMismatch) {
                            qsTr("A Model 1XA Extruder can only be used with a " +
                                 "Support 2XA Extruder. A Model 1A Extruder can " +
                                 "only be used with a Support 2A Extruder.")
                        }
                        else if (bot.machineType == MachineType.Fire) {
                            // V1 printers support only mk14 extruders.
                            if (wrongExtruderPopup.modelExtWrong) {
                                qsTr("Please insert a Model 1A Performance Extruder "+
                                "into slot 1\nto continue attaching the "+
                                "extruders.")
                            } else if (wrongExtruderPopup.supportExtWrong) {
                                qsTr("Please insert a Support 2A Performance Extruder "+
                                "into slot 2\nto continue attaching the "+
                                "extruders. Currently only model\nand support "+
                                "printing is supported.")
                            } else {
                                emptyString
                            }
                        } else {
                            // Hot bot (V2) supports both mk14 and mk14_hot extruders.
                            if (wrongExtruderPopup.modelExtWrong) {
                                qsTr("Please insert a Model 1A or Model 1XA Performance " +
                                     "Extruder into slot 1 to continue attaching the " +
                                     "extruders.")
                            } else if (wrongExtruderPopup.supportExtWrong) {
                                qsTr("Please insert a Support 2A or Support 2XA Performance " +
                                     "Extruder into slot 2 to continue attaching the extruders. " +
                                     "Currently only model and support printing is supported.")
                            } else {
                                emptyString
                            }
                        }
                    }
                    style: TextBody.Large
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: parent.width
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    wrapMode: Text.WordWrap
                }

                TextBody {
                    text: "\nmakerbot.com/compatibility"
                    style: TextBody.Large
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: parent.width
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    wrapMode: Text.WordWrap
                    font.letterSpacing: 1.1
                }
            }
        }

        // Modal Popup for Toolhead Disconnected/FFC Cable Disconnected
        CustomPopup {
            popupName: "CarriageCommunicationError"
            /* When the toolhead disconnects, the Kaiten's Bot Model's
               extruderXErrorCode the toolhead error disconnect error
               code followed by a space.
            */
            property bool toolheadADisconnect: bot.extruderAToolheadDisconnect
            property bool toolheadBDisconnect: bot.extruderBToolheadDisconnect

            id: toolheadDisconnectedPopup
            visible: toolheadADisconnect || toolheadBDisconnect
            closePolicy: Popup.CloseOnPressOutside

            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                height: 150

                TextHeadline {
                    text: "CARRIAGE COMMUNICATION ERROR"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                TextBody {
                    text: {
                        "The printer’s carriage is reporting communication drop-outs. " +
                        "Try restarting the printer. If this happens again, please " +
                        "contact MakerBot support."
                    }
                    style: TextBody.Large
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.preferredWidth: 620
                    wrapMode: "WordWrap"
                }
            }
        }

        // Modal Popup for Heating system error
        CustomPopup {
            popupName: "HeatingSystemError"
            /* Report to the user that the heating system has detected a fault.
            */
            property bool chamberErrorValid: (bot.chamberErrorCode !== 0 && bot.chamberErrorCode !== 45
                                              && bot.chamberErrorCode !== 48)
            property bool heatingSystemError: (bot.hbpErrorCode !== 0 || chamberErrorValid)
            property int heatingSystemErrorCode: (chamberErrorValid ? bot.chamberErrorCode : bot.hbpErrorCode)

            id: heatingSystemErrorPopup
            visible: heatingSystemError && !bot.hasFilamentBay
            closePolicy: Popup.CloseOnPressOutside

            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                height: 150

                TextHeadline {
                    text: "HEATING SYSTEM ERROR"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                TextBody {
                    text: {
                       qsTr("The printer’s Heating System is reporting an error %1. Details can be found on the "
                                + "Sensor Info page. Try restarting the printer. If this happens again, please "
                                + "contact MakerBot support.").arg(heatingSystemErrorPopup.heatingSystemErrorCode)
                    }
                    style: TextBody.Large
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.preferredWidth: 620
                    wrapMode: "WordWrap"

                }
            }
        }

        LoggingPopup {
            popupName: "ExtrudersNotCalibrated"
            id: extNotCalibratedPopup
            width: 800
            height: 480
            modal: true
            dim: false
            focus: true
            closePolicy: Popup.CloseOnPressOutside
            parent: overlay

            background: Rectangle {
                id: extNotCalibratedPopupBackgroundDim
                color: "#000000"
                rotation: rootItem.rotation == 180 ? 180 : 0
                opacity: 0.5
                anchors.fill: parent
            }
            Rectangle {
                id: basePopupItem3
                color: "#000000"
                rotation: rootItem.rotation == 180 ? 180 : 0
                width: 720
                height: 270
                radius: 10
                border.width: 2
                border.color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    id: horizontal_divider3
                    width: 720
                    height: 2
                    color: "#ffffff"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 72
                }

                Rectangle {
                    id: vertical_divider3
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
                    id: buttonBar2
                    width: 720
                    height: 72
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0

                    Rectangle {
                        id: calib_rectangle
                        x: 0
                        y: 0
                        width: 360
                        height: 72
                        color: "#00000000"
                        radius: 10

                        Text {
                            id: calib_text
                            color: "#ffffff"
                            text: "CALIBRATE NOW"
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
                            logText: "extNotCalibratedPopup [_" + calib_text.text + "|]"
                            id: calib_mouseArea
                            anchors.fill: parent
                            onClicked: {
                                extNotCalibratedPopup.close()
                                resetSettingsSwipeViewPages()
                                mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.ExtruderSettingsPage)
                                settingsPage.extruderSettingsPage.extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.CalibrateExtrudersPage)
                            }
                            onPressed: {
                                calib_text.color = "#000000"
                                calib_rectangle.color = "#ffffff"
                            }
                            onReleased: {
                                calib_text.color = "#ffffff"
                                calib_rectangle.color = "#00000000"
                            }
                        }
                    }

                    Rectangle {
                        id: cancel_calib_rectangle
                        x: 360
                        y: 0
                        width: 360
                        height: 72
                        color: "#00000000"
                        radius: 10

                        Text {
                            id: cancel_calib_text
                            color: "#ffffff"
                            text: "CANCEL"
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.letterSpacing: 3
                            font.weight: Font.Bold
                            font.family: defaultFont.name
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        LoggingMouseArea {
                            logText: "extNotCalibratedPopup [|" + cancel_calib_text.text + "_]"
                            id: cancel_calib_mouseArea
                            anchors.fill: parent
                            onClicked: {
                                extNotCalibratedPopup.close()
                            }
                            onPressed: {
                                cancel_calib_text.color = "#000000"
                                cancel_calib_rectangle.color = "#ffffff"
                            }
                            onReleased: {
                                cancel_calib_text.color = "#ffffff"
                                cancel_calib_rectangle.color = "#00000000"
                            }
                        }
                    }
                }
                ColumnLayout {
                    height: 140
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -20

                    TitleText {
                        font.weight: Font.Bold
                        text: "CALIBRATION REQUIRED"
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    }
                    BodyText {
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        font.family: defaultFont.name
                        font.pixelSize: 18
                        lineHeight: 1.3
                        text: {
                            "Automatic calibration must be run when "+
                            "attaching extruders for best\nprint quality. "+
                            "Be sure the extruders are latched into place "+
                            "before\ncalibrating."
                        }
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    }
                }
            }
        }

        LoggingPopup {
            popupName: "UpdatingExtruderFirmware"
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
                        text: qsTr("EXTRUDERS ARE BEING PROGRAMMED...")
                        font.letterSpacing: 3
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.family: defaultFont.name
                        font.weight: Font.Bold
                        font.pixelSize: 20
                    }
                }
            }
        }

        LoggingPopup {
            popupName: "CancelPrint"
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
                            text: qsTr("CANCEL PRINT")
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
                            logText: "cancelPrintPopup [_" + cancel_text_cancel_print_popup.text + "|]"
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
                                printPage.clearErrors()
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
                            text: qsTr("CONTINUE PRINT")
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.letterSpacing: 3
                            font.weight: Font.Bold
                            font.family: defaultFont.name
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        LoggingMouseArea {
                            logText: "cancelPrintPopup [|" + continue_text_cancel_print_popup.text + "_]"
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
                        text: qsTr("CANCEL PRINT")
                        font.letterSpacing: 3
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.family: defaultFont.name
                        font.weight: Font.Bold
                        font.pixelSize: 20
                    }

                    Text {
                        id: cancel_description_text_cancel_print_popup
                        color: "#cbcbcb"
                        text: qsTr("Are you sure?")
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        font.family: defaultFont.name
                        font.pixelSize: 18
                        lineHeight: 1.3
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

        LoggingPopup {
            popupName: "StartPrintError"
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
                printPage.startPrintWithInsufficientModelMaterial = false
                printPage.startPrintWithInsufficientSupportMaterial = false
                printPage.startPrintNoFilament = false
                printPage.startPrintUnknownSliceGenuineMaterial = false
                printPage.startPrintGenuineSliceUnknownMaterial = false
                printPage.startPrintMaterialMismatch = false
            }

            Rectangle {
                id: basePopupItem_start_print_errors_popup
                color: "#000000"
                rotation: rootItem.rotation == 180 ? 180 : 0
                width: 720
                height: {
                    (printPage.startPrintTopLidOpen ||
                     printPage.startPrintBuildDoorOpen) ?
                                220 : 300
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
                    visible: (printPage.startPrintWithUnknownMaterials ||
                              printPage.startPrintWithInsufficientModelMaterial ||
                              printPage.startPrintWithInsufficientSupportMaterial ||
                              printPage.startPrintUnknownSliceGenuineMaterial) &&
                             !printPage.startPrintBuildDoorOpen &&
                             !printPage.startPrintTopLidOpen

                    LoggingMouseArea {
                        logText: "startPrintErrorsPopup [X]"
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
                            logText: "startPrintErrorsPopup [_" + full_text_start_print_errors_popup.text + "_]"
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
                                if(printPage.startPrintNoFilament) {
                                    qsTr("CANCEL")
                                }
                                else if(printPage.startPrintMaterialMismatch ||
                                        printPage.startPrintGenuineSliceUnknownMaterial) {
                                    qsTr("OK")
                                }
                                else if(printPage.startPrintUnknownSliceGenuineMaterial ||
                                        printPage.startPrintWithUnknownMaterials) {
                                    qsTr("START ANYWAY")
                                }
                                else if(printPage.startPrintWithInsufficientModelMaterial ||
                                        printPage.startPrintWithInsufficientSupportMaterial) {
                                    qsTr("START PRINT")
                                } else {
                                    ""
                                }
                            }
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
                            logText: "startPrintErrorsPopup [_" + left_text_start_print_errors_popup.text + "|]"
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
                                if(printPage.startPrintNoFilament) {
                                    // Do Nothing
                                }
                                else if(printPage.startPrintMaterialMismatch ||
                                        printPage.startPrintGenuineSliceUnknownMaterial) {
                                    startPrintErrorsPopup.close()
                                }
                                else if(printPage.startPrintUnknownSliceGenuineMaterial ||
                                        printPage.startPrintWithUnknownMaterials ||
                                        printPage.startPrintWithInsufficientModelMaterial ||
                                        printPage.startPrintWithInsufficientSupportMaterial) {
                                    if(printPage.startPrintDoorLidCheck()) {
                                        printPage.startPrint()
                                    }
                                    else {
                                        startPrintErrorsPopup.open()
                                    }
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
                                if(printPage.startPrintNoFilament) {
                                    qsTr("LOAD MATERIAL")
                                }
                                else if(printPage.startPrintMaterialMismatch ||
                                        printPage.startPrintGenuineSliceUnknownMaterial) {
                                    qsTr("CHANGE MATERIAL")
                                }
                                else if(printPage.startPrintUnknownSliceGenuineMaterial ||
                                        printPage.startPrintWithUnknownMaterials ||
                                        printPage.startPrintWithInsufficientModelMaterial ||
                                        printPage.startPrintWithInsufficientSupportMaterial) {
                                    qsTr("CHANGE MATERIAL")
                                }
                                else {
                                    ""
                                }
                            }

                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            font.letterSpacing: 3
                            font.weight: Font.Bold
                            font.family: defaultFont.name
                            font.pixelSize: 18
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        LoggingMouseArea {
                            logText: "startPrintErrorsPopup [|" + right_text_start_print_errors_popup.text + "_]"
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

                            function resetDetailsAndGoToMaterialsPage() {
                                printPage.resetPrintFileDetails()
                                printPage.printSwipeView.swipeToItem(PrintPage.BasePage)
                                mainSwipeView.swipeToItem(MoreporkUI.MaterialPage)
                            }

                            onClicked: {
                                startPrintErrorsPopup.close()
                                if(printPage.startPrintNoFilament) {
                                    resetDetailsAndGoToMaterialsPage()
                                }
                                else if(printPage.startPrintMaterialMismatch ||
                                        printPage.startPrintGenuineSliceUnknownMaterial) {
                                    resetDetailsAndGoToMaterialsPage()
                                }
                                else if(printPage.startPrintUnknownSliceGenuineMaterial ||
                                        printPage.startPrintWithUnknownMaterials ||
                                        printPage.startPrintWithInsufficientModelMaterial ||
                                        printPage.startPrintWithInsufficientSupportMaterial) {
                                    resetDetailsAndGoToMaterialsPage()
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
                         printPage.startPrintTopLidOpen) ? 100 : 180
                    }
                    anchors.top: parent.top
                    anchors.topMargin: 30
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        id: main_text_start_print_errors_popup
                        color: "#cbcbcb"
                        text: {
                            if(printPage.startPrintTopLidOpen) {
                                qsTr("CLOSE THE TOP LID")
                            }
                            else if(printPage.startPrintBuildDoorOpen) {
                                qsTr("CLOSE BUILD CHAMBER DOOR")
                            }
                            else if(printPage.startPrintNoFilament) {
                                qsTr("NO MATERIAL DETECTED")
                            }
                            else if(printPage.startPrintMaterialMismatch) {
                                qsTr("MATERIAL MISMATCH WARNING")
                            }
                            else if(printPage.startPrintGenuineSliceUnknownMaterial) {
                                qsTr("UNKNOWN MATERIAL WARNING")
                            }
                            else if(printPage.startPrintUnknownSliceGenuineMaterial) {
                                qsTr("MAKERBOT GENUINE MATERIALS")
                            }
                            else if(printPage.startPrintWithUnknownMaterials) {
                                qsTr("UNKNOWN MATERIAL DETECTED")
                            }
                            else if(printPage.startPrintWithInsufficientModelMaterial ||
                                    printPage.startPrintWithInsufficientSupportMaterial) {
                                qsTr("LOW MATERIAL")
                            }
                            else {
                                emptyString
                            }
                        }
                        font.letterSpacing: 3
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.family: defaultFont.name
                        font.weight: Font.Bold
                        font.pixelSize: 20
                    }

                    Text {
                        id: sub_text_start_print_errors_popup
                        color: "#cbcbcb"
                        text: {
                            if(printPage.startPrintTopLidOpen) {
                                qsTr("Put the top lid back on the printer to start the print.")
                            }
                            else if(printPage.startPrintBuildDoorOpen) {
                                qsTr("Close the build chamber door to start the print.")
                            }
                            else if(printPage.startPrintNoFilament) {
                                if (printPage.model_extruder_used && printPage.support_extruder_used) {
                                    qsTr("There is no material detected in at least one of the extruders." +
                                         " Please load material to start a print.")
                                } else if (printPage.model_extruder_used && !printPage.support_extruder_used) {
                                    qsTr("There is no material detected in the model extruder." +
                                         " Please load material to start a print.")
                                }
                            }
                            else if(printPage.startPrintMaterialMismatch) {
                                (materialPage.bay1.usingExperimentalExtruder ?
                                        qsTr("This print requires <b>%1</b> in <b>Support Extruder 2</b>.").arg(
                                                    printPage.print_support_material_name) :
                                        qsTr("This print requires <b>%1</b> in <b>Model Extruder 1</b>").arg(
                                                    printPage.print_model_material_name) +
                                                (!printPage.support_extruder_used ?
                                                    "." :
                                                    (" and <b>%2</b> in <b>Support Extruder 2</b>.").arg(
                                                    printPage.print_support_material_name))) +
                                qsTr("\nLoad the correct materials to start the print or export the file again with these material settings.")
                            }
                            else if(printPage.startPrintGenuineSliceUnknownMaterial) {
                                qsTr("This .MakerBot was exported for MakerBot materials. Use custom settings to" +
                                     " re-export this file for unknown materials. The limited warranty included" +
                                     " with this 3D printer does not apply to damage caused by the use of materials" +
                                     " not certified or approved by MakerBot. For additional information, please visit" +
                                     " MakerBot.com/legal/warranty.")
                            }
                            else if(printPage.startPrintUnknownSliceGenuineMaterial) {
                                qsTr("This .MakerBot is exported for unknown materials. It is recommended" +
                                     " to re-export this file for the correct materials for best results.")
                            }
                            else if(printPage.startPrintWithUnknownMaterials) {
                                qsTr("Be sure <b>%1</b> is in <b>Model Extruder 1</b>").arg(
                                     printPage.print_model_material_name) +
                                 (printPage.support_extruder_used ?
                                            qsTr(" and <b>%1</b> is in <b>Support Extruder 2</b>.").arg(
                                                 printPage.print_support_material_name) :
                                            qsTr(".")) +
                                  qsTr("\nThis printer is optimized for genuine MakerBot materials.")
                            }
                            else if(printPage.startPrintWithInsufficientModelMaterial ||
                                    printPage.startPrintWithInsufficientSupportMaterial) {
                                var insufficientModel = printPage.startPrintWithInsufficientModelMaterial
                                var insufficientSupport = printPage.startPrintWithInsufficientSupportMaterial
                                var modelMatStr = printPage.print_model_material_name
                                var supportMatStr = printPage.print_support_material_name
                                qsTr("There may not be enough <b>%1").arg(
                                     (insufficientModel && insufficientSupport) ?
                                         qsTr("%1</b> and <b>%2</b>").arg(modelMatStr).arg(supportMatStr) :
                                         (insufficientModel ?
                                                qsTr("%1</b>").arg(modelMatStr) :
                                                (insufficientSupport ?
                                                    qsTr("%1</b>").arg(supportMatStr) :
                                                    qsTr("</b>")))) +
                                qsTr(" to complete this print. The print will pause when the material runs out and a new spool can be loaded. Or change the material now.")
                            }
                             else {
                                emptyString
                            }
                        }
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        font.family: defaultFont.name
                        font.pixelSize: 20
                        lineHeight: 1.35
                    }
                }
            }
        }

        CustomPopup {
            popupName: "LabsExtruderDetected"
            id: experimentalExtruderPopup
            popupWidth: 720
            popupHeight: 350
            visible: !experimentalExtruderAcknowledged &&
                     experimentalExtruderInstalled
            showOneButton: true
            full_button_text: qsTr("CONTINUE")
            full_button.onClicked: {
                experimentalExtruderAcknowledged = true
                experimentalExtruderPopup.close()
            }

            ColumnLayout {
                id: columnLayout_exp_ext_popup
                width: 590
                height: children.height
                spacing: 20
                anchors.top: parent.top
                anchors.topMargin: 95
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: alert_text_exp_ext_popup
                    color: "#cbcbcb"
                    text: qsTr("MAKERBOT LABS EXTRUDER DETECTED")
                    font.letterSpacing: 3
                    Layout.alignment: Qt.AlignHCenter
                    font.family: defaultFont.name
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Text {
                    id: description_text_exp_ext_popup
                    color: "#cbcbcb"
                    text: {
                        qsTr("Visit MakerBot.com/Labs to learn about our material\n" +
                             "partners and recommended print settings. Material should\n" +
                             "be loaded through the AUX port under the removable cover\n" +
                             "on the top left of the printer. Make sure that the extruders\n" +
                             "are calibrated before printing. The Experimental Extruder is\n" +
                             "an experimental product and is not covered under warranty\n" +
                             "or MakerCare."
                            )
                    }
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.weight: Font.Light
                    wrapMode: Text.WordWrap
                    font.family: defaultFont.name
                    font.pixelSize: 18
                    font.letterSpacing: 1
                    lineHeight: 1.3
                }
            }
        }

        CustomPopup {
            popupName: "HepaFilterError"
            id: hepaFilterErrorPopup
            popupWidth: 720
            popupHeight: 280
            visible: (bot.hepaErrorCode > 0) && !hepaErrorAcknowledged
            showOneButton: true
            full_button_text: qsTr("OK")
            full_button.onClicked: {
                hepaErrorAcknowledged = true
                hepaFilterErrorPopup.close()
            }
            left_button_text: qsTr("CONTINUE PRINTING")
            right_button_text: qsTr("PAUSE PRINTING")
            left_button.onClicked: {
                hepaErrorAcknowledged = true
                hepaFilterErrorPopup.close()
            }
            right_button.onClicked: {
                bot.pauseResumePrint("suspend")
            }

            ColumnLayout {
                id: columnLayout_hepa_error_popup
                width: 650
                height: children.height
                spacing: 20
                anchors.top: parent.top
                anchors.topMargin: 160
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: alert_text_hepa_error_popup
                    color: "#cbcbcb"
                    text: qsTr("AIR FILTER ERROR")
                    font.letterSpacing: 3
                    Layout.alignment: Qt.AlignHCenter
                    font.family: defaultFont.name
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Text {
                    id: description_text_hepa_error_popup
                    color: "#cbcbcb"
                    text: {
                        qsTr("There seems to be something wrong with the filter. Error Code %1\n" +
                             "Visit support.makerbot.com to learn more.").arg(bot.hepaErrorCode)
                    }
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.weight: Font.Light
                    wrapMode: Text.WordWrap
                    font.family: defaultFont.name
                    font.pixelSize: 18
                    font.letterSpacing: 1
                    lineHeight: 1.3
                }
            }
        }

        CustomPopup {
            popupName: "HepaFilterReset"
            id: hepaFilterResetPopup
            popupWidth: 720
            popupHeight: 280
            visible: false
            showTwoButtons: true
            left_button_text: qsTr("CANCEL PROCEDURE")
            right_button_text: qsTr("CONTINUE PROCEDURE")
            right_button.onClicked: {
                bot.resetFilterHours()
                bot.hepaFilterPrintHours = 0
                bot.hepaFilterChangeRequired = false
                hepaFilterResetPopup.close()
            }
            left_button.onClicked: {
                hepaFilterResetPopup.close()
            }

            ColumnLayout {
                id: columnLayout_hepa_reset_popup
                width: 650
                height: children.height
                spacing: 20
                anchors.top: parent.top
                anchors.topMargin: 160
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: alert_text_hepa_reset_popup
                    color: "#cbcbcb"
                    text: qsTr("RESET FILTER?")
                    font.letterSpacing: 3
                    Layout.alignment: Qt.AlignHCenter
                    font.family: defaultFont.name
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Text {
                    id: description_text_hepa_reset_popup
                    color: "#cbcbcb"
                    text: {
                        qsTr("Doing this assumes a new filter has been installed.")
                    }
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.weight: Font.Light
                    wrapMode: Text.WordWrap
                    font.family: defaultFont.name
                    font.pixelSize: 18
                    font.letterSpacing: 1
                    lineHeight: 1.3
                }
            }
        }

        CustomPopup {
            popupName: "NPSSurvey"
            id: npsSurveyPopup
            popupWidth: 720
            popupHeight: 325
            visible: false
            showTwoButtons: true
            left_button_text: qsTr("LATER")
            right_button_text: qsTr("SEND FEEDBACK")
            right_button.onClicked: {
                if (ratings_buttons.score >= 0) {
                    bot.submitNPSSurvey(ratings_buttons.score)
                    updateNPSSurveyDueDate()
                    npsSurveyPopup.close()
                }
            }
            left_button.onClicked: {
                updateNPSSurveyDueDate()
                npsSurveyPopup.close()
            }
            onOpened: {
                ratings_buttons.checkState = Qt.Unchecked
            }

            ColumnLayout {
                id: columnLayout_nps_survey_popup
                width: 650
                height: children.height + 75
                spacing: 30
                anchors.top: parent.top
                anchors.topMargin: 110
                anchors.horizontalCenter: parent.horizontalCenter

                TextHeadline {
                    id: titleText_nps_survey_popup
                    text: qsTr("HOW LIKELY ARE YOU TO RECOMMEND THE MAKERBOT METHOD TO A FRIEND OR COLLEAGUE?")
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: parent.width
                }

                ColumnLayout {
                    id: ratingBar_nps_survey_popup
                    Layout.preferredWidth: parent.width
                    spacing: 20

                    RowLayout {
                        id: legend_text_nps_survey_popup
                        Layout.preferredWidth: parent.width
                        spacing: 350

                        TextSubheader {
                            text: qsTr("Not at all likely")
                            style: TextSubheader.Bold
                            color: "#ffffff"
                        }

                        TextSubheader {
                            text: qsTr("Extremely likely")
                            style: TextSubheader.Bold
                            color: "#ffffff"
                        }
                    }

                    ButtonGroup {
                        id: ratings_buttons
                        buttons: button_row.children
                        property int score: -1
                        onClicked: {
                            score = button.rating
                        }
                    }

                    RowLayout {
                        id: button_row
                        Layout.preferredWidth: parent.width
                        spacing: -4
                        Layout.alignment: Layout.Center

                        Repeater {
                            model: 10
                            delegate:
                            RadioButton {
                                id: control
                                property int rating: index + 1

                                indicator: Rectangle {
                                    width: 52
                                    height: 52
                                    radius: 5
                                    color: control.checked ? "#ffffff" : "#000000"
                                    border.width: 2
                                    border.color: "#ffffff"
                                }
                                contentItem: TextBody {
                                        style: TextBody.Large
                                        font.weight: Font.Bold
                                        text: control.rating
                                        color: control.checked ? "#000000" : "#ffffff"
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignHCenter
                                        anchors.fill : indicator
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
