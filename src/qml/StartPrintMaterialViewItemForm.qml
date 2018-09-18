import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: item1
    width: 350
    height: 82

    property int filamentBayID: 0

    property bool isSpoolPresent: {
        switch(filamentBayID) {
        case 1:
            materialPage.bay1.spoolPresent
            break;
        case 2:
            materialPage.bay2.spoolPresent
            break;
        default:
            false
            break;
        }
    }

    property real materialRequired: 0.0
    property real materialAvailable: {
        switch(filamentBayID) {
        case 1:
            materialPage.bay1.filamentQuantity
            break;
        case 2:
            materialPage.bay2.filamentQuantity
            break;
        default:
            0.0
            break;
        }
    }

    property string materialName: {
        switch(filamentBayID) {
        case 1:
            materialPage.bay1.filamentMaterialName
            break;
        case 2:
            materialPage.bay2.filamentMaterialName
            break;
        default:
            "MAT"
            break;
        }
    }

    property string materialColorName: {
        switch(filamentBayID) {
        case 1:
            materialPage.bay1.filamentColorName
            break;
        case 2:
            materialPage.bay2.filamentColorName
            break;
        default:
            "COLOR"
            break;
        }
    }

    Image {
        id: materialErrorAlertIcon
        z: 1
        height: 20
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        width: 20
        antialiasing: false
        smooth: false
        source: "qrc:/img/alert.png"
        visible: true
    }

    StartPrintMaterialIconForm {
        id: startPrintMaterialIcon
        filamentBayID: parent.filamentBayID
        filamentRequired: materialRequired
    }

    ColumnLayout {
        id: columnLayout
        width: 218
        height: 82
        anchors.left: startPrintMaterialIcon.right
        anchors.leftMargin: 10

        RowLayout {
            id: matNameLayout
            width: children.width
            spacing: 10
            visible: true

            Text {
                id: materialNameText
                text: isSpoolPresent ?
                          materialName :
                          "NO MATERIAL DETECTED"
                font.capitalization: Font.AllUppercase
                smooth: false
                antialiasing: false
                font.letterSpacing: 3
                font.family: "Antennae"
                font.weight: Font.Bold
                font.pixelSize: 18
                color: "#cbcbcb"
            }

            Rectangle {
                id: divider_rectangle
                width: 1
                height: 25
                color: "#ffffff"
                visible: isSpoolPresent
            }

            Text {
                id: materialColorText
                text: materialColorName
                font.capitalization: Font.AllUppercase
                smooth: false
                antialiasing: false
                font.letterSpacing: 3
                font.family: "Antennae"
                font.weight: Font.Bold
                font.pixelSize: 18
                color: "#cbcbcb"
                visible: isSpoolPresent
            }
        }

        RowLayout {
            id: matRequiredLayout
            width: 100
            height: 25
            visible: isSpoolPresent

            Text {
                id: materialRequiredText
                text: materialRequired + "KG NEEDED"
                smooth: false
                antialiasing: false
                font.letterSpacing: 3
                font.family: "Antennae"
                font.weight: Font.Light
                font.pixelSize: 18
                color: "#ffffff"
            }
        }

        RowLayout {
            id: matAvailableLayout
            width: 100
            height: 25
            visible: isSpoolPresent

            Text {
                id: materialAvailableText
                text: materialAvailable + "KG REMAINING"
                smooth: false
                antialiasing: false
                font.letterSpacing: 3
                font.family: "Antennae"
                font.weight: Font.Light
                font.pixelSize: 18
                color: "#ffffff"
            }
        }
    }
}
