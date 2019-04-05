import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    smooth: false
    anchors.fill: parent
    property alias buttonStartStopPreheat: buttonStartStopPreheat

    Flickable {
        id: flickablePreheat
        smooth: false
        flickableDirection: Flickable.VerticalFlick
        interactive: true
        anchors.fill: parent
        contentHeight: columnPreheat.height

        Column {
            id: columnPreheat
            smooth: false
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            spacing: 0

            MenuButton {
                id: buttonStartStopPreheat
                buttonImage.source: "qrc:/img/icon_preheat.png"
                buttonText.text: bot.chamberTargetTemp > 0 ?
                                     qsTr("STOP CHAMBER PREHEAT") :
                                     qsTr("START CHAMBER PREHEAT")
                Text {
                    id: temperature_text
                    color: "#ffffff"
                    text: {
                        if(bot.chamberTargetTemp > 0) {
                            bot.chamberCurrentTemp + "|" + bot.chamberTargetTemp + qsTr("\u00b0C")
                        }
                        else {
                            bot.chamberCurrentTemp + qsTr("\u00b0C")
                        }
                    }
                    font.letterSpacing: 3
                    font.weight: Font.Light
                    font.family: "Antennae"
                    font.pixelSize: 20
                    anchors.right: parent.right
                    anchors.rightMargin: {
                        if(bot.chamberTargetTemp > 0) {
                            35
                        }
                        else {
                            72
                        }
                    }
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item { width: parent.width; height: 1; smooth: false;
                Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
            }
        }
    }
}
