import QtQuick 2.12

MouseArea {
    height: topBar.height
    smooth: false
    anchors.right: parent.right
    anchors.rightMargin: 0
    anchors.left: parent.left
    anchors.leftMargin: 0

    onClicked: {
        console.info("TopDrawerUp clicked")
        activeDrawer.close()
    }
}
