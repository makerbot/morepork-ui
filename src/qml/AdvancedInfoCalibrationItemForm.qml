import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 800
    height: 180

    ColumnLayout {
        anchors.bottomMargin: 10
        anchors.fill: parent

        Text {
            id: heading
            text: qsTr("CALIBRATION OFFSETS")
            font.letterSpacing: 2
            font.weight: Font.Bold
            font.pixelSize: 20
            font.family: defaultFont.name
            color: "#ffffff"
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
