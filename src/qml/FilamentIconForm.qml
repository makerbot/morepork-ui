import QtQuick 2.10

Item {
    id: filament_item
    width: 22
    height: 22
    smooth: false

    property int filamentBayID: 0
    property bool spoolPresent: {
        switch(filamentBayID) {
             case 1:
                 materialPage.bay1.usingExperimentalExtruder ?
                         true : materialPage.bay1.spoolPresent
                 break;
             case 2:
                 materialPage.bay2.usingExperimentalExtruder ?
                         true : materialPage.bay2.spoolPresent
                 break;
             default:
                 false
                 break;
        }
    }

    property string filamentColor: {
        switch(filamentBayID) {
        case 1:
            materialPage.bay1.filamentColor
            break;
        case 2:
            materialPage.bay2.filamentColor
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
