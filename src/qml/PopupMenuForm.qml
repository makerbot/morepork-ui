import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Menu {
    id: popupMenu
    x: 0
    y: 0
    height: children.height
    width: rootAppWindow.width/2

    background: Rectangle {
        color: "#000000"
        border.color: "#ffffff"
        border.width: 2
        radius: 10
    }
}
