import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12

Flickable {
    id: flickableMenu
    anchors.fill: parent
    smooth: false
    antialiasing: false
    flickableDirection: Flickable.VerticalFlick
    interactive: contentHeight > height
    ScrollBar.vertical: ScrollBar {}
    flickDeceleration: 1000
}
