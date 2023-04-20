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
    property alias textNameStatusTitle: textNameStatusTitle
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

        TextBody {
            id: text_back
            style: TextBody.Base
            width: 200
            text: "    "
            antialiasing: false
            smooth: false
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: imageBackArrow.right
            anchors.leftMargin: 5
        }
    }

    TextBody {
        id: textDateTime
        style: TextBody.Base
        text: "--/-- --:--"
        antialiasing: false
        smooth: false
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
            id: itemNameStatusTitle
            smooth: false
            z: 1
            anchors.fill: parent

            TextHeadline {
                id: textNameStatusTitle
                style: TextHeadline.Base
                text: {
                    var status_text = qsTr("IDLE")
                    var processed_title = currentItem.topBarTitle
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
                    if ((currentItem.topBarTitle == qsTr("Select Source")) &&
                        (bot.process.type == ProcessType.Print)) {
                        processed_title = qsTr("Print")
                    }
                    else {
                        processed_title = currentItem.topBarTitle
                    }
                    if (status_text == qsTr("IDLE")) {
                        qsTr("%1 - %2").arg(bot.name).arg(processed_title)
                    } else {
                        qsTr("%1 - %2").arg(bot.name).arg(status_text)
                    }
                }
                antialiasing: false
                smooth: false
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -20
                anchors.verticalCenter: parent.verticalCenter
            }

            Image {
                id: imageDrawerArrow
                height: 25
                smooth: false
                anchors.left: textNameStatusTitle.right
                anchors.leftMargin: 10
                anchors.verticalCenter: textNameStatusTitle.verticalCenter
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
