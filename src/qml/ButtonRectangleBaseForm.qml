import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Button {
    id: buttonRectangle
    enum Style {
        Button,
        ButtonWithHelp,
        ButtonDisabledHelpEnabled,
        DelayedEnable
    }
    property int style: ButtonRectangleBase.Button

    property int delayedEnableTimeSec: 3
    property int delayedEnableCountdown
    onStyleChanged: {
        delayedEnableTimer.stop()
        enabled = true
        if(style == ButtonRectangleBase.DelayedEnable) {
            enabled = false
            delayedEnableCountdown = delayedEnableTimeSec
            delayedEnableTimer.start()
        }
    }

    Timer {
        id: delayedEnableTimer
        repeat: true
        interval: 1000
        onTriggered: {
            if(delayedEnableCountdown != 0) {
                delayedEnableCountdown -= 1
            } else {
                style = ButtonRectangleBase.Button
                enabled = true
                delayedEnableTimer.stop()
            }
        }
    }

    width: style == ButtonRectangleBase.Button ? 360 : 318
    Layout.preferredWidth: style == ButtonRectangleBase.Button ? 360 : 318
    height: 52
    text: "Button"
    antialiasing: false
    smooth: false
    flat: true

    property string logKey: "ButtonRectangleBase"
    property alias color: backgroundElement.color
    property alias textColor: textElement.color
    property alias border: backgroundElement.border
    property alias help: helpButton

    contentItem: Text {
        id: textElement
        text: buttonRectangle.text
        font.family: "Antenna"
        font.pixelSize: 17
        font.weight: Font.Bold
        font.letterSpacing: 3.2
        font.capitalization: Font.AllUppercase
        lineHeightMode: Text.FixedHeight
        lineHeight: 20
        color: "#000000"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        opacity: !buttonRectangle.enabled ||
                  buttonRectangle.style == ButtonRectangleBase.ButtonDisabledHelpEnabled ? 0.5 : 1

        Behavior on opacity {
            OpacityAnimator {
                duration: 100
            }
        }
    }

    background: Rectangle {
        id: backgroundElement
        implicitWidth: 136
        implicitHeight: 52
        radius: 5
        opacity: !buttonRectangle.enabled ||
                  buttonRectangle.style == ButtonRectangleBase.ButtonDisabledHelpEnabled ? 0.5 : 1

        Behavior on opacity {
            OpacityAnimator {
                duration: 100
            }
        }
    }

    Component.onCompleted: {
        this.onReleased.connect(logClick)
    }

    function logClick() {
        console.info(logKey + " [" + text + "] clicked")
    }

    Button {
        id: helpButton
        width: 32
        Layout.preferredWidth: 32
        height: 52
        anchors.left: parent.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        antialiasing: false
        smooth: false
        flat: true
        visible: buttonRectangle.style == ButtonRectangleBase.ButtonWithHelp ||
                 buttonRectangle.style == ButtonRectangleBase.ButtonDisabledHelpEnabled

        contentItem: Item {
            Image {
                source: "qrc:/img/button_help.png"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                Behavior on opacity {
                    OpacityAnimator {
                        duration: 100
                    }
                }
            }
        }

        background: Rectangle {
            id: backgroundElement1
            color: "#00000000"
            radius: 5

            Behavior on opacity {
                OpacityAnimator {
                    duration: 100
                }
            }
        }

        Component.onCompleted: {
            this.onReleased.connect(logClick)
        }

        function logClick() {
            console.info(logKey + " Help clicked")
        }
    }

    TextBody {
        id: disabledCountdown
        text: {
            ":" + (delayedEnableCountdown.toString().length == 1 ?
                  "0" + delayedEnableCountdown : delayedEnableCountdown)
        }
        style: TextBody.Large
        font.weight: Font.Bold
        anchors.left: parent.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        visible: buttonRectangle.style == ButtonRectangleBase.DelayedEnable
    }
}
