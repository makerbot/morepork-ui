import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

MenuTemplateForm {
    //property alias info_firmwareVersion: info_firmwareVersion

    ListView {
        id: listView
        anchors.topMargin: 10
        anchors.leftMargin: 10
        anchors.fill: parent

        delegate: Item {
            x: 5
            width: parent.width
            height: 40

            RowLayout {
                Text {
                    text: text_name
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#ffffff"
                    font.pixelSize: 20
                }

                Text {
                    text: text_data
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#ffffff"
                    font.pixelSize: 20
                }
            }
        }

        model: ListModel {
            ListElement {
                //id: info_firmwareVersion
                text_name: "Firmware Version"
                text_data: "null"
            }

            ListElement {
                //id: info_connectionType
                text_name: "Connection Type"
                text_data: "null"
            }

            ListElement {
                //id: info_ipAddress
                text_name: "IP Address"
                text_data: "null"
            }

            ListElement {
                //id: info_subnet
                text_name: "Subnet"
                text_data: "null"
            }

            ListElement {
                //id: info_gateway
                text_name: "Gateway"
                text_data: "null"
            }

            ListElement {
                //id: info_dns
                text_name: "DNS"
                text_data: "null"
            }

            ListElement {
                //id: info_wifiNetwork
                text_name: "WiFi Network"
                text_data: "null"
            }

            ListElement {
                //id: info_macAddress
                text_name: "MAC Address"
                text_data: "null"
            }
        }
    }
}
