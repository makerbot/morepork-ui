import QtQuick 2.12

Item {
    property string itemName: "Default"
    onStateChanged: {
        console.info("Item", itemName, "changed state to", state)
    }
}
