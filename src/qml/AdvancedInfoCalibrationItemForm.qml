import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: parent.width
    height: calibration_columnLayout.height

    Column {
        id: calibration_columnLayout
        width: parent.width
        spacing: 40

        TextHeadline {
            style: TextHeadline.Large
            id: heading
            text: qsTr("CALIBRATION OFFSETS")
            font.letterSpacing: 10
            width: parent.width
        }

        RowLayout {
            id: calibration_rowLayout
            width: parent.width
            spacing: 32

            AdvancedInfoCalibrationElement {
                id: toolheadA
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                calibrationLabelProperty.text: qsTr("TOOLHEAD A")
                xOffset.value: bot.offsetAX.toFixed(6)
                yOffset.value: bot.offsetAY.toFixed(6)
                zOffset.value: bot.offsetAZ.toFixed(6)
            }

            AdvancedInfoCalibrationElement {
                id: toolheadB
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                calibrationLabelProperty.text: qsTr("TOOLHEAD B")
                xOffset.value: bot.offsetBX.toFixed(6)
                yOffset.value: bot.offsetBY.toFixed(6)
                zOffset.value: bot.offsetBZ.toFixed(6)
            }
        }
    }
}
