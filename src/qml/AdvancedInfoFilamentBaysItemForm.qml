import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    width: 800
    height: 300

    ColumnLayout {
        anchors.bottomMargin: 30
        anchors.fill: parent

        Text {
            id: heading
            text: qsTr("FILAMENT BAY")
            font.letterSpacing: 2
            font.weight: Font.Bold
            font.pixelSize: 20
            font.family: "Antennae"
            color: "#ffffff"
        }

        RowLayout {
            id: filamentBays_rowLayout
            spacing: 0
            anchors.top: heading.bottom
            anchors.topMargin: 15

            AdvancedInfoFilamentBayElement {
                id: filamentBayA
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
