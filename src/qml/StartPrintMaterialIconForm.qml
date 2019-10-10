import QtQuick 2.10

Item {
    id: startPrintMaterialIcon
    width: 82
    height: 82
    smooth: false

    property int filamentBayID: 0
    property real filamentRequired: 0

    property int filamentPercentRequired: {
        switch(filamentBayID) {
        case 1:
            (filamentRequired/
            materialPage.bay1.filamentQuantity) * 100
            break;
        case 2:
            (filamentRequired/
            materialPage.bay2.filamentQuantity) * 100
            break;
        default:
            0
            break;
        }
    }

    property string filamentAvailableColor: {
        switch(filamentBayID) {
        case 1:
            Qt.rgba(bot.spoolAColorRGB[0]/255,
                    bot.spoolAColorRGB[1]/255,
                    bot.spoolAColorRGB[2]/255,
                    0.5)
            break;
        case 2:
            Qt.rgba(bot.spoolBColorRGB[0]/255,
                    bot.spoolBColorRGB[1]/255,
                    bot.spoolBColorRGB[2]/255,
                    0.5)
            break;
        default:
            "#000000"
            break;
        }
    }

    property string filamentRequiredColor: {
        switch(filamentBayID) {
        case 1:
            Qt.rgba(bot.spoolAColorRGB[0]/255,
                    bot.spoolAColorRGB[1]/255,
                    bot.spoolAColorRGB[2]/255,
                    1)
            break;
        case 2:
            Qt.rgba(bot.spoolBColorRGB[0]/255,
                    bot.spoolBColorRGB[1]/255,
                    bot.spoolBColorRGB[2]/255,
                    1)
            break;
        default:
            "#000000"
            break;
        }
    }

    property int filamentPercentAvailable: {
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
        border.width: 2
        border.color: "#c4c4c4"
        property int fillPercentAvailable: filamentPercentAvailable
        property int fillPercentRequired: filamentPercentRequired
        property string fillAvailableColor: filamentAvailableColor
        property string fillRequiredColor: filamentRequiredColor

        onFillPercentAvailableChanged: canvas.requestPaint()
        onFillPercentRequiredChanged: canvas.requestPaint()
        onFillAvailableColorChanged: canvas.requestPaint()
        onFillRequiredColorChanged: canvas.requestPaint()

        Canvas {
            id: canvas
            smooth: true
            antialiasing: true
            rotation: -90
            anchors.fill: parent
            visible: {
                if(isLabsMaterial) {
                    false
                    return;
                }
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
                context.arc(centreX, centreY, parent.width*0.36,0,
                            filamentPercentAvailable*0.06283185, false);
                context.lineWidth = 10;
                context.lineCap = "round";
                context.strokeStyle = filamentAvailableColor;
                context.stroke()

                if(filamentPercentRequired > 0) {
                    var context1 = getContext("2d");
                    context1.beginPath();
                    context1.arc(centreX, centreY, parent.width*0.36,
                                filamentPercentAvailable*0.06283185,
                                (filamentPercentAvailable*0.06283185)-
                                (filamentPercentRequired*0.06283185), true);
                    context1.lineWidth = 10;
                    context1.lineCap = "round";
                    context1.strokeStyle = filamentRequiredColor;
                    context1.stroke()
                }
            }
        }
    }
}
