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
    property bool isInManualCalibration: false


    property bool isNetworkConnectionAvailable: (bot.net.interface == "ethernet" ||
                                                 bot.net.interface == "wifi")
    onIsNetworkConnectionAvailableChanged: {
        fre.setStepEnable(FreStep.SetupWifi, !isNetworkConnectionAvailable)
        fre.setStepEnable(FreStep.LoginMbAccount, isNetworkConnectionAvailable)
    }

    property bool safeToRemoveUsb: bot.safeToRemoveUsb
    onSafeToRemoveUsbChanged: {
        if(safeToRemoveUsb && isFreComplete && !isInManualCalibration) {
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
            freScreen.state = "welcome"
            break;
        case FreStep.SunflowerSetupGuide:
            freScreen.state = "magma_setup_guide1"
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
        case FreStep.MaterialCaseSetup:
            freScreen.state = "material_case_setup"
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


    property bool isOffline: bot.net.interface != "wifi" &&
                             bot.net.interface != "ethernet"

    onIsOfflineChanged: {
        if(isOffline) {
            addToNotificationsList("printer_offline",
                                   qsTr("Printer Is Offline"),
                                   MoreporkUI.NotificationPriority.Persistent,
                                   function() {
                                       if(isProcessRunning()) {
                                           printerNotIdlePopup.open()
                                           return
                                       }

                                       // Navigate to System Settings Page
                                       if(settingsPage.settingsSwipeView.currentIndex != SettingsPage.SystemSettingsPage) {
                                           resetSettingsSwipeViewPages()
                                           mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                                           settingsPage.settingsSwipeView.swipeToItem(SettingsPage.SystemSettingsPage)
                                       }
                                   })
        } else {
            removeFromNotificationsList("printer_offline")
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
        // If extruders are mismatching dont bother showing the
        // calibration required popup
        if(wrongExtruderPopup.modelExtWrong ||
           wrongExtruderPopup.supportExtWrong ||
           wrongExtruderPopup.extruderComboMismatch) {
            return
        }

        // Do not open this popup while the user is in the process of
        // attaching the extruders in the attach extruders flow.
        if(materialPage.materialSwipeView.currentIndex ==
                MaterialPage.AttachExtruderPage) {
            return
        }

        if(extrudersCalibrated || !extrudersPresent) {
            extNotCalibratedPopup.close()
            removeFromNotificationsList("extruders_not_calibrated")
        }
        // Do not open popup in FRE and both extruders must
        // be present for this popup to open
        if (!extrudersCalibrated && isFreComplete && extrudersPresent) {
            extNotCalibratedPopup.open()
            addToNotificationsList("extruders_not_calibrated",
                                   qsTr("Extruders not calibrated"),
                                   MoreporkUI.NotificationPriority.Persistent,
                                   () => {
                                       if(isProcessRunning()) {
                                           printerNotIdlePopup.open()
                                           return
                                       }
                                       extNotCalibratedPopup.open()
                                   })
        }
    }

    onExtrudersCalibratedChanged: {
        calibratePopupDeterminant()
    }

    onExtrudersPresentChanged: {
        // Get a fresh update of the extruders configs which will update flags
        // used to evaluate whether the attached extruders combo is valid, as
        // well as whether they need to be calibrated.
        bot.getExtrudersConfigs()
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
        fre.setStepEnable(FreStep.SoftwareUpdate, isfirmwareUpdateAvailable)
        if(isfirmwareUpdateAvailable && isFreComplete) {

            // Open FW Update popup
            if(settingsPage.systemSettingsPage.systemSettingsSwipeView.currentIndex != SystemSettingsPage.FirmwareUpdatePage) {
                firmwareUpdatePopup.open()
            }

            // Add firmware item to notifications
            addToNotificationsList("firmware_update_available",
                                   qsTr("Firmware Update Available"),
                                   MoreporkUI.NotificationPriority.Persistent,
                                   function() {
                                       if(isProcessRunning()) {
                                           printerNotIdlePopup.open()
                                           return
                                       }
                                       if(settingsPage.systemSettingsPage.systemSettingsSwipeView.currentIndex != SystemSettingsPage.FirmwareUpdatePage) {
                                           resetSettingsSwipeViewPages()
                                           mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                                           settingsPage.settingsSwipeView.swipeToItem(SettingsPage.SystemSettingsPage)
                                           settingsPage.systemSettingsPage.systemSettingsSwipeView.swipeToItem(SystemSettingsPage.FirmwareUpdatePage)
                                       }
                                   })

        } else if(!isfirmwareUpdateAvailable){
            removeFromNotificationsList("firmware_update_available")
        }

    }

    property bool skipFirmwareUpdate: false
    property bool viewReleaseNotes: false

    onIsBuildPlateClearChanged: {
        if(isBuildPlateClear) {
            buildPlateClearPopup.open()
        }
        else {
            buildPlateClearPopup.close()
        }
    }

    // This holds the actual drawer object. The Notifications Drawer is
    // the default one when the UI starts up.
    property var activeDrawer: notificationsDrawer

    // Enum used to set the notifications icons state i.e to show the
    // notifications count or to show the drawer open/close arrow icon
    // depending on which drawer is the active one. Currently we only
    // differentiate between the notification drawer and other drawers.
    enum ActiveDrawer {
        NotificationsDrawer,
        OtherDrawers
    }
    property int currentActiveDrawer: MoreporkUI.ActiveDrawer.NotificationsDrawer

    // All drawers can be in open or closed state and the top bar
    // notifications/drawer state icon looks different based on the current active
    // drawer and whether that drawer is open or closed. e.g. when the notifications
    // drawer is active and in the closed state the notifications icon shows the
    // notifications count but when opened it shows the close arrow. Other drawers
    // just show the open/close icon when they are closed/open respectively.
    enum DrawerState {
        Closed,
        Open
    }
    property int drawerState: MoreporkUI.DrawerState.Closed

    // Error notifications (button) are styled differently from informational
    // notifications and should appear above informational notifications in the
    // notifications drawer. Persistent notifications are the highest in priority
    // and should be top most in the list.
    enum NotificationPriority {
        Informational,
        Error,
        Persistent
    }

    // An array holding the individual notification objects.
    property var notificationsList: ([])

    // Call this function to post a notiification.
    // Notification names must to be unique.
    //
    // e.g.
    // addToNotificationsList("notification_id_string", "display_name",
    //         MoreporkUI.NotificationPriority.Persistent,
    //         test_func)
    // addToNotificationsList("notification_id_string", "display_name",
    //         MoreporkUI.NotificationPriority.Error,
    //         test_func)
    // addToNotificationsList("notification_id_string", "display_name",
    //         MoreporkUI.NotificationPriority.Informational,
    //         test_func)

    function addToNotificationsList(id, name, priority, func) {
        // Don't add duplicate notifications.
        if(notificationsList.find(v => v.id === id)) {
            console.log("Attempting to post duplicate notification " + id)
            return
        }

        notificationsList.push(
            {
                id: id,
                name: name,
                priority: priority,
                func: func
            }
        )

        // Notifications should appear in the order of their priority in the list
        // so they are sorted in this order -- Persistent, Error, Informational.
        notificationsList.sort(function(a, b){return b["priority"] - a["priority"]})
        notificationsListChanged()
        console.info("Posted notification " + id)
    }

    // Call this function to remove a notiification
    //
    // e.g.
    // removeFromNotificationsList("notification_id_string")
    function removeFromNotificationsList(id) {
        notificationsList = notificationsList.filter(v => v.id !== id)
        notificationsListChanged()
        console.info("Removed notification " + id)
    }

    function test_func() {
        console.log("test_func")
    }

    // The notifications icon in the top bar looks different when there
    // are no notifications and when there are notifications and when
    // there is aleast one error notification. The notificationsState enum
    // is used to keep track of this.
    enum NotificationsState {
        NoNotifications,
        NotificationsAvailable,
        ErrorNotificationsAvailable
    }
    property int notificationsState: MoreporkUI.NotificationsState.NoNotifications
    onNotificationsListChanged: {
        if(notificationsList.length) {
            notificationsState = MoreporkUI.NotificationsState.NotificationsAvailable
            // Since the persistent notifications are located before the error notifications
            // in the list we cannot just check the first element for error notifications
            // which would've been very convenient.
            for(var notif of notificationsList) {
                if(notif["priority"] == MoreporkUI.NotificationPriority.Error) {
                    notificationsState = MoreporkUI.NotificationsState.ErrorNotificationsAvailable
                    break;
                }
            }
        } else {
            notificationsState = MoreporkUI.NotificationsState.NoNotifications
        }
    }

    // This is the only function for controlling the drawer. By default the UI
    // starts with the NotificationsDrawer as the active one. Anytime a new
    // drawer is set as the active one it replaces the previous drawer but
    // when the active drawer is set to null the notifications drawer becomes
    // the active drawer. The current usage for this mechanism is anytime we
    // enter a page that has a drawer e.g. the sorting drawer we set it as the
    // current drawer and when we move out of the page we set the active drawer
    // to null.
    // This function will break if you try to pass in the notifications drawer
    // object to set it as the active drawer.
    function setActiveDrawer(drawer) {
        if(drawer) {
            if(activeDrawer != drawer) {
                if(activeDrawer) {
                    activeDrawer.close()
                    topBar.drawerDownClicked.disconnect(activeDrawer.open)
                }
                activeDrawer = drawer
                topBar.drawerDownClicked.connect(activeDrawer.open)
                currentActiveDrawer = MoreporkUI.OtherDrawers
                drawerState = MoreporkUI.DrawerState.Closed
            }
        } else {
            if(activeDrawer) {
                activeDrawer.close()
                topBar.drawerDownClicked.disconnect(activeDrawer.open)
            }
            activeDrawer = notificationsDrawer
            topBar.drawerDownClicked.connect(activeDrawer.open)
            currentActiveDrawer = MoreporkUI.NotificationsDrawer
            drawerState = MoreporkUI.DrawerState.Closed
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

    function disableOtherDrawer() {
        drawerState = MoreporkUI.DrawerState.Closed
        if(activeDrawer == printPage.printingDrawer ||
           activeDrawer == materialPage.materialPageDrawer ||
           activeDrawer == printPage.sortingDrawer) {
            setActiveDrawer(null)
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
        settingsPage.systemSettingsPage.setupProceduresPage.setupProceduresSwipeView.swipeToItem(SetupProceduresPage.BasePage, false)
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
        MaterialPage,   // 2
        SettingsPage    // 3
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

        PowerButtonScreen {
            id: powerButtonScreen
            z: 2
            visible: false
        }

        HeatShieldInstructions {
            anchors.fill: parent
            z: 2
        }

        Connections {
            target: power_key
            onPowerbuttonPressed: {
                console.info("Power button is pressed!")
                powerButtonScreen.visible = true
            }
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

        NotificationsDrawer {
            id: notificationsDrawer
            drawerStyle: CustomDrawer.DrawerStyle.NotificationsDrawer
        }

        TopBarForm {
            id: topBar
            z: 1
            backButton.visible: false
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
                    // Since the notifications drawer is the default drawer
                    // when moving to the home page we disable all other drawers
                    // which sets the notifications drawer as the active one.
                    // See disableOtherDrawer() and setActiveDrawer() for more info.
                    if(swipeToIndex === MoreporkUI.BasePage) {
                        topBar.backButton.visible = false
                        disableOtherDrawer()
                    } else {
                        topBar.backButton.visible = true
                    }

                    // When moving to the print page we set the printing drawer
                    // as the active one if a print process is running.
                    if(swipeToIndex == MoreporkUI.PrintPage) {
                        if(printPage.isPrintProcess) {
                            setActiveDrawer(printPage.printingDrawer)
                        }
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
                    property bool hasAltBack: true
                    property string topBarTitle: bot.process.type == ProcessType.Print ?
                                                     qsTr("PRINT") :
                                                     qsTr("Select Source")
                    property bool backIsCancel: isInManualCalibration

                    smooth: false
                    visible: false

                    function altBack() {
                        if(isInManualCalibration) {
                            settingsPage.extruderSettingsPage.manualZCalibration.cancelManualZCalPopup.open()
                        }
                        else if(!inFreStep) {
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

                // MoreporkUI.MaterialPage
                Item {
                    property var backSwiper: mainSwipeView
                    property int backSwipeIndex: MoreporkUI.BasePage
                    property string topBarTitle: qsTr("Material")
                    smooth: false
                    visible: false
                    MaterialPage {
                        id: materialPage
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
            }
        }

        CustomPopup {
            popupName: "SkipFreStep"
            id: skipFreStepPopup
            popupHeight: 285
            popupWidth: 720

            showTwoButtons: true
            left_button_text: qsTr("BACK")
            right_button_text: qsTr("CONFIRM")

            left_button.onClicked: {
                skipFreStepPopup.close()
            }
            right_button.onClicked: {
                skipFreStepPopup.close()
                if (inFreStep) {
                    currentItem.skipFreStepAction()
                }
                if(currentFreStep == FreStep.AttachExtruders ||
                   currentFreStep == FreStep.LevelBuildPlate ||
                   currentFreStep == FreStep.CalibrateExtruders ||
                   currentFreStep == FreStep.MaterialCaseSetup ||
                   currentFreStep == FreStep.LoadMaterial ||
                   currentFreStep == FreStep.TestPrint) {
                    fre.setFreStep(FreStep.FreComplete)
                }
                else {
                    fre.gotoNextStep(currentFreStep)
                }
            }

            ColumnLayout {
                width: 720
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -40

                Image {
                    source: "qrc:/img/popup_error.png"
                    Layout.alignment: Qt.AlignHCenter
                }

                TextHeadline {
                    Layout.alignment: Qt.AlignHCenter
                    text: {
                        switch(currentFreStep) {
                        case FreStep.Welcome:
                            ""
                            break;
                        case FreStep.SetupWifi:
                            qsTr("OFFLINE SETUP?")
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
                        case FreStep.AttachExtruders:
                        case FreStep.LevelBuildPlate:
                        case FreStep.CalibrateExtruders:
                        case FreStep.MaterialCaseSetup:
                        default:
                            qsTr("SKIP THIS STEP?")
                            break;
                        }
                    }
                }

                TextBody {
                    Layout.alignment: Qt.AlignHCenter
                    text: {
                        switch(currentFreStep) {
                        case FreStep.Welcome:
                            ""
                            break;
                        case FreStep.SetupWifi:
                            qsTr("We recommend connecting your printer for the best experience.")
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
                        case FreStep.AttachExtruders:
                        case FreStep.LevelBuildPlate:
                        case FreStep.CalibrateExtruders:
                        case FreStep.MaterialCaseSetup:
                        default:
                            qsTr("This may skip other set-up procedures as well. You can revisit all steps of the set-up in the settings.")
                            break;
                        }
                    }
                    Layout.fillWidth: true
                    Layout.preferredWidth: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
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

        CustomPopup {
            popupName: "InstallUnsignedFirmware"
            id: installUnsignedFwPopup
            closePolicy: Popup.CloseOnPressOutside
            popupHeight: installUnsignedFwBasePopupLayout.height + 140

            showTwoButtons: true
            right_button_text: qsTr("INSTALL")
            right_button.onClicked: {
                bot.respondInstallUnsignedFwRequest("allow")
                installUnsignedFwPopup.close()
            }
            left_button_text: qsTr("CANCEL")
            left_button.onClicked: {
                bot.respondInstallUnsignedFwRequest("rejected")
                installUnsignedFwPopup.close()
            }

            ColumnLayout {
                id: installUnsignedFwBasePopupLayout
                height: children.height
                anchors.top: installUnsignedFwPopup.popupContainer.top
                anchors.topMargin: 35
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20

                TextHeadline {
                    id: install_unsigned_fw_header
                    text: qsTr("UNKNOWN FIRMWARE")
                    Layout.alignment: Qt.AlignHCenter
                }

                TextBody {
                    id: install_unsigned_fw_description
                    width: 600
                    Layout.preferredWidth: width
                    text: qsTr("You are installing an unknown firmware, this can damage your printer and void your warranty. Are you sure you want to proceed?")
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        CustomPopup {
            popupName: "FirmwareUpdateNotification"
            id: firmwareUpdatePopup
            popupHeight: firmwareUpdatePopupColumnLayout.height +140
            closePolicy: Popup.CloseOnPressOutside

            showTwoButtons: true
            right_button_text: qsTr("UPDATE")
            right_button.onClicked: {
                mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.SystemSettingsPage)
                settingsPage.systemSettingsPage.systemSettingsSwipeView.swipeToItem(SystemSettingsPage.FirmwareUpdatePage)
                firmwareUpdatePopup.close()
            }
            left_button_text: skipFirmwareUpdate ? qsTr("SKIP") : qsTr("NOT NOW")
            left_button.onClicked: {
                if(skipFirmwareUpdate) {
                    firmwareUpdatePopup.close()
                }
                else {
                    skipFirmwareUpdate = true
                    viewReleaseNotes = false
                }
            }
            onClosed: {
                viewReleaseNotes = false
                skipFirmwareUpdate = false
            }

            ColumnLayout {
                id: firmwareUpdatePopupColumnLayout
                height: children.height
                anchors.top: firmwareUpdatePopup.popupContainer.top
                anchors.topMargin: 35
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20

                TextHeadline {
                    id: firmware_header_text
                    text: viewReleaseNotes ? qsTr("FIRMWARE %1 RELEASE NOTES").arg(bot.firmwareUpdateVersion) : skipFirmwareUpdate ? qsTr("SKIP FIRMWARE UPDATE?") : qsTr("FIRMWARE UPDATE AVAILABLE")
                    Layout.alignment: Qt.AlignHCenter
                }

                TextBody {
                    id: firmware_description_text
                    width: 500
                    text: skipFirmwareUpdate ? qsTr("We recommend using the most up to date firmware for your printer.") : qsTr("A new version of firmware is available. Do you want to update to the most recent version %1?").arg(bot.firmwareUpdateVersion)
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: width
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
                        TextBody {
                            id: firmware_release_notes_text
                            width: 600
                            text: model.modelData
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            Layout.preferredWidth: width
                        }
                    ScrollBar.vertical: ScrollBar {
                        orientation: Qt.Vertical
                        policy: ScrollBar.AsNeeded
                    }
                }

                TextBody {
                    id: firmware_show_release_notes_text
                    text: qsTr("Tap to see Release Notes")
                    font.underline: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    visible: !skipFirmwareUpdate &&
                             !viewReleaseNotes

                    LoggingMouseArea {
                        logText: "firmwareUpdatePopup [" + firmware_show_release_notes_text.text + "]"
                        anchors.fill: parent
                        visible: !skipFirmwareUpdate
                        onClicked: {
                            viewReleaseNotes = true
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
            property bool extruderComboMismatch: {
                (bot.extruderAPresent && bot.extruderBPresent) &&
                (!bot.extruderACanPairTools || !bot.extruderBCanPairTools)
            }

            showOneButton: false
            showTwoButtons: false
            visible: modelExtWrong || supportExtWrong || extruderComboMismatch

            ColumnLayout {
                id: wrongExtColumnLayout
                height: children.height
                width: 630
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 20

                Image {
                    source: "qrc:/img/process_error_small.png"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                TextHeadline {
                    text: qsTr("WRONG EXTRUDER TYPE DETECTED")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                TextBody {
                    text: {
                        if (wrongExtruderPopup.extruderComboMismatch) {
                            if(bot.machineType == MachineType.Magma && bot.extruderAType == ExtruderType.MK14_COMP) {
                                // Composites with 2A combo on magma
                                qsTr("The Composites extruder cannot be used with a Support 2A extruder. Please use the Labs extruder in the model slot to support this configuration.")
                            } else {
                                // Normal + Hot Extruders combo
                                 qsTr("A Model 1XA Extruder can only be used with a Support 2XA Extruder. A Model 1A Extruder can only be used with a Support 2A Extruder.")
                            }
                        } else {
                            if (wrongExtruderPopup.modelExtWrong) {
                                qsTr("Please insert a %1 extruder into slot 1.").arg(bot.extruderASupportedTypes.join("/"))
                            } else if (wrongExtruderPopup.supportExtWrong) {
                                qsTr("Please insert a %1 extruder into slot 2. Currently only model and support printing is supported.").arg(bot.extruderBSupportedTypes.join("/"))
                            } else {
                                emptyString
                            }
                        }
                    }
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    style: TextBody.Large
                    Layout.preferredWidth: parent.width
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
                    text: qsTr("CARRIAGE COMMUNICATION ERROR")
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
                TextBody {
                    text: qsTr(
                        "The printer’s carriage is reporting communication drop-outs. " +
                        "Try restarting the printer. If this happens again, please " +
                        "contact MakerBot support."
                    )
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

        CustomPopup {
            id: printerNotIdlePopup
            popupName: "PrinterNotIdleWarning"

            showOneButton: true
            full_button_text: qsTr("CLOSE")
            full_button.onClicked: {
                printerNotIdlePopup.close()
            }

            ColumnLayout {
                width: parent.width
                height: children.height
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenterOffset: -25

                Image{
                    id: error_icon
                    source: "qrc:/img/popup_error.png"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 10
                }

                TextHeadline {
                    id: cancel_popup_header
                    style: TextHeadline.Base
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("PRINTER IS BUSY")
                    Layout.bottomMargin: 7
                }

                TextBody {
                    text: qsTr("Please wait until the printer is idle.")
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 30
                }
            }
        }

        CustomPopup {
            popupName: "ExtrudersNotCalibrated"
            id: extNotCalibratedPopup
            showTwoButtons: true
            left_button_text: qsTr("SKIP")
            left_button.onClicked: {
                extNotCalibratedPopup.close()
            }
            right_button_text: qsTr("GO TO PAGE")
            right_button.onClicked: {
                extNotCalibratedPopup.close()
                resetSettingsSwipeViewPages()
                mainSwipeView.swipeToItem(MoreporkUI.SettingsPage)
                settingsPage.settingsSwipeView.swipeToItem(SettingsPage.ExtruderSettingsPage)
                settingsPage.extruderSettingsPage.extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.AutomaticCalibrationPage)
            }

            ColumnLayout {
                width: parent.width
                height: children.height
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -18
                spacing: 10

                TextHeadline {
                    id: calibrate_extruders
                    style: TextHeadline.Base
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("CALIBRATE EXTRUDERS?")
                    Layout.bottomMargin: 7
                }

                TextBody {
                    text: qsTr("Calibration enables precise 3D printing. The printer must calibrate new extruders to ensure print quality")
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 30
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: 600
                    horizontalAlignment: Text.AlignHCenter
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

        CustomPopup {
            id: cancelPrintPopup
            popupWidth: 720
            popupHeight: 275
            showTwoButtons: true
            left_button_text: qsTr("BACK")
            left_button.onClicked: {
                cancelPrintPopup.close()
            }
            right_button_text: qsTr("CONFIRM")
            right_button.onClicked: {
                bot.cancel()
                printPage.clearErrors()
                cancelPrintPopup.close()
            }

            ColumnLayout {
                width: parent.width
                height: children.height
                spacing: 20
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenterOffset: -45

                Image{
                    source: "qrc:/img/popup_error.png"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                Text {
                    color: "#cbcbcb"
                    text: qsTr("CANCEL PRINT?")
                    font.letterSpacing: 3
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 25
                    font.family: defaultFont.name
                    font.weight: Font.Bold
                    font.pixelSize: 20
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

        CustomPopup {
            popupName: "StartPrintError"
            id: startPrintErrorsPopup
            popupHeight: columnLayout_start_print_errors_popup.height +145
            closePolicy: Popup.CloseOnPressOutside
            onClosed: {
                printPage.startPrintBuildDoorOpen = false
                printPage.startPrintTopLidOpen = false
                printPage.startPrintNoFilament = false
                printPage.startPrintUnknownSliceGenuineMaterial = false
                printPage.startPrintGenuineSliceUnknownMaterial = false
                printPage.startPrintMaterialMismatch = false
                printPage.startPrintWithLabsExtruder = false
            }

            showOneButton: (printPage.startPrintBuildDoorOpen ||
                            printPage.startPrintTopLidOpen)
            showTwoButtons: (!printPage.startPrintBuildDoorOpen &&
                             !printPage.startPrintTopLidOpen)
            full_button_text: qsTr("OK")

            full_button.onClicked: {
                startPrintErrorsPopup.close()
            }

            left_button_text: {
                if(printPage.startPrintNoFilament ||
                   printPage.startPrintMaterialMismatch ||
                   printPage.startPrintGenuineSliceUnknownMaterial ||
                   printPage.startPrintWithLabsExtruder) {
                    qsTr("BACK")
                } else if(printPage.startPrintUnknownSliceGenuineMaterial) {
                    qsTr("START ANYWAY")
                } else {
                    emptyString
                }
            }

            left_button.onClicked: {
                startPrintErrorsPopup.close()
                if(printPage.startPrintUnknownSliceGenuineMaterial) {
                    if(printPage.startPrintDoorLidCheck()) {
                        printPage.confirm_build_plate_popup.open()
                    } else {
                        startPrintErrorsPopup.open()
                    }
                }
            }

            function resetDetailsAndGoToMaterialsPage() {
                printPage.resetPrintFileDetails()
                printPage.printSwipeView.swipeToItem(PrintPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.MaterialPage)
            }

            right_button_text: {
                if(printPage.startPrintNoFilament) {
                    qsTr("LOAD MATERIAL")
                } else if(printPage.startPrintMaterialMismatch ||
                        printPage.startPrintGenuineSliceUnknownMaterial ||
                        printPage.startPrintUnknownSliceGenuineMaterial) {
                    qsTr("CHANGE MATERIAL")
                } else if(printPage.startPrintWithLabsExtruder) {
                    qsTr("CONTINUE")
                } else {
                    emptyString
                }
            }

            right_button.onClicked: {
                startPrintErrorsPopup.close()
                if(printPage.startPrintNoFilament ||
                   printPage.startPrintMaterialMismatch ||
                   printPage.startPrintGenuineSliceUnknownMaterial ||
                   printPage.startPrintUnknownSliceGenuineMaterial) {
                    resetDetailsAndGoToMaterialsPage()
                    if(isInManualCalibration) {
                        // Reset Manual Z Cal
                        settingsPage.extruderSettingsPage.manualZCalibration.resetProcess(true)
                    }
                } else if(printPage.startPrintWithLabsExtruder) {
                    if(printPage.startPrintDoorLidCheck()) {
                        printPage.confirm_build_plate_popup.open()
                    } else {
                        startPrintErrorsPopup.open()
                    }
                }
            }

            ColumnLayout {
                id: columnLayout_start_print_errors_popup
                width: 650
                height: children.height
                anchors.top: startPrintErrorsPopup.popupContainer.top
                anchors.topMargin: 35
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20

                Image {
                    id: error_image
                    width: sourceSize.width - 10
                    height: sourceSize.height -10
                    Layout.alignment: Qt.AlignHCenter
                    source: "qrc:/img/process_error_small.png"
                }

                TextHeadline {
                    id: main_text_start_print_errors_popup
                    text: qsTr("START PRINT ERROR")
                    Layout.alignment: Qt.AlignHCenter
                }

                TextBody {
                    id: sub_text_start_print_errors_popup
                    Layout.preferredWidth: parent.width
                    text: "Error message"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                TextBody {
                    id: mb_compatibility_link_error_popup
                    text: "<br><b>makerbot.com/compatibility</b>"
                    Layout.alignment: Qt.AlignHCenter
                    visible: false
                }

                states: [
                    State {
                        name: "close_top_lid"
                        when: printPage.startPrintTopLidOpen

                        PropertyChanges {
                            target: main_text_start_print_errors_popup
                            text: qsTr("CLOSE THE TOP LID")
                        }

                        PropertyChanges {
                            target: sub_text_start_print_errors_popup
                            text: qsTr("Put the top lid back on the printer to start the print.")
                        }

                        PropertyChanges {
                            target: mb_compatibility_link_error_popup
                            visible: false
                        }
                    },
                    State {
                        name: "close_build_chamber_door"
                        when: printPage.startPrintBuildDoorOpen


                        PropertyChanges {
                            target: main_text_start_print_errors_popup
                            text: qsTr("CLOSE BUILD CHAMBER DOOR")
                        }

                        PropertyChanges {
                            target: sub_text_start_print_errors_popup
                            text: qsTr("Close the build chamber door to start the print.")
                        }

                        PropertyChanges {
                            target: mb_compatibility_link_error_popup
                            visible: false
                        }
                    },
                    State {
                        name: "no_material_detected"
                        when: printPage.startPrintNoFilament

                        PropertyChanges {
                            target: main_text_start_print_errors_popup
                            text: qsTr("NO MATERIAL DETECTED")
                        }

                        PropertyChanges {
                            target: sub_text_start_print_errors_popup
                            text: {
                                if (printPage.model_extruder_used && printPage.support_extruder_used) {
                                    qsTr("There is no material detected in at least one of the extruders." +
                                         " Please load material to start a print.")
                                } else if (printPage.model_extruder_used && !printPage.support_extruder_used) {
                                    qsTr("There is no material detected in the model extruder." +
                                         " Please load material to start a print.")
                                }
                            }
                        }

                        PropertyChanges {
                            target: mb_compatibility_link_error_popup
                            visible: false
                        }
                    },
                    State {
                        name: "material_mismatch_warning"
                        when: printPage.startPrintMaterialMismatch

                        PropertyChanges {
                            target: main_text_start_print_errors_popup
                            text: qsTr("MATERIAL MISMATCH")
                        }

                        PropertyChanges {
                            target: sub_text_start_print_errors_popup
                            text: {
                                if(isInManualCalibration) {
                                    qsTr("Manual Z-Calibration print is only supported for ABS-R, ABS-CF, and RapidRinse.")
                                } else {
                                    (materialPage.bay1.usingExperimentalExtruder ?
                                            qsTr("This print requires <b>%1</b> in <b>Support Extruder 2</b>.").arg(
                                                        printPage.print_support_material_name) :
                                      (printPage.support_extruder_used?
                                            qsTr("This print requires <b>%1</b> in <b>Model Extruder 1</b> and <b>%2</b> in <b>Support Extruder 2</b>.").arg(
                                                        printPage.print_model_material_name).arg(printPage.print_support_material_name) :
                                            qsTr("This print requires <b>%1</b> in <b>Model Extruder 1</b>.").arg(
                                                        printPage.print_model_material_name))) + "\n"
                                    qsTr("Load the correct materials to start the print or export the file again with these material settings.")
                                }
                            }
                        }

                        PropertyChanges {
                            target: mb_compatibility_link_error_popup
                            visible: true
                        }
                    },
                    State {
                        name: "unknown_material_warning"
                        when: printPage.startPrintGenuineSliceUnknownMaterial

                        PropertyChanges {
                            target: main_text_start_print_errors_popup
                            text: qsTr("UNKNOWN MATERIAL")
                        }

                        PropertyChanges {
                            target: sub_text_start_print_errors_popup
                            text: qsTr("This .MakerBot was exported for MakerBot materials. Use custom settings to" +
                                         " re-export this file for unknown materials. The limited warranty included" +
                                         " with this 3D printer does not apply to damage caused by the use of materials" +
                                         " not certified or approved by MakerBot. For additional information, please visit" +
                                         " MakerBot.com/legal/warranty.")
                        }

                        PropertyChanges {
                            target: mb_compatibility_link_error_popup
                            visible: false
                        }
                    },
                    State {
                        name: "makerbot_genuine_materials"
                        when: printPage.startPrintUnknownSliceGenuineMaterial

                        PropertyChanges {
                            target: main_text_start_print_errors_popup
                            text: qsTr("MAKERBOT GENUINE MATERIALS")
                        }

                        PropertyChanges {
                            target: sub_text_start_print_errors_popup
                            text: qsTr("This .MakerBot is exported for unknown materials. It is recommended" +
                             " to re-export this file for the correct materials for best results.")
                        }

                        PropertyChanges {
                            target: mb_compatibility_link_error_popup
                            visible: false
                        }
                    },
                    State {
                        name: "start_print_with_labs_extruder"
                        when: printPage.startPrintWithLabsExtruder

                        PropertyChanges {
                            target: main_text_start_print_errors_popup
                            text: qsTr("LABS EXTRUDER ALERT")
                        }

                        PropertyChanges {
                            target: sub_text_start_print_errors_popup
                            text: qsTr("This Manual Z Calibration print is designed for optimizing calibration for " +
                                       "printing with <b>ABS-R/ABS-CF</b> as the model material and <b>RapidRinse</b> as the support " +
                                       "material. Printing with other materials is not recommended and could negatively " +
                                       "impact print quality. If you experience worse results with other materials " +
                                       "running automatic calibration might help.")
                        }

                        PropertyChanges {
                            target: mb_compatibility_link_error_popup
                            visible: false
                        }
                    }
                ]
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
                        qsTr("Visit MakerBot.com/Labs to learn about our material " +
                             "partners and recommended print settings. Material should " +
                             "be loaded through the AUX port under the removable cover " +
                             "on the top left of the printer. Make sure that the extruders " +
                             "are calibrated before printing. The Experimental Extruder is " +
                             "an experimental product and is not covered under warranty " +
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
                        qsTr("There seems to be something wrong with the filter. Error Code %1. " +
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
            visible: false

            property string state: "reset_filter"
            showTwoButtons: state === "reset_filter"
            showOneButton: state === "complete"

            left_button_text: qsTr("BACK")
            right_button_text: qsTr("CONFIRM")
            full_button_text: qsTr("CLOSE")


            right_button.onClicked: {
                bot.resetFilterHours()
                bot.hepaFilterPrintHours = 0
                bot.hepaFilterChangeRequired = false
                state = "complete"
            }
            left_button.onClicked: {
                hepaFilterResetPopup.close()
            }
            full_button.onClicked: {
                hepaFilterResetPopup.close()
            }
            onClosed: {
                state = "reset_filter"
            }

            ColumnLayout {
                id: columnLayout_hepa_reset_popup
                height: children.height
                anchors.top: hepaFilterResetPopup.popupContainer.top
                anchors.topMargin: hepaFilterResetPopup.state === "complete" ?
                                       30 : 60
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 25

                Image {
                    source: "qrc:/img/popup_complete.png"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    visible: hepaFilterResetPopup.state === "complete"
                }

                TextHeadline {
                    id: alert_text_hepa_reset_popup
                    text: hepaFilterResetPopup.state === "complete" ? qsTr("Complete") : qsTr("RESET FILTER")
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                TextBody {
                    id: description_text_hepa_reset_popup
                    text: {
                        qsTr("This procedure will assume a new filter has been installed.")
                    }
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    visible: hepaFilterResetPopup.state !== "complete"
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

        CustomPopup {
            popupName: "HelpPopup"
            id: helpPopup
            popupWidth: 720
            popupHeight: columnLayout_help_popup.height + 130
            showOneButton: true
            full_button_text: qsTr("CLOSE")
            full_button.onClicked: {
                helpPopup.close()
            }
            property alias state: columnLayout_help_popup.state

            ColumnLayout {
                id: columnLayout_help_popup
                width: 600
                height: children.height
                spacing: 0
                anchors.top: parent.top
                anchors.topMargin: 90
                anchors.horizontalCenter: parent.horizontalCenter

                RowLayout {
                    spacing: 100
                    Layout.preferredHeight: children.height
                    Layout.preferredWidth: children.width
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                    Image {
                        id: help_qr_code
                        Layout.preferredHeight: 200
                        Layout.preferredWidth: 200
                        source: "qrc:/img/broken.png"
                        visible: true
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ColumnLayout {
                        spacing: 16
                        Layout.preferredWidth: 340
                        Layout.preferredHeight: children.height
                        TextHeadline {
                            id: help_title
                            text: qsTr("HELP")
                            Layout.alignment: Qt.AlignLeft
                            Layout.preferredWidth: parent.width
                            visible: true
                        }

                        TextBody {
                            id: help_description
                            text: qsTr("Scan the QR code for more information and troubleshooting tips.")
                            Layout.preferredWidth: parent.width
                            Layout.alignment: Qt.AlignLeft
                            visible: true
                        }

                        TextBody {
                            id: url
                            font.weight: Font.Bold
                            Layout.preferredWidth: parent.width
                            Layout.alignment: Qt.AlignLeft
                            visible: false
                        }
                    }
                }

                states: [
                    State {
                        name: "fre"

                        PropertyChanges {
                            target: help_qr_code
                            source: "qrc:/img/qr_230_xlsetup.png"
                        }

                        PropertyChanges {
                            target: help_title
                            text: qsTr("METHOD XL SETUP GUIDE")
                        }

                        PropertyChanges {
                            target: help_description
                            text: qsTr("Scan the QR code for more information and troubleshooting tips.")
                        }
                    },

                    State {
                        name: "general_help"

                        PropertyChanges {
                            target: help_qr_code
                            source: "qrc:/img/qr_230_general_help.png"
                        }

                        PropertyChanges {
                            target: help_title
                            text: qsTr("HELP")
                        }

                        PropertyChanges {
                            target: help_description
                            text: qsTr("Scan the QR code or visit the following URL "+
                                       "for more information and troubleshooting tips."+
                                       "<br><br><b>support.ultimaker.com</b>")
                        }
                    },

                    State {
                        name: "attach_extruders"

                        PropertyChanges {
                            target: help_qr_code
                            source: "qrc:/img/qr_230_compatibility.png"
                        }

                        PropertyChanges {
                            target: help_title
                            text: qsTr("METHOD COMPATIBILITY")
                        }

                        PropertyChanges {
                            target: help_description
                            text: qsTr("Scan the QR code for more information on compatibility of extruders and materials.")
                        }

                        PropertyChanges {
                            target: url
                            visible: false
                        }
                    },

                    State {
                        name: "cut_filament_tip_help"

                        PropertyChanges {
                            target: help_qr_code
                            source: "qrc:/img/qr_230_xlsetup.png"
                        }

                        PropertyChanges {
                            target: help_title
                            text: qsTr("CUT FILAMENT TIP HELP")
                        }

                        PropertyChanges {
                            target: url
                            visible: false
                        }
                    },

                    State {
                        name: "methodxl_place_desiccant_help"

                        PropertyChanges {
                            target: help_qr_code
                            source: "qrc:/img/qr_230_xlsetup.png"
                        }

                        PropertyChanges {
                            target: help_title
                            text: qsTr("PLACE DESICCANT HELP")
                        }

                        PropertyChanges {
                            target: url
                            visible: false
                        }
                    },

                    State {
                        name: "methodxl_place_material_help"

                        PropertyChanges {
                            target: help_qr_code
                            source: "qrc:/img/qr_230_xlsetup.png"
                        }

                        PropertyChanges {
                            target: help_title
                            text: qsTr("PLACE MATERIAL HELP")
                        }

                        PropertyChanges {
                            target: url
                            visible: false
                        }
                    },
                    State {
                        name: "methodxl_feed_filament_help"

                        PropertyChanges {
                            target: help_qr_code
                            source: "qrc:/img/qr_230_xlsetup.png"
                        }

                        PropertyChanges {
                            target: help_title
                            text: qsTr("FEED MATERIAL HELP")
                        }

                        PropertyChanges {
                            target: url
                            visible: false
                        }
                    },
                    State {
                        name: "methodxl_locate_desiccant_help"

                        PropertyChanges {
                            target: help_qr_code
                            source: "qrc:/img/qr_230_xlsetup.png"
                        }

                        PropertyChanges {
                            target: help_title
                            text: qsTr("LOCATE DESICCANT HELP")
                        }

                        PropertyChanges {
                            target: url
                            visible: false
                        }
                    },
                    State {
                        name: "method_calibration"

                        PropertyChanges {
                            target: help_qr_code
                            source: "qrc:/img/qr_method_calibration.png"
                        }

                        PropertyChanges {
                            target: help_title
                            text: qsTr("HELP")
                        }

                        PropertyChanges {
                            target: url
                            text: "ultimaker.com/method-calibration"
                            visible: true
                        }
                    }

                ]
            }
        }
    }

    Component.onCompleted: {
        fre.setStepEnable(FreStep.SetupWifi, !isNetworkConnectionAvailable)
        fre.setStepEnable(FreStep.LoginMbAccount, isNetworkConnectionAvailable)
        fre.setStepEnable(FreStep.SoftwareUpdate, isfirmwareUpdateAvailable)

        // When starting up the UI we set the notifications drawer as the
        // active drawer.
        activeDrawer = notificationsDrawer
        topBar.drawerDownClicked.connect(activeDrawer.open)
        currentActiveDrawer = MoreporkUI.NotificationsDrawer
        drawerState = MoreporkUI.DrawerState.Closed
    }
}
