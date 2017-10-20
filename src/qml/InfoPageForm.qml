import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Item {
    id: menuTemplateForm
    property alias flickable: flickable

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.leftMargin: 15
        interactive: true
        flickableDirection: Flickable.VerticalFlick
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
                textLabel.text: qsTr("Firmware Version") + cpUiTr.emptyStr
                textData.text: bot.version
            }
            InfoItem {
                id: info_connectionType
                width: parent.width
                textLabel.text: qsTr("Connection Type") + cpUiTr.emptyStr
                textData.text: bot.net.interface
            }
            InfoItem {
                id: info_ipAddress
                width: parent.width
                textLabel.text: qsTr("IP Address") + cpUiTr.emptyStr
                textData.text: bot.net.ipAddr
            }
            InfoItem {
                id: info_subnet
                width: parent.width
                textLabel.text: qsTr("Netmask") + cpUiTr.emptyStr
                textData.text: bot.net.netmask
            }
            InfoItem {
                id: info_gateway
                width: parent.width
                textLabel.text: qsTr("Gateway") + cpUiTr.emptyStr
                textData.text: bot.net.gateway
            }
            Item { //TODO: make this a QML Form
                id: infoListItem
                height: 45
                width: parent.width
                property alias dnsTextLabel: dnsTextLabel

                RowLayout {
                    id: rowLayoutDns
                    spacing: 25
                    anchors.verticalCenter: parent.verticalCenter

                    Item{
                        z: 1
                        height: parent.height
                        width: dnsTextLabel.width

                        Text {
                            id: dnsTextLabel
                            text: qsTr("DNS") + cpUiTr.emptyStr
                            z: 2
                            font.family: "Antenna"
                            font.letterSpacing: 3
                            font.pixelSize: 28
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#ffffff"

                        }

                        Item {
                            anchors.fill: dnsTextLabel
                            anchors.leftMargin: -flickable.anchors.leftMargin
                            anchors.rightMargin: -rowLayoutDns.spacing

                            LinearGradient {
                                cached: true
                                anchors.fill: parent
                                start: Qt.point(parent.width, 0)
                                end: Qt.point(0, 0)
                                gradient: Gradient {
                                  GradientStop {
                                    position: 0.0
                                    color: "#00000000"
                                  }
                                  GradientStop {
                                    position: 0.25
                                    color: "#FF000000"
                                  }
                                }
                            }
                        }
                    }

                    ListView {
                        width: 650 //TODO: Dynamically set this
                        height: infoListItem.height
                        boundsBehavior: Flickable.DragOverBounds
                        spacing: 15
                        orientation: ListView.Horizontal
                        flickableDirection: Flickable.HorizontalFlick
                        z: 0

                        model: bot.net.dns
                        delegate: Text {
                            text: modelData
                            font.family: "Antenna"
                            font.letterSpacing: 3
                            font.weight: Font.Light
                            font.pixelSize: 26
                            verticalAlignment: Text.AlignTop
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#ffffff"
                        }
                    }
                }
            }
            InfoItem {
                id: info_wifiNetwork
                width: parent.width
                textLabel.text: qsTr("WiFi Name") + cpUiTr.emptyStr
                textData.text: bot.net.interface === "wifi" ? "null" : "n/a"
            }
            InfoItem {
                id: info_ethMacAddress
                width: parent.width
                textLabel.text: qsTr("Ethernet MAC Address") + cpUiTr.emptyStr
                textData.text: bot.net.ethMacAddr
            }
            InfoItem {
                id: info_wlanMacAddress
                width: parent.width
                textLabel.text: qsTr("WiFi MAC Address") + cpUiTr.emptyStr
                textData.text: bot.net.wlanMacAddr
            }
        }
    }
}
