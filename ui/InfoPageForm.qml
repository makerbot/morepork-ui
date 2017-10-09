import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
//import QtGraphicalEffects 1.0

MenuTemplateForm {
    id: menuTemplateForm
    property alias flickable: flickable
    image_drawerArrow.visible: false

    Flickable {
        id: flickable
        y: 70
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
                text_label.text: qsTr("Firmware Version  ")
                text_data.text: bot.version
            }
            InfoItem {
                id: info_connectionType
                width: parent.width
                text_label.text: qsTr("Connection Type  ")
                text_data.text: bot.net.interface
            }
            InfoItem {
                id: info_ipAddress
                width: parent.width
                text_label.text: qsTr("IP Address  ")
                text_data.text: bot.net.ipAddr
            }
            InfoItem {
                id: info_subnet
                width: parent.width
                text_label.text: qsTr("Netmask  ")
                text_data.text: bot.net.netmask
            }
            InfoItem {
                id: info_gateway
                width: parent.width
                text_label.text: qsTr("Gateway  ")
                text_data.text: bot.net.gateway
            }
            Item { //TODO: make this a QML Form
                id: infoListItem
                height: 45
                width: parent.width
                property alias dns_text_label: dns_text_label

                RowLayout {
                    anchors.verticalCenter: parent.verticalCenter

                    Item{
                        z: 1
                        height: parent.height
                        width: dns_text_label.width

                        Text {
                            id: dns_text_label
                            text: qsTr("DNS  ")
                            z: 2
                            font.family: "Antenna"
                            font.letterSpacing: 3
                            font.pixelSize: 28
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#ffffff"

                        }

//                        Item {
//                            anchors.fill: dns_text_label
//                            anchors.leftMargin: -15

//                            LinearGradient {
//                                cached: true
//                                anchors.fill: parent
//                                start: Qt.point(parent.width, 0)
//                                end: Qt.point(0, 0)
//                                gradient: Gradient {
//                                  GradientStop {
//                                    position: 0.0
//                                    color: "#00000000"
//                                  }
//                                  GradientStop {
//                                    position: 0.25
//                                    color: "#FF000000"
//                                  }
//                                }
//                            }
//                        }

                        Rectangle {
                            id: rectangle
                            anchors.leftMargin: -15
                            anchors.fill: dns_text_label
                            color: "#000000"
                            z: 1
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
                text_label.text: qsTr("WiFi Name  ")
                text_data.text: bot.net.interface === "wifi" ? "null" : "n/a"
            }
            InfoItem {
                id: info_ethMacAddress
                width: parent.width
                text_label.text: qsTr("Ethernet MAC Address  ")
                text_data.text: bot.net.ethMacAddr
            }
            InfoItem {
                id: info_wlanMacAddress
                width: parent.width
                text_label.text: qsTr("WiFi MAC Address  ")
                text_data.text: bot.net.wlanMacAddr
            }
        }
    }
}
