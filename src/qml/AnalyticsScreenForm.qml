import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    width: 800
    height: 420

    property alias enableDisableButton: enableDisableButton

    Image {
        id: bot_image
        width: sourceSize.width
        height: sourceSize.height
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -15
        source: "qrc:/img/sombrero_welcome.png"
    }

    ColumnLayout {
        anchors.left: bot_image.right
        anchors.leftMargin: 8
        anchors.verticalCenter: bot_image.verticalCenter
        spacing: 15
        Text {
            id: main_instruction_text
            color: "#ffffff"
            text: qsTr("MAKERBOT ANALYTICS")
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 3
            wrapMode: Text.WordWrap
            font.family: "Antennae"
            font.weight: Font.Bold
            font.pixelSize: 20
            lineHeight: 1.3
        }

        Text {
            id: instruction_description_text
            Layout.maximumWidth: 340
            color: "#ffffff"
            text: qsTr("Analytics enables sharing of information about " +
                       "your 3D printer with MakerBot to help us improve " +
                       "our products.\nwww.MakerBot.com/Privacy")
            wrapMode: Text.WordWrap
            font.family: "Antennae"
            font.weight: Font.Light
            font.pixelSize: 18
            font.letterSpacing: 1
            lineHeight: 1.35
        }

        RoundedButton {
            id: enableDisableButton
            label_width: 280
            label_size: 18
            label: bot.net.analyticsEnabled ?
                       qsTr("DISABLE ANALYTICS") :
                       qsTr("ENABLE ANALYTICS")
            buttonWidth: 280
            buttonHeight: 50
        }
    }
}
