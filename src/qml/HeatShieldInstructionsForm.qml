import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ExtruderTypeEnum 1.0

LoggingItem {
    itemName: "HeatShieldInstructions"
    property bool heatShieldWarningAcknowledged: false
    property bool extruderAttached: bot.extruderAPresent
    property int lastAttachedExtruder: ExtruderType.None
    property bool lastExtruderValid: false
    property string timeRemaining
    property var endTime: new Date()
    anchors.fill: parent
    visible: !heatShieldWarningAcknowledged &&
             lastAttachedExtruder == ExtruderType.MK14_HOT_E &&
             lastExtruderValid

    onExtruderAttachedChanged: {
        if (extruderAttached) {
            if(bot.extruderAType != ExtruderType.NONE) {
                coolDownTimer.stop()
                lastAttachedExtruder = bot.extruderAType
                lastExtruderValid = extruderAToolTypeCorrect
                if(bot.extruderAType == ExtruderType.MK14_HOT_E &&
                   lastExtruderValid) {
                    state = "install_heat_shield"
                    heatShieldWarningAcknowledged = false
                }
            }
        } else if(!extruderAttached) {
            if(lastAttachedExtruder == ExtruderType.MK14_HOT_E) {
                state = "remove_heat_shield"
                heatShieldWarningAcknowledged = false
                startCountdown()
            }
        }
    }

    function startCountdown() {
        var t = new Date()
        t.setMinutes(t.getMinutes() + 15)
        endTime = t
        coolDownTimer.start()
    }

    Timer {
        id: coolDownTimer
        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            if (endTime > now) {
                var dt = new Date(endTime - now)
                var s = dt.getSeconds()
                timeRemaining = dt.getMinutes() + ":" + (s > 10 ? s : "0" + s)
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        LoggingMouseArea {
            logText: "heatShieldWarningAcknowledged [?MouseArea?]"
            anchors.fill: parent
            preventStealing: true
        }
    }

    AnimatedImage {
        id: extruder_image
        width: sourceSize.width
        height: sourceSize.height
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/install_heat_shield.gif"
        playing: parent.visible
        cache: false
        smooth: false
        antialiasing: false
    }

    Image {
        id: alert_icon
        width: sourceSize.width/4
        height: sourceSize.height/4
        source: "qrc:/img/error.png"
        anchors.top: containerItem.top
        anchors.topMargin: 62
        anchors.right: containerItem.left
        anchors.rightMargin: 20
        visible: false
    }

    ColumnLayout {
        id: containerItem
        width: 380
        height: children.height
        anchors.verticalCenterOffset: -10
        anchors.left: parent.left
        anchors.leftMargin: 400
        anchors.verticalCenter: parent.verticalCenter
        spacing: 20

        Text {
            id: element
            color: "#ffffff"
            text: qsTr("INSTALL HEAT SHIELD")
            font.letterSpacing: 2
            font.family: defaultFont.name
            font.weight: Font.Bold
            font.pixelSize: 22
            lineHeight: 1.3
        }

        Text {
            id: element1
            color: "#ffffff"
            text: qsTr("Warning: LABS 1 HT Experimental Extruder recognized.\n\n" +
                       "Make sure the heat shield is installed before using this extruder.")
            wrapMode: Text.WordWrap
            font.letterSpacing: 1
            font.family: defaultFont.name
            font.weight: Font.Light
            font.pixelSize: 18
            lineHeight: 1.3
            Layout.preferredWidth: parent.width
        }

        RoundedButton {
            id: continueButton
            label_width: 175
            buttonWidth: 175
            label: qsTr("CONFIRM")
            buttonHeight: 50
            button_mouseArea.onClicked: {
                heatShieldWarningAcknowledged = true
            }
        }
    }

    states: [
        State {
            name: "install_heat_shield"
            PropertyChanges {
                target: extruder_image
                source: "qrc:/img/install_heat_shield.gif"
            }
        },

        State {
            name: "remove_heat_shield"
            PropertyChanges {
                target: extruder_image
                source: "qrc:/img/remove_heat_shield.gif"
            }

            PropertyChanges {
                target: element
                text: qsTr("REMOVE HEAT SHIELD")
            }

            PropertyChanges {
                target: element1
                text: {
                    (bot.extruderACurrentTemp > 50 ?
                        qsTr("Please wait <b>%1</b> minutes for the heat shield to cool down.<br><br>").arg(timeRemaining) :
                        "") +
                     qsTr("Make sure to remove the heat shield before using a different " +
                          "extruder. Flex the tabs to remove.")
                }
            }

            PropertyChanges {
                target: alert_icon
                visible: bot.extruderACurrentTemp > 50
            }
        }
    ]
}
