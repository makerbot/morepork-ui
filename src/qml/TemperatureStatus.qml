import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import MachineTypeEnum 1.0

ColumnLayout {
    width: 360
    height: children.height
    spacing: 20

    enum Component {
        ModelExtruder,
        SupportExtruder,
        BothExtruders,
        Chamber,
        ChamberBuildPlane,
        HeatedBuildPlate,
        ChamberAndHeatedBuildPlate,
        Generic
    }

    property int showComponent: TemperatureStatus.BothExtruders
    property alias component1: component1
    property alias component2: component2

    TemperatureStatusElement {
        id: component1
        componentName: {
            if(showComponent == TemperatureStatus.ModelExtruder ||
               showComponent == TemperatureStatus.BothExtruders) {
                qsTr("EXTRUDER 1")
            } else if(showComponent == TemperatureStatus.SupportExtruder) {
                qsTr("EXTRUDER 2")
            } else if(showComponent == TemperatureStatus.Chamber ||
                      showComponent == TemperatureStatus.ChamberBuildPlane) {
                qsTr("CHAMBER")
            } else if(showComponent == TemperatureStatus.HeatedBuildPlate) {
                qsTr("BUILD PLATE")
            } else if(showComponent == TemperatureStatus.ChamberAndHeatedBuildPlate) {
                qsTr("CHAMBER")
            } else if(showComponent == TemperatureStatus.Generic) {
                "GENERIC HEATER"
            }
        }
        customCurrentTemperature: {
            if(showComponent == TemperatureStatus.ModelExtruder ||
               showComponent == TemperatureStatus.BothExtruders) {
                bot.extruderACurrentTemp
            } else if(showComponent == TemperatureStatus.SupportExtruder) {
                bot.extruderBCurrentTemp
            } else if(showComponent == TemperatureStatus.Chamber) {
                bot.chamberCurrentTemp
            } else if(showComponent == TemperatureStatus.ChamberBuildPlane) {
                bot.buildplaneCurrentTemp
            } else if(showComponent == TemperatureStatus.HeatedBuildPlate) {
                bot.hbpCurrentTemp
            } else if(showComponent == TemperatureStatus.ChamberAndHeatedBuildPlate) {
                bot.buildplaneCurrentTemp
            } else if(showComponent == TemperatureStatus.Generic) {
                -999
            }
        }
        customTargetTemperature: {
            if(showComponent == TemperatureStatus.ModelExtruder ||
               showComponent == TemperatureStatus.BothExtruders) {
                bot.extruderATargetTemp
            } else if(showComponent == TemperatureStatus.SupportExtruder) {
                bot.extruderBTargetTemp
            } else if(showComponent == TemperatureStatus.Chamber) {
                bot.chamberTargetTemp
            } else if(showComponent == TemperatureStatus.ChamberBuildPlane) {
                bot.buildplaneTargetTemp
            } else if(showComponent == TemperatureStatus.HeatedBuildPlate) {
                bot.hbpTargetTemp
            } else if(showComponent == TemperatureStatus.ChamberAndHeatedBuildPlate) {
                bot.buildplaneTargetTemp
            } else if(showComponent == TemperatureStatus.Generic) {
                -999
            }
        }
    }

    TemperatureStatusElement {
        id: component2
        componentName: {
            if(showComponent == TemperatureStatus.ChamberAndHeatedBuildPlate) {
                qsTr("BUILD PLATE")
            } else {
                qsTr("EXTRUDER 2")
            }
        }
        customCurrentTemperature: {
            if(showComponent == TemperatureStatus.ChamberAndHeatedBuildPlate) {
                bot.hbpCurrentTemp
            } else {
                bot.extruderBCurrentTemp
            }
        }
        customTargetTemperature: {
            if(showComponent == TemperatureStatus.ChamberAndHeatedBuildPlate) {
                bot.hbpTargetTemp
            } else {
                bot.extruderBTargetTemp
            }
        }
        visible: showComponent == TemperatureStatus.BothExtruders ||
                 showComponent == TemperatureStatus.ChamberAndHeatedBuildPlate
    }
}
