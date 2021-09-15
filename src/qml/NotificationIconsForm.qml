import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import FreStepEnum 1.0

Item {
    width: 125
    height: 40
    smooth: false

    property alias hepa_filter_image: hepa_filter_image
    property string timeSeconds: "00"
    property string oldSeparatorString: " "

    Timer {
        id: secondsUpdater
        interval: 100 // 10x per second
        repeat: true
        running: true
        onTriggered: {
            timeSeconds = new Date().toLocaleString(Qt.locale(), "ss")
            // 2-on, 2-off
            var newSeparatorString = (((timeSeconds % 4) < 2) ? ":" : " ")
            if (newSeparatorString != oldSeparatorString) {
                oldSeparatorString =  newSeparatorString
                var formatString = "M/d H" + oldSeparatorString + "mm"
                textDateTime.text = new Date().toLocaleString(Qt.locale(), formatString)
            }
        }
    }

    Item {
        id: dateTimeText
        z: 3
        anchors.rightMargin: 0
        anchors.topMargin: 11
        height: barHeight
        smooth: false
        anchors.right: hepaFilter_item.left
        anchors.top: parent.top

        Text {
            id: textDateTime
            color: "#a0a0a0"
            text: "--/--\n--:--"
            antialiasing: false
            smooth: false
            font.capitalization: Font.AllUppercase
            font.family: defaultFont.name
            font.letterSpacing: 0
            font.weight: Font.Light
            font.pixelSize: 18
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignRight
            anchors.top: parent.top
            anchors.right: parent.right
        }
    }

    Item {
        id: hepaFilter_item
        width: 26
        height: 26
        anchors.right: filamentIconItem.left
        anchors.rightMargin: 7
        anchors.verticalCenter: parent.verticalCenter
        smooth: false

        AnimatedImage {
            id: hepa_filter_image
            smooth: false
            anchors.fill: parent
            opacity: 1
            visible: bot.hepaFilterConnected
            source: bot.hepaFilterChangeRequired ? "qrc:/img/yellow_hepa_blink.gif" : "qrc:/img/white_hepa_no_blink.gif"
            cache: false
        }
    }

    Item {
        id: filamentIconItem
        width: 35
        height: 26
        anchors.right: connectionType_item.left
        anchors.rightMargin: 7
        anchors.verticalCenter: parent.verticalCenter
        smooth: false
        opacity: isFreComplete || currentFreStep >= FreStep.AttachExtruders

        FilamentIcon {
            id: filament1_icon
            z: 1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -8
            filamentBayID: 1
            anchors.verticalCenter: parent.verticalCenter
        }

        FilamentIcon {
            id: filament2_icon
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 8
            filamentBayID: 2
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Item {
        id: connectionType_item
        width: 26
        height: 26
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        smooth: false

        Image {
            id: connection_type_image
            antialiasing: true
            smooth: true
            anchors.fill: parent
            visible: true
            source: {
                switch(bot.net.interface) {
                case "wifi":
                    "qrc:/img/wifi_connected.png"
                    break;
                case "ethernet":
                    "qrc:/img/ethernet_connected.png"
                    break;
                default:
                    "qrc:/img/no_ethernet.png"
                    break;
                }
            }
        }
    }
}
