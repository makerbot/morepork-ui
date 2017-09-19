import QtQuick 2.5

Rectangle {
    property alias mouseArea_cancelPrint: mouseArea_cancelPrint

    width: 800
    color: "#000000"

    Flickable {
        id: flickable
        x: 0
        y: 0
        width: 800
        height: 300
        contentHeight: 300
        contentWidth: 1800
        flickableDirection: Flickable.HorizontalFlick

        Rectangle {
            id: rectangle
            x: 26
            y: 28
            width: 200
            height: 200
            color: "#ff0000"

            MouseArea {
                id: mouseArea_cancelPrint
                anchors.fill: parent

                Text {
                    id: text1
                    x: 79
                    y: 85
                    text: qsTr("Cancel\nAnnuler\nCancelar")
                    horizontalAlignment: Text.AlignHCenter
                    font.family: "Arial"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 30
                }
            }
        }

        Rectangle {
            id: rectangle1
            x: 250
            y: 80
            width: 200
            height: 200
            color: "#2d965c"
        }

        Rectangle {
            id: rectangle2
            x: 468
            y: 28
            width: 200
            height: 200
            color: "#223bbe"
        }

        Rectangle {
            id: rectangle3
            x: 684
            y: 80
            width: 200
            height: 200
            color: "#d5ff00"
        }

        Rectangle {
            id: rectangle4
            x: 909
            y: 28
            width: 200
            height: 200
            color: "#ff0000"
        }

        Rectangle {
            id: rectangle5
            x: 1133
            y: 80
            width: 200
            height: 200
            color: "#2d965c"
        }

        Rectangle {
            id: rectangle6
            x: 1351
            y: 28
            width: 200
            height: 200
            color: "#223bbe"
        }

        Rectangle {
            id: rectangle7
            x: 1567
            y: 80
            width: 200
            height: 200
            color: "#d5ff00"
        }
    }

    Text {
        id: ip_address
        x: 400
        y: 400
        width: 400
        height: 83
        color: "#ffffff"
        text: bot.net.ipAddr
        font.pointSize: 48
        verticalAlignment: Text.AlignVCenter
        fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignHCenter
        font.family: "Tahoma"
    }

    Text {
        id: name
        x: 0
        y: 300
        width: 800
        height: 94
        color: "#ffffff"
        text: bot.name
        font.pointSize: 64
        font.family: "Tahoma"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.Fit
    }

    Text {
        id: version
        x: 114
        y: 400
        width: 285
        height: 83
        color: "#ffffff"
        text: bot.version
        font.pointSize: 48
        fontSizeMode: Text.Fit
        font.family: "Tahoma"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
