import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import WifiStateEnum 1.0
import WifiErrorEnum 1.0

ColumnLayout {
    spacing: 15
    Layout.alignment: Qt.AlignHCenter

    Image {
        id: ethernet_image
        Layout.preferredWidth: 30
        Layout.preferredHeight: 30
        Layout.alignment: Qt.AlignHCenter
        source: {
            if(bot.net.interface == "ethernet") {
                "qrc:/img/process_complete_small.png"
            } else {
                "qrc:/img/ethernet_connected.png"
            }
        }
    }

    TextBody {
        font.pixelSize: 13
        font.weight: Font.Bold
        Layout.alignment: Qt.AlignHCenter
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap

        Layout.preferredWidth: 400
        text: {
            if(bot.net.interface == "ethernet") {
                "You’re connected to the internet through the ethernet port."
            } else {
                "Plug an ethernet cable into the rear of the machine to use a wired connection."
            }
        }
    }

    // Extra space at the bottom
    Item {
        height: 0
        width: 1
    }
}
