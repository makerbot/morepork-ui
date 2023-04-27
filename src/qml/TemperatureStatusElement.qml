import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import MachineTypeEnum 1.0

ColumnLayout {
    width: 360
    spacing: 8

    property int extruderIdx: 0
    property int customCurrentTemperature: -999
    property int customTargetTemperature: -999
    property alias type: headline.text
    property bool headlineVisible: true

    property string idxAsAxis: {
        switch (extruderIdx) {
            case 0:
                "A"
                break
            case 1:
                "B"
                break
            case 2:
                "Chamber"
                break
            default:
                "A"
        }
    }

    TextHeadline {
        id: headline
        text: qsTr("Extruder %1").arg(extruderIdx + 1)
        visible: headlineVisible
    }

    RowLayout {
        spacing: 44

        ColumnLayout {
            spacing: 4

            TextBody {
                text: qsTr("Current")
            }

            TextBody {
                text: {
                    customCurrentTemperature > 0 ? customCurrentTemperature :
                    ("%1 C").arg(bot["extruder%1CurrentTemp".arg(idxAsAxis)])
                }
                font.weight: Font.Bold
            }
        }

        ColumnLayout {
            spacing: 4

            TextBody {
                text: qsTr("Target")
            }

            TextBody {
                text: {
                    customTargetTemperature > 0 ? customTargetTemperature :
                    ("%1 C").arg(bot["extruder%1TargetTemp".arg(idxAsAxis)])
                }
                font.weight: Font.Bold
            }
        }
    }
}
