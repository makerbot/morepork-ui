import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import MachineTypeEnum 1.0

ColumnLayout {
    width: 360
    spacing: 20

    enum Extruder {
        Model,
        Support,
        BuildplaneCool,
        HBPCool,
        Both
    }

    property int showExtruder: TemperatureStatus.Extruder.Both
    property alias modelExtruder: modelExtruder
    property alias supportExtruder: supportExtruder
    property alias buildplaneCool: buildplaneCool
    property alias hbpCool: hbpCool

    TemperatureStatusElement {
        id: modelExtruder
        extruderIdx: TemperatureStatus.Extruder.Model
        visible: {
            showExtruder == TemperatureStatus.Extruder.Model ||
            showExtruder == TemperatureStatus.Extruder.Both
        }
    }

    TemperatureStatusElement {
        id: supportExtruder
        extruderIdx: TemperatureStatus.Extruder.Support
        visible: {
            showExtruder == TemperatureStatus.Extruder.Support ||
            showExtruder == TemperatureStatus.Extruder.Both
        }
    }

    TemperatureStatusElement {
        id: buildplaneCool
        extruderIdx: TemperatureStatus.Extruder.HBPCool
        customCurrentTemperature: bot.buildplaneCurrentTemp
        customTargetTemperature: printPage.waitToCoolBuildplaneTemperature
        headlineVisible: false
        visible: { showExtruder == TemperatureStatus.Extruder.BuildplaneCool }
    }

    TemperatureStatusElement {
        id: hbpCool
        extruderIdx: TemperatureStatus.Extruder.HBPCool
        customCurrentTemperature: bot.hbpCurrentTemp
        customTargetTemperature: printPage.waitToCoolHBPTemperature
        headlineVisible: false
        visible: { showExtruder == TemperatureStatus.Extruder.HBPCool }
    }
}
