import QtQuick 2.12

LoggingItem {
    anchors.fill: parent
    ContentLeftSide {
        id: contentLeftSide
        visible: true
        anchors.verticalCenter: parent.verticalCenter
        image {
            source: "qrc:/img/power_button_screen.png"
            visible: true
        }
    }

    ContentRightSide {
        id: contentRightSide
        visible: true
        anchors.verticalCenter: parent.verticalCenter
        buttonPrimary {
            text: qsTr("SHUT DOWN")
            visible: true
            onClicked: {
                bot.shutdown()
            }
        }
        buttonSecondary1 {
            text: qsTr("RESTART")
            visible: true
            onClicked: {
                bot.reboot()
            }
        }
        buttonSecondary2 {
            text: qsTr("CANCEL")
            visible: true
            onClicked: {
                powerButtonScreen.visible = false
            }
        }
    }
}
