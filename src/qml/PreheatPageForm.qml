import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    smooth: false
    anchors.fill: parent
    property alias buttonAutoChamberPreheat: buttonAutoChamberPreheat
    property alias buttonStartStopPreheat: buttonStartStopPreheat
    property alias switchAutoChamberPreheat: switchAutoChamberPreheat

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
                id: buttonAutoChamberPreheat
                buttonImage.source: "qrc:/img/icon_advanced_info.png"
                buttonText.text: "AUTO CHAMBER PREHEAT"

                SlidingSwitch {
                    id: switchAutoChamberPreheat
                    checked: false
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 50

                    onClicked: {
                        if(switchAutoChamberPreheat.checked) {

                        }
                        else if(!switchAutoChamberPreheat.checked) {

                        }
                    }
                }
            }

            Item { width: parent.width; height: 1; smooth: false;
                Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
            }

            MenuButton {
                id: buttonStartStopPreheat
                buttonImage.source: "qrc:/img/icon_preheat.png"
                buttonText.text: bot.chamberTargetTemp > 0 ?
                                     "STOP CHAMBER PREHEAT" :
                                     "START CHAMBER PREHEAT"
                Text {
                    id: temperature_text
                    color: "#ffffff"
                    text: {
                        if(bot.chamberTargetTemp > 0) {
                            bot.chamberCurrentTemp + "|" + bot.chamberTargetTemp + "\u00b0C"
                        }
                        else {
                            bot.chamberCurrentTemp + "\u00b0C"
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
