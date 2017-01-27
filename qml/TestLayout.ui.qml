import QtQuick 2.5

Rectangle {
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
        x: 0
        y: 296
        width: 800
        height: 184
        color: "#ffffff"
        text: botIpAddr
        verticalAlignment: Text.AlignVCenter
        fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignHCenter
        font.family: "Tahoma"
        font.pixelSize: 64
    }

}
