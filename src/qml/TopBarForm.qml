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
        anchors.leftMargin: 20
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
            height: 25
            smooth: false
            anchors.verticalCenterOffset: -1
            anchors.verticalCenter: text_back.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 0
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            fillMode: Image.PreserveAspectFit
            source: (inFreStep && (typeof currentItem.skipFreStepAction === "function")) ?
                        "qrc:/img/skip.png" :
                        "qrc:/img/arrow_19pix.png"
        }

        Text {
            id: text_back
            width: 200
            color: "#a0a0a0"
            text: "    "
            antialiasing: false
            smooth: false
            verticalAlignment: Text.AlignVCenter
            font.family: "Antenna"
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
                        "LOADING"
                        break;
                    case ProcessStateType.Printing:
                        "PRINTING"
                        break;
                    case ProcessStateType.Pausing:
                        "PAUSING"
                        break;
                    case ProcessStateType.Resuming:
                        "RESUMING"
                        break;
                    case ProcessStateType.Paused:
                        "PAUSED"
                        break;
                    case ProcessStateType.Failed:
                        "FAILED"
                        break;
                    case ProcessStateType.Completed:
                        "PRINT COMPLETE"
                        break;
                    }
                    break;
                case ProcessType.Load:
                    switch(bot.process.stateType) {
                    case ProcessStateType.Preheating:
                        "PREHEATING"
                        break;
                    case ProcessStateType.Extrusion:
                        "EXTRUDING"
                        break;
                    case ProcessStateType.Stopping:
                    case ProcessStateType.Done:
                        "MATERIAL LOADED"
                        break;
                    default:
                        "LOAD MATERIAL"
                        break;
                    }
                    break;
                case ProcessType.Unload:
                    switch(bot.process.stateType) {
                    case ProcessStateType.Preheating:
                        "PREHEATING"
                        break;
                    case ProcessStateType.UnloadingFilament:
                        "UNLOADING MATERIAL"
                        break;
                    case ProcessStateType.Done:
                        "MATERIAL UNLOADED"
                        break;
                    default:
                        "UNLOAD MATERIAL"
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
                            "CHOOSE A FILE"
                            break;
                        case 2:
                            "PRINT"
                            break;
                        case 3:
                            "FILE INFORMATION"
                            break;
                        }
                        break;
                    case 2:
                        switch(extruderPage.extruderSwipeView.currentIndex) {
                        case 0:
                            "EXTRUDERS"
                            break;
                        case 1:
                            "ATTACHING EXTRUDERS"
                            break;
                        default:
                            "EXTRUDERS"
                            break;
                        }
                        break;
                    case 3:
                        switch(settingsPage.settingsSwipeView.currentIndex) {
                        case 2:
                            "ASSISTED LEVELING"
                            break;
                        case 4:
                            "CALIBRATION"
                            break;
                        case 5:
                            "CHOOSE WIFI NETWORK"
                            break;
                        case 6:
                            bot.name + " ADVANCED INFO"
                            break;
                        case 7:
                            "SIGN-IN TO MAKERBOT ACCOUNT"
                            break;
                        case 10:
                            "PRINTER NAME"
                            break;
                        default:
                            "SETTINGS"
                            break;
                        }
                        break;
                    case 4:
                        "INFO"
                        break;
                    case 5:
                        "MATERIAL"
                        break;
                    case 6:
                        "PREHEAT"
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
            font.family: "Antenna"
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
