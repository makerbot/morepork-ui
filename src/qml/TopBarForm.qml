import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    id: itemTopBarForm
    property alias itemTopBarForm: itemTopBarForm
    // You will always want to reference pages off barHeight or
    // topFadeIn.height depending on what you are doing.
    property int barHeight: 40
    height: topFadeIn.height
    smooth: false
    property alias topFadeIn: topFadeIn
    property alias imageDrawerArrow: imageDrawerArrow
    property alias backButton: backButton
    property alias notificationIcons: notificationIcons
    property alias text_printerName: textPrinterName
    signal backClicked()
    signal drawerDownClicked()

    Item {
        id: itemNotificationIcons
        width: 100
        height: 40
        smooth: false
        z: 2
        anchors.right: parent.right
        anchors.rightMargin: 3

        NotificationIcons {
            id: notificationIcons
            anchors.fill: parent
        }
    }

    LinearGradient {
        id: topFadeIn
        height: 60
        smooth: false
        cached: true
        z: 1
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        gradient: Gradient {
            GradientStop {
                position: 0.6
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
        height: barHeight
        smooth: false
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 0
        z: 2

        MouseArea {
            id: mouseArea_back
            height: topFadeIn.height
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
            source: (inFreStep && (typeof currentItem.skipFreStepAction === "function")) ?
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

    Item {
        id: itemPrinterName
        height: barHeight
        smooth: false
        z: 1
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left

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
                    case 0:
                        bot.name
                        break;
                    case 1:
                        switch(printPage.printSwipeView.currentIndex) {
                        case 0:
                        case 1:
                            qsTr("CHOOSE A FILE")
                            break;
                        case 2:
                            qsTr("PRINT")
                            break;
                        case 3:
                            qsTr("FILE INFORMATION")
                            break;
                        }
                        break;
                    case 2:
                        switch(extruderPage.extruderSwipeView.currentIndex) {
                        case 0:
                            qsTr("EXTRUDERS")
                            break;
                        case 1:
                            qsTr("ATTACHING EXTRUDERS")
                            break;
                        default:
                            qsTr("EXTRUDERS")
                            break;
                        }
                        break;
                    case 3:
                        switch(settingsPage.settingsSwipeView.currentIndex) {
                        case 1:
                            qsTr("%1 INFO").arg(bot.name)
                            break;
                        case 2:
                            qsTr("CHANGE PRINTER NAME")
                            break;
                        case 3:
                            qsTr("CHOOSE WIFI NETWORK")
                            break;
                        case 4:
                            qsTr("AUTHORIZE MAKERBOT ACCOUNT")
                            break;
                        case 5:
                            qsTr("SOFTWARE UPDATE")
                            break;
                        case 6:
                            qsTr("CALIBRATE EXTRUDERS")
                            break;
                        case 7:
                            switch(settingsPage.timePage.timeSwipeView.currentIndex) {
                            case 0:
                                qsTr("ENTER TODAY'S DATE")
                                break;
                            case 1:
                                qsTr("SET TIME ZONE")
                                break;
                            case 2:
                                qsTr("SET CURRENT TIME")
                                break;
                            }
                            break;
                        case 8:
                            switch(settingsPage.advancedSettingsPage.advancedSettingsSwipeView.currentIndex) {
                            case 1:
                                qsTr("%1 SENSOR INFO").arg(bot.name)
                                break;
                            case 2:
                                qsTr("PREHEAT")
                                break;
                            case 3:
                                qsTr("ASSISTED LEVELING")
                                break;
                            case 6:
                                qsTr("RAISE/LOWER BUILD PLATE")
                                break;
                            case 7:
                                qsTr("ANALYTICS")
                                break;
                            case 8:
                                qsTr("DRYING CYCLE")
                                break;
                            case 9:
                                qsTr("CLEAN EXTRUDERS")
                                break;
                            default:
                                qsTr("ADVANCED")
                                break;
                            }
                            break;
                        default:
                            qsTr("SETTINGS")
                            break;
                        }
                        break;
                    case 4:
                        qsTr("INFO")
                        break;
                    case 5:
                        switch(materialPage.materialSwipeView.currentIndex) {
                        case 0:
                            qsTr("MATERIAL")
                            break;
                        case 1:
                            switch(materialPage.expExtruderSettingsPage.selectMaterialSwipeView.currentIndex) {
                                case 0:
                                qsTr("CHOOSE BASE MATERIAL")
                                break;
                                case 1:
                                qsTr("CHOOSE TEMPERATURE")
                                break;
                            }
                            break;
                        default:
                            qsTr("MATERIAL")
                            break;
                        }
                        break;
                    case 6:
                        // This bit is repeated from above, but making it a function
                        // returning a string doesn't seem to be updating the title
                        // dynamically when the advanced page is reached through the
                        // settings page.
                        switch(advancedPage.advancedSettingsSwipeView.currentIndex) {
                        case 1:
                            qsTr("%1 SENSOR INFO").arg(bot.name)
                            break;
                        case 2:
                            qsTr("PREHEAT")
                            break;
                        case 3:
                            qsTr("ASSISTED LEVELING")
                            break;
                        case 6:
                            qsTr("RAISE/LOWER BUILD PLATE")
                            break;
                        case 7:
                            qsTr("ANALYTICS")
                            break;
                        case 8:
                            qsTr("DRYING CYCLE")
                            break;
                        case 9:
                            qsTr("CLEAN EXTRUDERS")
                            break;
                        default:
                            qsTr("ADVANCED")
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
            anchors.verticalCenter: parent.verticalCenter
        }

        Image {
            id: imageDrawerArrow
            y: 227
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

        MouseArea {
            id: mouseAreaTopDrawerDown
            x: 301
            y: 40
            width: 40
            height: 60
            smooth: false
            anchors.fill: parent
            z: 2
            onClicked: drawerDownClicked()
        }
    }
}
