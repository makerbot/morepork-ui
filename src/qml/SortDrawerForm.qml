import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.9

CustomDrawer {
    objectName: "sortDrawer"
    property string topBarTitle: qsTr("Sort By")
    property alias buttonSortAZ: buttonSortAZ
    property alias buttonSortDateAdded: buttonSortDateAdded
    property alias buttonSortPrintTime: buttonSortPrintTime

    Column {
        id: column
        width: parent.width
        height: children.height
        smooth: false
        spacing: 0
        rotation: rootItem.rotation
        anchors.top: parent.top
        anchors.topMargin: 70

        DrawerButton {
            id: buttonSortAZ
            buttonText: qsTr("A-Z")
            buttonImage: ""
        }

        DrawerButton {
            id: buttonSortDateAdded
            buttonText: qsTr("DATE ADDED")
            buttonImage: "qrc:/img/drawer_current_selection.png"
        }

        DrawerButton {
            id: buttonSortPrintTime
            buttonText: qsTr("PRINT TIME")
            buttonImage: ""
        }

        Rectangle {
            id: emptyItem
            width: parent.width
            height: 120
            color: "#000000"
        }
    }
}
