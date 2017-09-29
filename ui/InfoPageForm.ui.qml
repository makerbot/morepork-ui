import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

MenuTemplateForm {
    Flickable {
        id: flickable
        interactive: true
        flickableDirection: Flickable.VerticalFlick
        anchors.topMargin: 75
        anchors.leftMargin: 15
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            spacing: 1

            InfoItemForm {
                id: info_firmwareVersion
                width: parent.width
                text_label.text: "Firmware Version"
                text_data.text: bot.version
            }
            InfoItem {
                id: info_connectionType
                width: parent.width
                text_label.text: "Connection Type"
                text_data.text: "null"
            }
            InfoItem {
                id: info_ipAddress
                width: parent.width
                text_label.text: "IP Address"
                text_data.text: bot.net.ipAddr
            }
            InfoItem {
                id: info_subnet
                width: parent.width
                text_label.text: "Subnet"
                text_data.text: bot.net.netmask
            }
            InfoItem {
                id: info_gateway
                width: parent.width
                text_label.text: "Gateway"
                text_data.text: bot.net.gateway
            }
            InfoItem {
                id: info_dns
                width: parent.width
                text_label.text: "DNS"
                text_data.text: "null"
            }
            InfoItem {
                id: info_wifiNetwork
                width: parent.width
                text_label.text: "WiFi Network"
                text_data.text: "null"
            }
            InfoItem {
                id: info_macAddress
                width: parent.width
                text_label.text: "MAC Address"
                text_data.text: "null"
            }
        }
    }
}
