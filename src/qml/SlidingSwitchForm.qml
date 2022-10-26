import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Switch {
    id: slidingSwitch
    property alias switchText: switchText.text
    property bool showText: false

    indicator: Rectangle {
            id: switchElement
            implicitWidth: 70
            implicitHeight: 32
            x: slidingSwitch.leftPadding
            y: parent.height / 2 - height / 2
            radius: 16
            color: slidingSwitch.checked ? "#569BC1" : "#666666"
            border.width: 0
            opacity: enabled ? 1 : 0.3

            Rectangle {
                x: slidingSwitch.checked ? parent.width - width - 3 : 3
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: width
                radius: width/2
                color: "#ffffff"
                border.width: 0
            }
        }

    TextBody {
        id: switchText
        font.weight: Font.Bold
        color: slidingSwitch.checked ? "#ffffff" : "#999999"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: switchElement.right
        anchors.leftMargin: 16
        visible: showText
    }
}
