import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: parent.width
    height: 314

    ColumnLayout {
        width: parent.width
        spacing: 43

        TextHeadline {
            style: TextHeadline.Large
            id: heading
            text: qsTr("CALIBRATION OFFSETS")
        }

        RowLayout {
            id: calibration_rowLayout
            spacing: 0

            AdvancedInfoCalibrationElement {
                id: toolheadA
                calibrationLabelProperty.text: qsTr("TOOLHEAD A")
                xOffset.value: bot.offsetAX.toFixed(10)
                yOffset.value: bot.offsetAY.toFixed(10)
                zOffset.value: bot.offsetAZ.toFixed(10)
            }

            AdvancedInfoCalibrationElement {
                id: toolheadB
                calibrationLabelProperty.text: qsTr("TOOLHEAD B")
                xOffset.value: bot.offsetBX.toFixed(10)
                yOffset.value: bot.offsetBY.toFixed(10)
                zOffset.value: bot.offsetBZ.toFixed(10)
            }
        }
    }
}
