import QtQuick 2.5

Rectangle {
    width: 800
    color: "#000000"
    Flickable {
        id: flickable
        x: 340
        y: 0
        width: 460
        height: 300
        contentHeight: 300
        contentWidth: 900
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
    }

    Flickable {
        id: flickable1
        x: 0
        y: 0
        width: 300
        height: 480
        contentHeight: 900
        contentWidth: 300
        flickableDirection: Flickable.VerticalFlick

        Rectangle {
            id: rectangle4
            x: 16
            y: 14
            width: 200
            height: 200
            color: "#ffffff"
        }

        Rectangle {
            id: rectangle5
            x: 82
            y: 237
            width: 200
            height: 200
            color: "#a4a4a4"
        }

        Rectangle {
            id: rectangle6
            x: 16
            y: 461
            width: 200
            height: 200
            color: "#727272"
        }

        Rectangle {
            id: rectangle7
            x: 82
            y: 682
            width: 200
            height: 200
            color: "#404040"
        }
    }

}
