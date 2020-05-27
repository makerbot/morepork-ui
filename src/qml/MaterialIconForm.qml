import QtQuick 2.10

Item {
    id: materialIcon
    width: 164
    height: 164
    smooth: false

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
        border.width: 4
        border.color: "#c4c4c4"
        property int fillPercent: filamentPercent
        property string fillColor: filamentColor

        onFillPercentChanged: canvas.requestPaint()
        onFillColorChanged: canvas.requestPaint()

        Canvas {
            id: canvas
            smooth: true
            antialiasing: true
            rotation: -90
            anchors.fill: parent
            visible: {
                usingExperimentalExtruder ? true : spoolPresent
            }
            onPaint: {
                var context = getContext("2d");
                context.reset();
                var centreX = parent.width * 0.5;
                var centreY = parent.height * 0.5;
                context.beginPath();
                if(usingExperimentalExtruder) {
                    context.fillStyle = parent.fillColor;
                    context.moveTo(centreX, centreY);
                    //0.06283185 = PI*2/100
                    context.arc(centreX, centreY, parent.width*0.40, 0,
                                parent.fillPercent*0.06283185, false);
                    context.lineTo(centreX, centreY);
                    context.fill();
                } else {
                    //0.06283185 = PI*2/100
                    context.arc(centreX, centreY, parent.width*0.40, 0,
                                parent.fillPercent*0.06283185, false);
                    context.lineWidth = 12;
                    context.lineCap = "round";
                    context.strokeStyle = parent.fillColor;
                    context.stroke()
                }
            }
        }
    }
}
