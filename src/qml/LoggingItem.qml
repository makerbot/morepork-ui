import QtQuick 2.12
import MachineTypeEnum 1.0

Item {
    smooth: false
    antialiasing: false
    width: 800
    height: 408
    property string itemName: "Default"
    onStateChanged: {
        console.info("Item", itemName, "changed state to", state)
    }

    property alias backgroundColor: background.color
    Rectangle {
        id: background
        anchors.fill: parent
        color: "#000000"
    }

    // String that goes before the image name
    property string imagePrefixString: {
        if (bot.machineType == MachineType.Fire) {
            "method_"
        } else if (bot.machineType == MachineType.Lava) {
            "method_"
        } else if (bot.machineType == MachineType.Magma) {
            "methodxl_"
        } else {
            emptyString
        }
    }

    function getImageForPrinter(name) {
        return imagePrefixString+name

    }
}
