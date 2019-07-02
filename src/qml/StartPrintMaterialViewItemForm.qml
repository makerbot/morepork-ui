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
        width: 30
        height: 30
        anchors.left: parent.left
        anchors.leftMargin: -12
        anchors.top: parent.top
        anchors.topMargin: -12
        antialiasing: false
        smooth: false
        source: "qrc:/img/alert.png"
        visible: {
            if(filamentBayID == 1 &&
               materialPage.bay1.filamentMaterialName.toLowerCase() == print_model_material) {
                // Disable material quantity check before print for now
                // until the spool quantity reading becomes reliable
                   // && materialPage.bay1.filamentQuantity > materialRequired) {
                false
            }
            else if(filamentBayID == 2 &&
                    materialPage.bay2.filamentMaterialName.toLowerCase() == print_support_material) {
                // Disable material quantity check before print for now
                // until the spool quantity reading becomes reliable
                // && materialPage.bay2.filamentQuantity > materialRequired) {
                false
            }
            else {
                true
            }
        }
    }

    StartPrintMaterialIconForm {
        id: startPrintMaterialIcon
        filamentBayID: parent.filamentBayID
        filamentRequired: materialRequired
    }

    Item {
        id: materialItem
        width: 218
        height: 82
        anchors.left: startPrintMaterialIcon.right
        anchors.leftMargin: 12

        Text {
            id: materialNameOrBayIDText
            text: isSpoolPresent ?
                      materialName :
                      qsTr("BAY %1").arg(filamentBayID)
            anchors.top: parent.top
                      anchors.topMargin: 8
            font.capitalization: Font.AllUppercase
            smooth: false
            antialiasing: false
            font.letterSpacing: 3
            font.family: defaultFont.name
            font.weight: Font.Bold
            font.pixelSize: 17
            color: "#cbcbcb"
        }

        Text {
            id: materialColorText
            text: materialColorName
            anchors.top: materialNameOrBayIDText.bottom
            anchors.topMargin: 8
            font.capitalization: Font.AllUppercase
            smooth: false
            antialiasing: false
            font.letterSpacing: 3
            font.family: defaultFont.name
            font.weight: Font.Bold
            font.pixelSize: 17
            color: "#cbcbcb"
            visible: isSpoolPresent
        }

        Text {
            id: noMaterialText
            width: 210
            text: qsTr("NO MATERIAL DETECTED")
            anchors.top: materialNameOrBayIDText.bottom
            anchors.topMargin: 8
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.capitalization: Font.AllUppercase
            smooth: false
            antialiasing: false
            font.letterSpacing: 3
            font.family: defaultFont.name
            font.weight: Font.Normal
            font.pixelSize: 18
            color: "#cbcbcb"
            lineHeight: 1.3
            visible: !isSpoolPresent
        }

        Text {
            id: materialRequiredText
            text: {
                if(materialColorName != "Reading Spool...") {
                    qsTr("%1KG OF %2KG").arg(materialRequired).arg(materialAvailable)
                } else {
                    ""
                }
            }
            anchors.top: materialColorText.bottom
            anchors.topMargin: 8
            smooth: false
            antialiasing: false
            font.letterSpacing: 1
            font.family: defaultFont.name
            font.weight: Font.Light
            font.pixelSize: 18
            color: "#ffffff"
            visible: isSpoolPresent
        }
    }
}
