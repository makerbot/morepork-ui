import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Menu {
    id: popupMenu
    x: 0
    y: 0

    background: Rectangle {
        implicitWidth: rootAppWindow.width/2
        implicitHeight: children.height
        color: "#000000"
        border.color: "#ffffff"
        border.width: 2
        radius: 10
    }
}
