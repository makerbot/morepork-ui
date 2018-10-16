import QtQuick 2.10

Item {
    id: materialIcon
    width: 164
    height: 164
    smooth: false

    property int filamentBayID: 0
    property string filamentColor: {
        switch(filamentBayID) {
        case 1:
            Qt.rgba(bot.spoolAColorRGB[0]/255,
                    bot.spoolAColorRGB[1]/255,
                    bot.spoolAColorRGB[2]/255)
            break;
        case 2:
            Qt.rgba(bot.spoolBColorRGB[0]/255,
                    bot.spoolBColorRGB[1]/255,
                    bot.spoolBColorRGB[2]/255)
            break;
        default:
            "#000000"
            break;
        }
    }

    property int filamentPercent: {
        switch(filamentBayID) {
        case 1:
            (bot.spoolAAmountRemaining/
            bot.spoolAOriginalAmount) * 100
            break;
        case 2:
            (bot.spoolBAmountRemaining/
            bot.spoolBOriginalAmount) * 100
            break;
        default:
            0
            break;
        }
    }

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
                switch(filamentBayID) {
                     case 1:
                         bot.filamentBayATagPresent
                         break;
                     case 2:
                         bot.filamentBayBTagPresent
                         break;
                     default:
                         false
                         break;
                     }
            }
            onPaint: {
                var context = getContext("2d");
                context.reset();
                var centreX = parent.width * 0.5;
                var centreY = parent.height * 0.5;
                context.beginPath();
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
