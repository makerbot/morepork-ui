import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import MachineTypeEnum 1.0

Item {
    id: startPrintMaterialIcon
    width: 65
    height: 65
    smooth: false

    property int filamentBayID: 0
    property real filamentRequired: 0
    property bool noSpoolInfo: (bot.machineType == MachineType.Magma) || !bot.hasFilamentBay
    property bool materialMatch: false

    property int filamentPercentRequired: {
        if(noSpoolInfo) {
            (filamentRequired*2) * 100
        }
        else {
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
            if(noSpoolInfo) {
                "#E85A4F"
            }
            else {
                Qt.rgba(bot.spoolAColorRGB[0]/255,
                        bot.spoolAColorRGB[1]/255,
                        bot.spoolAColorRGB[2]/255,
                        1)
            }
            break;
        case 2:
            if(noSpoolInfo) {
                "#FFFFFF"
            }
            else {
                Qt.rgba(bot.spoolBColorRGB[0]/255,
                        bot.spoolBColorRGB[1]/255,
                        bot.spoolBColorRGB[2]/255,
                        1)
            }
            break;
        default:
            "#FFFFFF"
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
        id: outer_ring
        anchors.fill: parent
        color: "#00000000"
        radius: width/2
        antialiasing: false
        smooth: false
        anchors.top: parent.top
        anchors.topMargin: 0
        visible: true
        border.width: 2
        border.color: "#ffffff"
    }
    Rectangle {
        id: inner_ring
        width: outer_ring.width/(2.4)
        height: outer_ring.height/(2.4)
        radius: width/2
        color: "#00000000"
        border.color: "#ffffff"
        border.width: 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        id: filament_extension
        width: 2
        height: outer_ring.radius
        color: "#ffffff"
        anchors.top: outer_ring.top
        anchors.left: outer_ring.left
    }

    Rectangle {
        id: material_amount_ring
        anchors.fill: outer_ring
        color: "#00000000"
        antialiasing: false
        smooth: false
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
                // Check material match before displaying
                if(isLabsMaterial || !materialMatch) {
                    false
                } else if(noSpoolInfo) {
                    true
                } else {
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
            }
            onPaint: {
                var context = getContext("2d");
                context.reset();
                var centreX = parent.width * 0.5;
                var centreY = parent.height * 0.5;
                if(noSpoolInfo) {
                    // Do not know filament spool amount
                    if(filamentPercentRequired > 0) {

                        context.beginPath();
                        //0.06283185 = PI*2/100
                        context.arc(centreX, centreY, parent.width*0.34,
                                    0,filamentPercentRequired*0.06283185, false);
                        context.lineWidth = 10;
                        context.lineCap = "round";
                        context.strokeStyle = filamentRequiredColor;
                        context.stroke()
                    }
                }
                else {

                    context.beginPath();
                    //0.06283185 = PI*2/100
                    context.arc(centreX, centreY, parent.width*0.34,0,
                                filamentPercentAvailable*0.06283185, false);
                    context.lineWidth = 10;
                    context.lineCap = "round";
                    context.strokeStyle = filamentAvailableColor;
                    context.stroke()

                    if(filamentPercentRequired > 0) {
                        var context1 = getContext("2d");
                        context1.beginPath();
                        context1.arc(centreX, centreY, parent.width*0.34,
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
}
