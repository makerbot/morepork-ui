import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: parent.width
    height: 667

    ColumnLayout {
        width: parent.width
        spacing: 40

        TextHeadline {
            style: TextHeadline.Large
            id: heading
            text: qsTr("TOOLHEADS")
            font.letterSpacing: 10
        }

        RowLayout {
            id: toolheads_rowLayout
            spacing: 0

            AdvancedInfoToolheadElement {
                id: toolheadA
                toolheadLabelProperty.text: qsTr("A/1")
                attachedProperty.value: bot.infoToolheadAAttached
                filamentPresentProperty.value: bot.infoToolheadAFilamentPresent
                currentTempProperty.value: bot.infoToolheadACurrentTemp
                targetTempProperty.value: bot.infoToolheadATargetTemp
                tempOffsetProperty.value: (bot.infoToolheadATempOffset).toFixed(2)
                encoderTicksProperty.value: bot.infoToolheadAEncoderTicks
                activeFanRpmProperty.value: bot.infoToolheadAActiveFanRPM
                activeFanFailSecsProperty.value: bot.infoToolheadAActiveFanFailSecs
                gradientFanRpmProperty.value: bot.infoToolheadAGradientFanRPM
                gradientFanFailSecsProperty.value: bot.infoToolheadAGradientFanFailSecs
                hesValueProperty.value: bot.infoToolheadAHESValue
                jamEnabledProperty.value: bot.infoToolheadAFilamentJamEnabled
                errorCodeProperty.value: bot.infoToolheadAError
            }

            AdvancedInfoToolheadElement {
                id: toolheadB
                toolheadLabelProperty.text: qsTr("B/2")
                attachedProperty.value: bot.infoToolheadBAttached
                filamentPresentProperty.value: bot.infoToolheadBFilamentPresent
                currentTempProperty.value: bot.infoToolheadBCurrentTemp
                targetTempProperty.value: bot.infoToolheadBTargetTemp
                tempOffsetProperty.value: (bot.infoToolheadBTempOffset).toFixed(2)
                encoderTicksProperty.value: bot.infoToolheadBEncoderTicks
                activeFanRpmProperty.value: bot.infoToolheadBActiveFanRPM
                activeFanFailSecsProperty.value: bot.infoToolheadBActiveFanFailSecs
                gradientFanRpmProperty.value: bot.infoToolheadBGradientFanRPM
                gradientFanFailSecsProperty.value: bot.infoToolheadBGradientFanFailSecs
                hesValueProperty.value: bot.infoToolheadBHESValue
                jamEnabledProperty.value: bot.infoToolheadBFilamentJamEnabled
                errorCodeProperty.value: bot.infoToolheadBError
            }
        }
    }
}
