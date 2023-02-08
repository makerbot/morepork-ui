import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    id: topBar
    width: parent.width
    height: 72
    smooth: false
    property alias textDateTime: textDateTime
    property alias imageDrawerArrow: imageDrawerArrow
    property alias backButton: backButton
    property alias notificationIcons: notificationIcons
    property alias text_printerName: textPrinterName
    property string timeSeconds: "00"
    property string oldSeparatorString: " "
    signal backClicked()
    signal drawerDownClicked()

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Timer {
        id: secondsUpdater
        interval: 100 // 10x per second hides time interval misses better than exactly 1x per second
        repeat: true
        running: true
        onTriggered: {
            timeSeconds = new Date().toLocaleString(Qt.locale(), "ss")
            // 2-on, 2-off hides time interval misses better than 1-on, 1-off
            var newSeparatorString = (((timeSeconds % 4) < 2) ? ":" : " ")
            if (newSeparatorString != oldSeparatorString) {
                oldSeparatorString =  newSeparatorString
                var formatString = "M/d  H" + oldSeparatorString + "mm"
                textDateTime.text = new Date().toLocaleString(Qt.locale(), formatString)
            }
        }
    }

    NotificationIcons {
        id: notificationIcons
        z: 2
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.verticalCenter: parent.verticalCenter
    }

    LinearGradient {
        id: fade
        height: 30
        width: parent.width
        smooth: false
        z: 1
        anchors.top: parent.bottom
        gradient: Gradient {
            GradientStop {
                position: 0
                color: "#FF000000"
            }
            GradientStop {
                position: 1.0
                color: "#00000000"
            }
        }
    }

    Item {
        id: backButton
        width: 150
        height: parent.height
        smooth: false
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 0
        z: 2

        LoggingMouseArea {
            logText: "[<back_button<]"
            id: mouseArea_back
            height: parent.height
            smooth: false
            anchors.leftMargin: -parent.anchors.leftMargin
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left
            onClicked: backClicked()
        }

        Image {
            id: imageBackArrow
            height: sourceSize.height
            width: sourceSize.width
            smooth: false
            anchors.verticalCenterOffset: -1
            anchors.verticalCenter: text_back.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 0
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            fillMode: Image.PreserveAspectFit
            source: currentItem.backIsCancel ||
                    (inFreStep && (typeof currentItem.skipFreStepAction === "function")) ?
                        "qrc:/img/skip.png" :
                        "qrc:/img/back_button.png"
        }

        Text {
            id: text_back
            width: 200
            color: "#a0a0a0"
            text: "    "
            antialiasing: false
            smooth: false
            verticalAlignment: Text.AlignVCenter
            font.family: defaultFont.name
            font.letterSpacing: 3
            font.weight: Font.Light
            font.pixelSize: 22
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: imageBackArrow.right
            anchors.leftMargin: 5
        }
    }

    Text {
        id: textDateTime
        color: "#a0a0a0"
        text: "--/-- --:--"
        antialiasing: false
        smooth: false
        font.capitalization: Font.AllUppercase
        font.family: defaultFont.name
        font.weight: Font.Light
        font.pixelSize: 18
        visible: settings.getShowTimeInTopBar()
        anchors.left: backButton.left
        anchors.leftMargin: 45
        anchors.verticalCenter: parent.verticalCenter
    }

    Flickable {
        id: drawerDownSwipeHandler
        z: 4
        height: parent.height
        anchors.top: parent.top
        anchors.left: backButton.right
        anchors.right: notificationIcons.left
        anchors.bottom: parent.bottom
        flickableDirection: Flickable.VerticalFlick
        onFlickStarted: {
            if (verticalVelocity < 0) drawerDownClicked()
        }
        boundsMovement: Flickable.StopAtBounds
        pressDelay: 0

        // Flickable absorbs touch events and only propagates them to
        // its children which is why the center title area which is clickable
        // (to open the drawers) is a child of the flickable.
        Item {
            id: itemPrinterName
            smooth: false
            z: 1
            anchors.fill: parent

            Text {
                id: textPrinterName
                color: "#a0a0a0"
                text: {
                    switch(bot.process.type) {
                    case ProcessType.Print:
                        switch(bot.process.stateType) {
                        case ProcessStateType.Loading:
                            qsTr("LOADING")
                            break;
                        case ProcessStateType.Printing:
                            qsTr("PRINTING")
                            break;
                        case ProcessStateType.Pausing:
                            qsTr("PAUSING")
                            break;
                        case ProcessStateType.Resuming:
                            qsTr("RESUMING")
                            break;
                        case ProcessStateType.Paused:
                            qsTr("PAUSED")
                            break;
                        case ProcessStateType.Failed:
                            qsTr("FAILED")
                            break;
                        case ProcessStateType.Completed:
                            qsTr("PRINT COMPLETE")
                            break;
                        case ProcessStateType.Cancelled:
                            qsTr("PRINT CANCELLED")
                            break;
                        }
                        break;
                    case ProcessType.Load:
                        switch(bot.process.stateType) {
                        case ProcessStateType.Preheating:
                            qsTr("PREHEATING")
                            break;
                        case ProcessStateType.Extrusion:
                            qsTr("EXTRUDING")
                            break;
                        case ProcessStateType.Stopping:
                        case ProcessStateType.Done:
                            qsTr("MATERIAL LOADED")
                            break;
                        default:
                            qsTr("LOAD MATERIAL")
                            break;
                        }
                        break;
                    case ProcessType.Unload:
                        switch(bot.process.stateType) {
                        case ProcessStateType.Preheating:
                            qsTr("PREHEATING")
                            break;
                        case ProcessStateType.UnloadingFilament:
                            qsTr("UNLOADING MATERIAL")
                            break;
                        case ProcessStateType.Done:
                            qsTr("MATERIAL UNLOADED")
                            break;
                        default:
                            qsTr("UNLOAD MATERIAL")
                            break;
                        }
                        break;
                    default:
                        switch(mainSwipeView.currentIndex) {
                        case MoreporkUI.BasePage:
                            bot.name
                            break;
                        case MoreporkUI.PrintPage:
                            switch(printPage.printSwipeView.currentIndex) {
                            case PrintPage.BasePage:
                            case PrintPage.FileBrowser:
                            case PrintPage.PrintQueueBrowser:
                                qsTr("CHOOSE A FILE")
                                break;
                            case PrintPage.StartPrintConfirm:
                                qsTr("PRINT")
                                break;
                            case PrintPage.FileInfoPage:
                                qsTr("FILE INFORMATION")
                                break;
                            }
                            break;
                        case MoreporkUI.ExtruderPage:
                            switch(extruderPage.extruderSwipeView.currentIndex) {
                            case ExtruderPage.BasePage:
                                qsTr("EXTRUDERS")
                                break;
                            case ExtruderPage.AttachExtruderPage:
                                qsTr("ATTACHING EXTRUDERS")
                                break;
                            default:
                                qsTr("EXTRUDERS")
                                break;
                            }
                            break;
                        case MoreporkUI.SettingsPage:
                            switch(settingsPage.settingsSwipeView.currentIndex) {
                            case SettingsPage.SystemSettingsPage:
                                switch(settingsPage.systemSettingsPage.systemSettingsSwipeView.currentIndex) {
                                case SystemSettingsPage.PrinterInfoPage:
                                    qsTr("%1 INFO").arg(bot.name)
                                    break;
                                case SystemSettingsPage.AdvancedInfoPage:
                                    qsTr("%1 SENSOR INFO").arg(bot.name)
                                    break;
                                case SystemSettingsPage.WifiPage:
                                    switch(settingsPage.wifiPage.wifiSwipeView.currentIndex) {
                                    case WiFiPage.EnterPassword:
                                       var wifiNameRefactor = (qsTr("%1").arg(settingsPage.wifiPage.selectedWifiName))
                                       if(wifiNameRefactor.length > 8) {
                                            wifiNameRefactor= wifiNameRefactor.substr(0,8) + "..."
                                        }
                                        qsTr("%1 - ENTER PASSWORD").arg(wifiNameRefactor)
                                        break;
                                    default:
                                        qsTr("WIFI AND NETWORK")
                                        break;
                                    }
                                    break;
                                case SystemSettingsPage.AuthorizeAccountsPage:
                                    qsTr("AUTHORIZE MAKERBOT ACCOUNT")
                                    break;
                                case SystemSettingsPage.FirmwareUpdatePage:

                                    if(settingsPage.systemSettingsPage.systemSettingsSwipeView.currentItem.firmwareUpdatePage.state == "install_from_usb"
                                        || settingsPage.systemSettingsPage.systemSettingsSwipeView.currentItem.firmwareUpdatePage.state == "select_firmware_file") {
                                           qsTr("FIRMWARE UPDATE - USB")
                                    }
                                    else {
                                        qsTr("FIRMWARE UPDATE")
                                    }
                                    break;
                                case SystemSettingsPage.ShareAnalyticsPage:
                                    qsTr("ANALYTICS")
                                    break;
                                case SystemSettingsPage.ChangePrinterNamePage:
                                    qsTr("CHANGE PRINTER NAME")
                                    break;
                                case SystemSettingsPage.TimePage:
                                    switch(settingsPage.systemSettingsPage.timePage.timeSwipeView.currentIndex) {
                                    case TimePage.BasePage:
                                        qsTr("TIME AND DATE")
                                        break;
                                    case TimePage.SetTimeZone:
                                        qsTr("EDIT TIME ZONE")
                                        break;
                                    case TimePage.SetDate:
                                        qsTr("EDIT DATE")
                                        break;
                                    case TimePage.SetTime:
                                        qsTr("EDIT TIME")
                                        break;
                                    }
                                    break;
                                default:
                                    qsTr("SYSTEM SETTINGS")
                                    break;
                                }
                                break;
                            case SettingsPage.ExtruderSettingsPage:
                                switch(settingsPage.extruderSettingsPage.extruderSettingsSwipeView.currentIndex) {
                                case ExtruderSettingsPage.CalibrateExtrudersPage:
                                    qsTr("CALIBRATE EXTRUDERS")
                                    break;
                                case ExtruderSettingsPage.CleanExtrudersPage:
                                    qsTr("CLEAN EXTRUDERS")
                                    break;
                                default:
                                    qsTr("EXTRUDER SETTINGS")
                                    break;
                                }
                                break;
                            case SettingsPage.BuildPlateSettingsPage:
                                switch(settingsPage.buildPlateSettingsPage.buildPlateSettingsSwipeView.currentIndex) {
                                    case BuildPlateSettingsPage.AssistedLevelingPage:
                                        qsTr("ASSISTED LEVELING")
                                        break;
                                    case BuildPlateSettingsPage.RaiseLowerBuildPlatePage:
                                        qsTr("RAISE/LOWER BUILD PLATE")
                                        break;
                                    default:
                                        qsTr("BUILD PLATE SETTINGS")
                                        break;
                                }
                                break;

                            case SettingsPage.CleanAirSettingsPage:
                                qsTr("CLEAN AIR SETTINGS")
                                break;
                            case SettingsPage.PreheatPage:
                                qsTr("PREHEAT")
                                break;
                            case SettingsPage.DryMaterialPage:
                                qsTr("DRYING CYCLE")
                                break;
                            case SettingsPage.AnnealPrintPage:
                                qsTr("ANNEAL PRINT")
                                break;
                            default:
                                qsTr("SETTINGS")
                                break;
                            }
                            break;
                        case MoreporkUI.InfoPage:
                            qsTr("INFO")
                            break;
                        case MoreporkUI.MaterialPage:
                            switch(materialPage.materialSwipeView.currentIndex) {
                            case MaterialPage.BasePage:
                                qsTr("MATERIAL")
                                break;
                            case MaterialPage.LoadMaterialSettingsPage:
                                switch(materialPage.loadMaterialSettingsPage.selectMaterialSwipeView.currentIndex) {
                                    case LoadMaterialSettings.SelectMaterialPage:
                                    qsTr("CHOOSE BASE MATERIAL")
                                    break;
                                    case LoadMaterialSettings.SelectTemperaturePage:
                                    qsTr("CHOOSE TEMPERATURE")
                                    break;
                                }
                                break;
                            default:
                                qsTr("MATERIAL")
                                break;
                            }
                            break;
                        default:
                            bot.name
                            break;
                        }
                        break;
                    }
                }
                font.capitalization: Font.AllUppercase
                antialiasing: false
                smooth: false
                verticalAlignment: Text.AlignVCenter
                font.family: defaultFont.name
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pixelSize: 22
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -20
                anchors.verticalCenter: parent.verticalCenter
            }

            Image {
                id: imageDrawerArrow
                height: 25
                smooth: false
                anchors.left: textPrinterName.right
                anchors.leftMargin: 10
                anchors.verticalCenter: textPrinterName.verticalCenter
                rotation: -90
                z: 1
                source: "qrc:/img/arrow_19pix.png"
                fillMode: Image.PreserveAspectFit
            }

            LoggingMouseArea {
                logText: "[^TopDrawerDown^]"
                id: mouseAreaTopDrawerDown
                smooth: false
                anchors.fill: parent
                z: 2
                onClicked: drawerDownClicked()
            }
        }
    }
}
