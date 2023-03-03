import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Button {
    id: control
    width: 360
    Layout.preferredWidth: 360
    height: 52
    text: qsTr("Button")
    antialiasing: true
    flat: true

    property string logKey: "ButtonRectangleBase"
    property alias color: backgroundElement.color
    property alias textColor: textElement.color
    property alias border: backgroundElement.border

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
}
