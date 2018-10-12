import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    width: 75
    height: 40
    smooth: false

    RowLayout {
        id: rowLayout
        smooth: false
        spacing: 5
        anchors.fill: parent

        Item {
            id: filamentIconItem
            width: 35
            height: 26
            smooth: false
            anchors.verticalCenter: parent.verticalCenter
            opacity: isFreComplete || currentFreStep >= 6

            FilamentIcon {
                id: filament1_icon
                z: 1
                anchors.left: parent.left
                anchors.leftMargin: 5
                filamentBayID: 1
            }

            FilamentIcon {
                id: filament2_icon
                anchors.left: parent.left
                anchors.leftMargin: 20
                filamentBayID: 2
            }
        }

        Item {
            id: connectionType_item
            width: 26
            height: 26
            smooth: false
            anchors.verticalCenter: parent.verticalCenter

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
}
