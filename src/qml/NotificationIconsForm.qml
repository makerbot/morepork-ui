import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import FreStepEnum 1.0

Item {
    width: 125
    height: 40
    smooth: false

    property alias hepa_filter_image: hepa_filter_image

    Timer {
        id: uiTimeTimer
        interval: 60000 // once every minute
        repeat: true
        running: true
        onTriggered: {
            bot.getSystemTime()
            var systemTime = bot.systemTime
            if (systemTime.indexOf(" ") < 0) {
                // not ready for parsing; do nothing
                return
            }
            // 2018-09-10 18:04:16
            var time_elements = systemTime.split(" ")
            var date_element = time_elements[0] // 2018-09-10
            var time_element = time_elements[1] // 18:04:16
            var time_split = time_element.split(":")
            var current_hour = time_split[0] // 18
            var current_minute = time_split[1] // 04
            var current_second = time_split[2] // 16
            var date_split = date_element.split("-")
            // var current_year = date_split[0] // 2018
            var current_month = date_split[1] // 09
            var current_day = date_split[2] //10

            var monthDayText = current_month + "/" + current_day
            current_hour = (current_hour == 0 ? 12 : current_hour)
            var hourMinuteText = current_hour + ":" + current_minute

            textDateTime.text = monthDayText + "\n" + hourMinuteText
        }
    }

    Item {
        id: dateTimeText
        z: 3
        anchors.rightMargin: 0
        anchors.topMargin: 0
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
            font.pixelSize: 12
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
