import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Item {
    smooth: false
    width: 800
    height: 440

    Item {
        id: baseItem
        anchors.fill: parent

        TextBody {
            style: TextBody.ExtraLarge

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            text: qsTr("%1 info").arg(bot.name)
            font.pixelSize: 17
            font.weight: Font.Bold
            font.capitalization: Font.AllUppercase
        }

        ColumnLayout {
            id: columnLayout
            width: 600
            height: 350
            anchors.left: parent.left
            anchors.leftMargin: 65
            anchors.top: parent.top
            anchors.topMargin: 50
            smooth: false

            InfoItemForm {
                id: info_firmwareVersion
                labelText: qsTr("Firmware Version")
                dataText: bot.version
            }
            InfoItem {
                id: info_connectionType
                labelText: qsTr("Connection Type")
                dataText: bot.net.interface
            }
            InfoItem {
                id: info_ipAddress
                labelText: qsTr("IP Address")
                dataText: bot.net.ipAddr
            }
            InfoItem {
                id: info_gateway
                labelText: qsTr("Gateway")
                dataText: bot.net.gateway
            }
            InfoItem {
                id: info_dns
                height: listView.height
                labelText: qsTr("DNS")
                dataText: bot.net.gateway
                labelElement.anchors.top: baseElement.top
                labelElement.anchors.topMargin: 0
                dataElement.visible: false
                ListView {
                    id: listView
                    x: 320
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    width: 150
                    height: 50
                    boundsBehavior: Flickable.DragOverBounds
                    orientation: ListView.Vertical
                    flickableDirection: Flickable.VerticalFlick
                    spacing: 5
                    smooth: false
                    model: bot.net.dns
                    delegate:
                        TextBody {
                            style: TextBody.Base

                            text: model.modelData
                            font.weight: Font.Bold
                        }
                }
            }

            InfoItem {
                id: info_wifiNetwork
                labelText: qsTr("Wi-Fi Name")
                dataText: bot.net.interface === "wifi" ? bot.net.name : qsTr("n/a")
            }
            InfoItem {
                id: info_ethMacAddress
                labelText: qsTr("Ethernet MAC Address")
                dataText: bot.net.ethMacAddr
            }
            InfoItem {
                id: info_wlanMacAddress
                labelText: qsTr("Wi-Fi MAC Address")
                dataText: bot.net.wlanMacAddr
            }
        }
    }
}
