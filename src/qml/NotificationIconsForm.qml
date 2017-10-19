import QtQuick 2.4

Item {
    width: 130
    height: 40

    Rectangle {
        id: base
        color: "#000000"
        anchors.fill: parent

        Image {
            id: unknown_filament1_image
            width: 40
            height: 40
            anchors.horizontalCenterOffset: -40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/img/unknown_filament.png"
            visible: (!bot.filament1Color)
        }

        Image {
            id: unknown_filament2_image
            width: 40
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/img/unknown_filament.png"
            visible: (!bot.filament2Color)
        }

        Rectangle {
            id: filament1_circle
            width: 30
            height: 30
            color: "#000000"
            radius: 15
            rotation: -90
            anchors.horizontalCenterOffset: -40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            border.color: "#ffffff"
            border.width: 2
            visible: bot.filament1Color

            property int filament1Percent: bot.filament1Percent

            property string filament1Color:
            {
                switch(bot.filament1Color)
                {
                    case 1:
                        "Red"
                        break;
                    case 2:
                        "Green"
                        break;
                    case 3:
                        "Blue"
                        break;
                    case 4:
                        "Yellow"
                        break;
                    case 5:
                        "Orange"
                        break;
                    case 6:
                        "Violet"
                        break;
                    case 0:
                        "transparent"
                        break;
                }
            }

            onFilament1PercentChanged: canvas1.requestPaint()

            Canvas {
                id: canvas1
                anchors.fill: parent
                onPaint:
                {
                    var context = getContext("2d");
                    context.reset();

                    var centreX = parent.width / 2;
                    var centreY = parent.height / 2;

                    context.beginPath();
                    context.fillStyle = parent.filament1Color
                    context.moveTo(centreX, centreY);
                    context.arc(centreX, centreY, (parent.width-4) / 2, 0, (Math.PI*(2.0*parent.filament1Percent/100)), false);
                    context.lineTo(centreX, centreY);
                    context.fill();
                }
            }
        }

        Rectangle {
            id: filament2_circle
            width: 30
            height: 30
            color: "#000000"
            radius: 15
            rotation: -90
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            border.color: "#ffffff"
            border.width: 2
            visible: bot.filament2Color

            property int filament2Percent: bot.filament2Percent

            property string filament2Color:
            {
                switch(bot.filament2Color)
                {
                    case 1:
                        "Red"
                        break;
                    case 2:
                        "Green"
                        break;
                    case 3:
                        "Blue"
                        break;
                    case 4:
                        "Yellow"
                        break;
                    case 5:
                        "Orange"
                        break;
                    case 6:
                        "Violet"
                        break;
                    case 0:
                        "transparent"
                        break;
                }
            }

            onFilament2PercentChanged: canvas2.requestPaint()

            Canvas {
                id: canvas2
                anchors.fill: parent
                onPaint:
                {
                    var context = getContext("2d");
                    context.reset();

                    var centreX = parent.width / 2;
                    var centreY = parent.height / 2;

                    context.beginPath();
                    context.fillStyle = parent.filament2Color
                    context.moveTo(centreX, centreY);
                    context.arc(centreX, centreY, (parent.width-4) / 2, 0, (Math.PI*(2.0*parent.filament2Percent/100)), false);
                    context.lineTo(centreX, centreY);
                    context.fill();
                }
            }
        }

        Image {
            id: connection_type_image
            x: 82
            y: 5
            width: 30
            height: 30
            anchors.horizontalCenterOffset: 40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
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
