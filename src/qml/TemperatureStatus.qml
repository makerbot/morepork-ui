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
        Both
    }

    property int showExtruder: TemperatureStatus.Extruder.Both
    property alias modelExtruder: modelExtruder
    property alias supportExtruder: supportExtruder

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
}
