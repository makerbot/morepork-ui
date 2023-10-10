import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.9

CustomDrawer {
    objectName: "materialPageDrawer"
    property string topBarTitle: qsTr("Manage Material Loading")
    property alias buttonCancelMaterialChange: buttonCancelMaterialChange

    Column {
        id: column
        width: parent.width
        height: children.height
        smooth: false
        spacing: 0
        rotation: rootItem.rotation

        CloseDrawerItem {}

        DrawerButton {
            id: buttonCancelMaterialChange
            buttonText: qsTr("CANCEL MATERIAL CHANGE")
            buttonImage: "qrc:/img/drawer_cancel.png"
        }

        Rectangle {
            id: emptyItem
            width: parent.width
            height: 320
            color: "#000000"
        }
    }
}
