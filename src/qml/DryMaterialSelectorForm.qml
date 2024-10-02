import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import MachineTypeEnum 1.0

ListView {
    property bool annealMaterial: false

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
        if (annealMaterial) {
            annealMaterialsList
        } else if(bot.machineType == MachineType.Fire) {
            dryingMaterialsListMethod
        } else if(bot.machineType == MachineType.Lava) {
            dryingMaterialsListMethodX
        } else if(bot.machineType == MachineType.Magma) {
            dryingMaterialsListMethodXL
        } else {
            []
        }
    }

    header:
        DryMaterialButton {
            id: customMaterialButton
            property int time: bot.machineType == MachineType.Magma ? 16 : 24
            materialNameText: qsTr("ENTER CUSTOM TEMPERATURE")
            temperatureAndTimeText: qsTr("Chamber will heat for %1 hours").arg(time)
            enabled: !annealMaterial
            opacity: 1
            onClicked: {
                customMaterialTemperature.customTime = time
                dryMaterial.state = "custom_material"
            }
            smooth: false
            antialiasing: false
            visible: !annealMaterial
            height: {
                if (annealMaterial) {
                    0
                } else {
                    80
                }
            }
        }

    delegate:
        DryMaterialButton {
        id: materialButton
        enabled: model.modelData["temperature"] != 0
        opacity: model.modelData["temperature"] != 0 ? 1 : 0.3
        materialNameText: model.modelData["label"]
        temperatureAndTimeText: {
            if (model.modelData["temperature"] != 0) {
                qsTr("%1°C for %2 hours").arg(model.modelData["temperature"]).arg(model.modelData["time"])
            } else {
               qsTr("Not available, this material can be damaged by drying.")
            }
        }
        smooth: false
        antialiasing: false
        onClicked: {
            bot.startDrying(parseInt(model.modelData["temperature"], 10), model.modelData["time"])
        }
    }
}

