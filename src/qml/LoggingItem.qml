import QtQuick 2.12

Item {
    width: 800
    height: 408
    property string itemName: "Default"
    onStateChanged: {
        console.info("Item", itemName, "changed state to", state)
    }
}
