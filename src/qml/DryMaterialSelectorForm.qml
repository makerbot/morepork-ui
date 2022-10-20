import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import MachineTypeEnum 1.0

ListView {
    id: materialsList
    smooth: false
    anchors.fill: parent
    boundsBehavior: Flickable.DragOverBounds
    spacing: 1
    orientation: ListView.Vertical
    flickableDirection: Flickable.VerticalFlick
    ScrollBar.vertical: ScrollBar {}

    model: {
        if(bot.machineType == MachineType.Fire) {
            dryingMaterialsListMethod
        } else if(bot.machineType == MachineType.Lava) {
            dryingMaterialsListMethodX
        } else if(bot.machineType == MachineType.Magma) {
            dryingMaterialsListMethodX
        } else {
            []
        }
    }

    delegate:
        DryMaterialButton {
        id: materialButton
        enabled: model.modelData["temperature"] != 0
        opacity: model.modelData["temperature"] != 0 ? 1 : 0.3
        materialNameText: model.modelData["label"]
        temperatureAndTimeText: {
            if (model.modelData["temperature"] != 0)
                model.modelData["temperature"] + "°C for " + model.modelData["time"] + " hours"
            else
                "Not available, this material can be damaged by drying."
        }
        smooth: false
        antialiasing: false
        onClicked: {
            bot.startDrying(parseInt(model.modelData["temperature"], 10), model.modelData["time"])
        }
    }
}
