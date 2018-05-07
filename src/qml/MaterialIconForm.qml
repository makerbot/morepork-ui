import QtQuick 2.4

Item {
    id: materialIcon
    width: 164
    height: 164
    smooth: false

    property int filamentColor
    property int filamentPercent
    property alias filamentType: filament_type_text.text

    Rectangle {
        id: base_circle
        anchors.fill: parent
        color: "#00000000"
        radius: 82
        antialiasing: false
        smooth: false
        anchors.top: parent.top
        anchors.topMargin: 0
        visible: true
        border.width: 2
        border.color: "#484848"
        property int fillPercent: filamentPercent
        property string fillColor: {
            switch(filamentColor) {
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
            id: filament_type_text
            color: "#ffffff"
            text: "MAT"
            font.letterSpacing: 4
            smooth: true
            antialiasing: true
            anchors.verticalCenterOffset: 2
            anchors.horizontalCenterOffset: 1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.family: "Antenna"
            font.weight: Font.Bold
            font.pixelSize: 18
            visible: true
        }
        Canvas {
            id: canvas
            smooth: true
            antialiasing: true
            rotation: -90
            anchors.fill: parent
            onPaint: {
                var context = getContext("2d");
                context.reset();
                var centreX = parent.width * 0.5;
                var centreY = parent.height * 0.5;
                context.beginPath();
                //0.06283185 = PI*2/100
                context.arc(centreX, centreY, parent.width*0.5-13, 0,
                            parent.fillPercent*0.06283185, false);
                context.lineWidth = 7;
                context.lineCap = "round";
                context.strokeStyle = parent.fillColor;
                context.stroke()
            }
        }
    }
}
