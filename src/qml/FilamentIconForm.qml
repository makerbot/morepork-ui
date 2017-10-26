import QtQuick 2.4

Item {
    id: filament_item
    width: 30
    height: 30
    anchors.verticalCenter: parent.verticalCenter

    property int filamentColor
    property int filamentPercent

    Image {
        id: unknown_filament_image
        anchors.fill: parent
        source: "qrc:/img/unknown_filament.png"
        visible: !filamentColor
    }

    Rectangle {
        id: filament_circle
        color: "#000000"
        radius: 15
        anchors.fill: parent
        rotation: -90
        border.color: "#ffffff"
        border.width: 2
        visible: filamentColor

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

        Canvas {
            id: canvas
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
                context.arc(centreX, centreY, (parent.width-4) / 2, 0, (Math.PI*(2.0*parent.fillPercent/100)), false);
                context.lineTo(centreX, centreY);
                context.fill();
            }
        }
    }
}
