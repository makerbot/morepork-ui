import QtQuick 2.10

Item {
    id: filament_item
    width: 22
    height: 22
    smooth: false
    anchors.verticalCenter: parent.verticalCenter

    property int filamentBayID: 0
    property bool spoolPresent: {
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
            "#ffffff"
            break;
        }
    }

    Rectangle {
        id: filament_circle
        color: "#00000000"
        radius: 11
        smooth: true
        antialiasing: true
        anchors.fill: parent
        border.color: filamentColor
        border.width: 7
        visible: spoolPresent
    }
}
