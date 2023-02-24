import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Button {
    id: control
    width: 55
    height: 52
    antialiasing: true
    flat: true

    property string logKey: "ButtonOptions"
    property bool was_pressed: false
    property var text_color: enabled ? (was_pressed ? "#000000" : "#FFFFFF") : "#555555"

    // Divider
    Rectangle {
        id: dividerRectangle
        width: 2
        height: 40
        color: text_color
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin:  8
        antialiasing: false
        smooth: false
    }

    // Meatballs
    RowLayout {
        width: children.width
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: dividerRectangle.right
        anchors.leftMargin:  10
        anchors.right: parent.right
        anchors.rightMargin: 13
        spacing: 5

        Rectangle {
            width: 4
            height: 4
            color: text_color
            radius: width / 2
            antialiasing: false
            smooth: false
        }
        Rectangle {
            width: 4
            height:4
            color: text_color
            radius: width / 2
            antialiasing: false
            smooth: false
        }
        Rectangle {
            width: 4
            height: 4
            color: text_color
            radius: width / 2
            antialiasing: false
            smooth: false
        }
    }

    background: Rectangle {
        id: backgroundElement
        width: parent.width
        height: parent.height
        radius: 5
        opacity: control.enabled ? 1 : 0.5
        color: (was_pressed ? "#FFFFFF" : "transparent")
        border.width: 0


        Behavior on opacity {
            OpacityAnimator {
                duration: 100
            }
        }
    }

    Component.onCompleted: {
        this.onClicked.connect(logClick)
    }

    function logClick() {
        console.info(logKey + " " + text + " clicked")
    }
}
