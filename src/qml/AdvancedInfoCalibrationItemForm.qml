import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: parent.width
    height: 314

    ColumnLayout {
        width: parent.width
        spacing: 40

        TextHeadline {
            style: TextHeadline.Large
            id: heading
            text: qsTr("CALIBRATION OFFSETS")
            font.letterSpacing: 10
        }

        RowLayout {
            id: calibration_rowLayout
            spacing: 0

            AdvancedInfoCalibrationElement {
                id: toolheadA
                calibrationLabelProperty.text: qsTr("TOOLHEAD A")
                xOffset.value: bot.offsetAX.toFixed(6)
                yOffset.value: bot.offsetAY.toFixed(6)
                zOffset.value: bot.offsetAZ.toFixed(6)
            }

            AdvancedInfoCalibrationElement {
                id: toolheadB
                calibrationLabelProperty.text: qsTr("TOOLHEAD B")
                xOffset.value: bot.offsetBX.toFixed(6)
                yOffset.value: bot.offsetBY.toFixed(6)
                zOffset.value: bot.offsetBZ.toFixed(6)
            }
        }
    }
}
