import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import FreStepEnum 1.0

Item {
    width: 125
    height: 40
    smooth: false

    property alias hepa_filter_image: hepa_filter_image

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
            source: bot.hepaFilterChangeRequired ? "qrc:/img/yellow_hepa_blink.gif" : "qrc:/img/hepa_filter_solid.gif"
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
