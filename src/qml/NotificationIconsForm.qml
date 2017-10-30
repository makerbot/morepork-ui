import QtQuick 2.4

Item {
    width: 100
    height: 40

    Row {
        id: rowLayout
        spacing: 13
        anchors.fill: parent

        FilamentIcon{
            id: filament1_icon
            filamentPercent: bot.filament1Percent
            filamentColor: bot.filament1Color
        }

        FilamentIcon{
            id: filament2_icon
            filamentPercent: bot.filament2Percent
            filamentColor: bot.filament2Color
        }

        Item {
            id: connectionType_item
            width: 26
            height: 26
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: connection_type_image
                anchors.fill: parent
                visible: true
                source:
                {
                    switch(bot.net.interface)
                    {
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
