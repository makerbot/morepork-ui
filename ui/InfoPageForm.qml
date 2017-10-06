import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

MenuTemplateForm {
    image_drawerArrow.visible: false

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
                text_label.text: qsTr("Firmware Version")
                text_data.text: bot.version
            }
            InfoItem {
                id: info_connectionType
                width: parent.width
                text_label.text: qsTr("Connection Type")
                text_data.text: bot.net.interface
            }
            InfoItem {
                id: info_ipAddress
                width: parent.width
                text_label.text: qsTr("IP Address")
                text_data.text: bot.net.ipAddr
            }
            InfoItem {
                id: info_subnet
                width: parent.width
                text_label.text: qsTr("Netmask")
                text_data.text: bot.net.netmask
            }
            InfoItem {
                id: info_gateway
                width: parent.width
                text_label.text: qsTr("Gateway")
                text_data.text: bot.net.gateway
            }
            InfoItem {
                id: info_dns
                width: parent.width
                text_label.text: qsTr("DNS")
                text_data.text: "null"
            }
            InfoItem {
                id: info_wifiNetwork
                width: parent.width
                text_label.text: qsTr("WiFi Network")
                text_data.text: bot.net.interface === "wifi" ? "null" : "n/a"
            }
            InfoItem {
                id: info_ethMacAddress
                width: parent.width
                text_label.text: qsTr("Ethernet MAC Address")
                text_data.text: bot.net.ethMacAddr
            }
            InfoItem {
                id: info_wlanMacAddress
                width: parent.width
                text_label.text: qsTr("WLAN MAC Address")
                text_data.text: bot.net.wlanMacAddr
            }
        }
    }
}
