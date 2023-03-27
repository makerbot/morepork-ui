import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Item {
    smooth: false
    anchors.fill: parent

    TextBody {
        style: TextBody.Large
        text: qsTr("PRINTER INFO")
        font.weight: Font.Bold
        font.letterSpacing: 3
        horizontalAlignment: Text.AlignHCenter

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }
    width: parent.width

    ColumnLayout {
        id: columnLayout
        width: 800
        height: 350
        smooth: false
        spacing: 34
        anchors.fill: parent
        anchors.leftMargin: 60

        Item {
            id: spacing_item
            width: 200
            height: 18
            // return to 48 when topbar gets reduced
            // height: 48
            visible: true
        }
        InfoItem {
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
            id: info_subnet
            labelText: qsTr("Netmask")
            dataText: bot.net.netmask
        }
        InfoItem {
            id: info_gateway
            labelText: qsTr("Gateway")
            dataText: bot.net.gateway
        }
        InfoItem {
            id: info_dns
            Layout.minimumHeight: listView.height
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
