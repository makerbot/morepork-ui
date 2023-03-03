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
    property int barHeight: 72
    height: topFadeIn.height
    width: parent.width
    smooth: false
    property alias textDateTime: textDateTime
    property alias imageDrawerArrow: imageDrawerArrow
    property alias backButton: backButton
    property alias notificationIcons: notificationIcons
    property alias dateTimeText: dateTimeText
    property alias textNameStatus: textNameStatus
    property string timeSeconds: "00"
    property string oldSeparatorString: " "
    signal backClicked()
    signal drawerDownClicked()

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
                var formatString = "M/d\nH" + oldSeparatorString + "mm"
                textDateTime.text = new Date().toLocaleString(Qt.locale(), formatString)
            }
        }
    }

    NotificationIcons {
        id: notificationIcons
        z: 2
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.top: parent.top
        height: barHeight
    }

    LinearGradient {
        id: topFadeIn
        height: 102
        // width: parent.width
        smooth: false
        cached: true
        z: 1
        anchors.fill: parent
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
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -49
            fillMode: Image.PreserveAspectFit
            source: currentItem.backIsCancel ||
                    (inFreStep && (typeof currentItem.skipFreStepAction === "function")) ?
                        "qrc:/img/skip.png" :
                        "qrc:/img/back_button.png"
        }

        TextBody {
            style: TextBody.Light
            id: text_back
            width: 200
            color: "#a0a0a0"
            text: "    "
            antialiasing: false
            smooth: false
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: imageBackArrow.right
            anchors.leftMargin: 5
        }
    }

    Item {
        id: dateTimeText
        z: 3
        anchors.leftMargin: 48
        anchors.left: backButton.left
        anchors.top: parent.top
        height: barHeight
        width: 100
        smooth: false
        visible: settings.getDateTimeTextEnabled()

        TextHeadline {
            style: TextHeadline.Base
            font.weight: Font.Thin
            font.pixelSize: 17
            id: textDateTime
            color: "#a0a0a0"
            text: "--/--\n--:--"
            antialiasing: false
            smooth: false
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignLeft
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 17
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 5
            lineHeight: 29
        }
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

            TextHeadline {
                style: TextHeadline.Base
                font.weight: Font.Thin
                font.pixelSize: 17
                id: textNameStatus
                antialiasing: false
                smooth: false
                verticalAlignment: Text.AlignTop
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -22
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -26
                text: {
                    var status_text = "IDLE"
                    switch(bot.process.type) {
                    case ProcessType.Print:
                        switch(bot.process.stateType) {
                        case ProcessStateType.Loading:
                            status_text = qsTr("LOADING")
                            break;
                        case ProcessStateType.Printing:
                            status_text = qsTr("PRINTING")
                            break;
                        case ProcessStateType.Pausing:
                            status_text = qsTr("PAUSING")
                            break;
                        case ProcessStateType.Resuming:
                            status_text = qsTr("RESUMING")
                            break;
                        case ProcessStateType.Paused:
                            status_text = qsTr("PAUSED")
                            break;
                        case ProcessStateType.Failed:
                            status_text = qsTr("FAILED")
                            break;
                        case ProcessStateType.Completed:
                            status_text = qsTr("PRINT COMPLETE")
                            break;
                        case ProcessStateType.Cancelled:
                            status_text = qsTr("PRINT CANCELLED")
                            break;
                        }
                    break;
                    case ProcessType.Load:
                        switch(bot.process.stateType) {
                        case ProcessStateType.Preheating:
                            status_text = qsTr("PREHEATING")
                            break;
                        case ProcessStateType.Extrusion:
                            status_text = qsTr("EXTRUDING")
                            break;
                        case ProcessStateType.Stopping:
                        case ProcessStateType.Done:
                            status_text = qsTr("MATERIAL LOADED")
                            break;
                        default:
                            status_text = qsTr("LOAD MATERIAL")
                            break;
                        }
                        break;
                    case ProcessType.Unload:
                        switch(bot.process.stateType) {
                        case ProcessStateType.Preheating:
                            status_text = qsTr("PREHEATING")
                            break;
                        case ProcessStateType.UnloadingFilament:
                            status_text = qsTr("UNLOADING MATERIAL")
                            break;
                        case ProcessStateType.Done:
                            status_text = qsTr("MATERIAL UNLOADED")
                            break;
                        default:
                            status_text = qsTr("UNLOAD MATERIAL")
                            break;
                        }
                        break;
                    default:
                        status_text = qsTr("IDLE")
                        break;
                    }
                    qsTr("%1 - %2").arg(bot.name).arg(status_text)
                }
            }

            TextHeadline {
                style: TextHeadline.Base
                font.pixelSize: 17
                id: textTitle
                antialiasing: false
                smooth: false
                verticalAlignment: Text.AlignBottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -22
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -4
                text: {
                    if (
                        (currentItem.topBarTitle == qsTr("Choose a File")) &
                        (bot.process.type == ProcessType.Print)) {
                        qsTr("Print")
                    }
                    else {
                      currentItem.topBarTitle
                    }
                }
            }

            Image {
                id: imageDrawerArrow
                height: 25
                smooth: false
                anchors.left: textNameStatus.right
                anchors.leftMargin: 10
                anchors.verticalCenter: textNameStatus.verticalCenter
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
