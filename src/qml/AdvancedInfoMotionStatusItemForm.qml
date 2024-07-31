import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: parent.width
    implicitHeight: columnLayout.height

    Column {
        id: columnLayout
        width: parent.width
        spacing: 25

        TextHeadline {
            style: TextHeadline.Large
            id: heading
            text: qsTr("MOTION STATUS")
            font.letterSpacing: 10
            width: parent.width
        }

        AdvancedInfoMotionStatusElement {
            id: headingLabelProperty
            axis {
                style: TextBody.Large
                font.weight: Font.Bold
            }
            enabled {
                style: TextBody.Large
                font.weight: Font.Bold
            }
            endstop {
                style: TextBody.Large
                font.weight: Font.Bold
            }
            position {
                style: TextBody.Large
                font.weight: Font.Bold
            }
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
