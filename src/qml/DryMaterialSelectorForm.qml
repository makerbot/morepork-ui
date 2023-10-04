import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import MachineTypeEnum 1.0

ListView {
    id: materialsList
    smooth: false
    anchors.fill: parent
    anchors.topMargin: 10
    boundsBehavior: Flickable.DragOverBounds
    spacing: 1
    clip: true
    orientation: ListView.Vertical
    flickableDirection: Flickable.VerticalFlick
    ScrollBar.vertical: ScrollBar {}

    model: {
        if(bot.machineType == MachineType.Fire) {
            dryingMaterialsListMethod
        } else if(bot.machineType == MachineType.Lava) {
            dryingMaterialsListMethodX
        } else if(bot.machineType == MachineType.Magma) {
            dryingMaterialsListMethodXL
        } else {
            []
        }
    }

    delegate:
        DryMaterialButton {
        id: materialButton
        enabled: model.modelData["temperature"] != 0 || model.modelData["custom"]
        opacity: model.modelData["temperature"] != 0 ? 1 : (model.modelData["custom"] ? 1 : 0.3)
        materialNameText: model.modelData["label"]
        temperatureAndTimeText: {
            if (model.modelData["temperature"] != 0)
                qsTr("%1°C for %2 hours").arg(model.modelData["temperature"]).arg(model.modelData["time"])
            else if(model.modelData["custom"]) {
                qsTr("Chamber will heat for %1 hours").arg(model.modelData["time"])
            }
            else
               qsTr("Not available, this material can be damaged by drying.")
        }
        smooth: false
        antialiasing: false
        onClicked: {
            if(model.modelData["custom"]) {
                customMaterialTemperature.customTime = model.modelData["time"]
                dryMaterial.state = "custom_material"
            }
            else {
                bot.startDrying(parseInt(model.modelData["temperature"], 10), model.modelData["time"])
            }
        }
    }
}
