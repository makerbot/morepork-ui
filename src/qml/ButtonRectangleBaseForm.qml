import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Button {
    enum Style {
        Button,
        ButtonWithHelp
    }
    property int style: ButtonRectangleBase.Button

    id: control
    width: style == ButtonRectangleBase.ButtonWithHelp ? 318 : 360
    Layout.preferredWidth: style == ButtonRectangleBase.ButtonWithHelp ? 318 : 360
    height: 52
    text: qsTr("Button")
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
        text: control.text
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
        opacity: control.enabled ? 1 : 0.5

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
        opacity: control.enabled ? 1 : 0.5

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
        console.info(logKey + " " + text + " clicked")
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
        visible: style == ButtonRectangleBase.ButtonWithHelp

        contentItem: Item {
            Image {
                source: "qrc:/img/button_help.png"
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: control.enabled ? 1 : 0.5

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
            opacity: control.enabled ? 1 : 0.5

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
}
