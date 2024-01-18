import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

ListView {
    id: listSelector
    smooth: false
    anchors.fill: parent
    boundsBehavior: Flickable.DragOverBounds
    spacing: 0
    orientation: ListView.Vertical
    flickableDirection: Flickable.VerticalFlick
    ScrollBar.vertical: ScrollBar {}
}
