import QtQuick 2.4

Item {
    id: filament_item
    width: 22
    height: 22
    smooth: false
    anchors.verticalCenter: parent.verticalCenter

    property int filamentColor
    property int filamentPercent

    Rectangle {
        id: filament_circle
        color: "#00000000"
        radius: 11
        smooth: true
        antialiasing: true
        anchors.fill: parent
        border.color: "#ffffff"
        border.width: 1
        visible: true

        property int fillPercent: filamentPercent
        property string fillColor:
        {
            switch(filamentColor)
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

        onFillPercentChanged: canvas.requestPaint()
        onFillColorChanged: canvas.requestPaint()

        Text {
            id: unknown_filament_text
            color: "#ffffff"
            text: "?"
            smooth: true
            antialiasing: true
            anchors.verticalCenterOffset: 2
            anchors.horizontalCenterOffset: 1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.family: "Antenna"
            font.weight: Font.Light
            font.pixelSize: 18
            visible: !filamentColor
        }

        Canvas {
            id: canvas
            smooth: true
            antialiasing: true
            rotation: -90
            anchors.fill: parent
            onPaint:
            {
                var context = getContext("2d");
                context.reset();

                var centreX = parent.width / 2;
                var centreY = parent.height / 2;

                context.beginPath();
                context.fillStyle = parent.fillColor
                context.moveTo(centreX, centreY);
                context.arc(centreX, centreY, (parent.width-2) / 2, 0, (Math.PI*(2.0*parent.fillPercent/100)), false);
                context.lineTo(centreX, centreY);
                context.fill();
            }
        }

    }
}
