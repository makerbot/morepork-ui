import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 640
    height: 280

    ColumnLayout {
        id: columnLayout
        anchors.bottomMargin: 40
        spacing: -1.5
        anchors.fill: parent

        Text {
            id: heading
            text: "MOTION STATUS"
            font.letterSpacing: 2
            font.weight: Font.Bold
            font.pixelSize: 20
            font.family: "Antenna"
            color: "#ffffff"
        }

        Item {
            id: spacing_item
            width: 200
            height: 15
            visible: true
        }

        AdvancedInfoMotionStatusElement {
            id: headingLabelProperty
        }

        Item {
            id: spacing_item1
            width: 200
            height: 15
            visible: true
        }

        AdvancedInfoMotionStatusElement {
            id: xAxisProperty
            axis_label: "X"
            enabled_value: bot.infoAxisXEnabled
            endstop_value: bot.infoAxisXEndStopActive
            position_value: bot.infoAxisXPosition.toFixed(3)
        }

        AdvancedInfoMotionStatusElement {
            id: yAxisProperty
            axis_label: "Y"
            enabled_value: bot.infoAxisYEnabled
            endstop_value: bot.infoAxisYEndStopActive
            position_value: bot.infoAxisYPosition.toFixed(3)
        }

        AdvancedInfoMotionStatusElement {
            id: zAxisProperty
            axis_label: "Z"
            enabled_value: bot.infoAxisZEnabled
            endstop_value: bot.infoAxisZEndStopActive
            position_value: bot.infoAxisZPosition.toFixed(3)
        }

        AdvancedInfoMotionStatusElement {
            id: aAxisProperty
            axis_label: "A"
            enabled_value: bot.infoAxisAEnabled
            endstop_value: bot.infoAxisAEndStopActive
            position_value: bot.infoAxisAPosition.toFixed(3)
        }

        AdvancedInfoMotionStatusElement {
            id: bAxisProperty
            axis_label: "B"
            enabled_value: bot.infoAxisBEnabled
            endstop_value: bot.infoAxisBEndStopActive
            position_value: bot.infoAxisBPosition.toFixed(3)
        }

        AdvancedInfoMotionStatusElement {
            id: aaAxisProperty
            axis_label: "AA"
            enabled_value: bot.infoAxisAAEnabled
            endstop_value: bot.infoAxisAAEndStopActive
            position_value: bot.infoAxisAAPosition.toFixed(3)
        }

        AdvancedInfoMotionStatusElement {
            id: bbAxisProperty
            axis_label: "BB"
            enabled_value: bot.infoAxisBBEnabled
            endstop_value: bot.infoAxisBBEndStopActive
            position_value: bot.infoAxisBBPosition.toFixed(3)
        }
    }
}
