import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: parent.width
    height: columnLayout.height

    Column {
        id: columnLayout
        width: parent.width
        spacing: 40

        TextHeadline {
            style: TextHeadline.Large
            id: heading
            text: qsTr("FILAMENT BAY")
            font.letterSpacing: 10
        }

        RowLayout {
            id: filamentBays_rowLayout
            width: parent.width
            spacing: 32

            AdvancedInfoFilamentBayElement {
                id: filamentBayA
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                filamentBayLabelProperty.text: qsTr("BAY 1")
                temperatureProperty.value: bot.infoBay1Temp
                humidityProperty.value: bot.infoBay1Humidity
                filamentPresentProperty.value: bot.infoBay1FilamentPresent
                tagPresentProperty.value: bot.infoBay1TagPresent
                tagUidProperty.value: bot.infoBay1TagUID
                tagVerifiedProperty.value: bot.infoBay1TagVerified
                verificationDoneProperty.value: bot.infoBay1VerificationDone
                errorCodeProperty.value: bot.infoBay1Error
            }

            AdvancedInfoFilamentBayElement {
                id: filamentBayB
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                filamentBayLabelProperty.text: qsTr("BAY 2")
                temperatureProperty.value: bot.infoBay2Temp
                humidityProperty.value: bot.infoBay2Humidity
                filamentPresentProperty.value: bot.infoBay2FilamentPresent
                tagPresentProperty.value: bot.infoBay2TagPresent
                tagUidProperty.value: bot.infoBay2TagUID
                tagVerifiedProperty.value: bot.infoBay2TagVerified
                verificationDoneProperty.value: bot.infoBay2VerificationDone
                errorCodeProperty.value: bot.infoBay2Error
            }
        }
    }
}
