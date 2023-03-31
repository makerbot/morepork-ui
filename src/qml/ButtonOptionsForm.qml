import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ButtonRectangleBase {
    width: 55
    height: 52
    logKey: "ButtonOptions"
    color:(was_pressed ? "#FFFFFF" : "transparent")
    border.width: 0
    opacity: control.enabled ? 1 : 0.5

    property bool was_pressed: false
    property var text_color: enabled ? (was_pressed ? "#000000" : "#FFFFFF") : "#555555"

    contentItem: Item {
        anchors.fill: parent.fill
        antialiasing: false
        smooth: false

        // Divider
        Rectangle {
            id: dividerRectangle
            width: 2
            height: 40
            color: text_color
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
            }
            Rectangle {
                width: 4
                height:4
                color: text_color
                radius: width / 2
            }
            Rectangle {
                width: 4
                height: 4
                color: text_color
                radius: width / 2
            }
        }
    }
}
