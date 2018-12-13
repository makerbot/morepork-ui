import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Switch {
    id: slidingSwitch

    indicator: Rectangle {
            implicitWidth: 68
            implicitHeight: 35
            x: slidingSwitch.leftPadding
            y: parent.height / 2 - height / 2
            radius: 17
            color: slidingSwitch.checked ? "#3183af" : "#ffffff"
            border.color: slidingSwitch.checked ? "#3183af" : "#cccccc"

            Rectangle {
                x: slidingSwitch.checked ? parent.width - width - 3 : 3
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: 16
                color: slidingSwitch.down ? "#cccccc" : "#ffffff"
                border.color: slidingSwitch.checked ? "#3183af" : "#999999"
            }
        }

}
