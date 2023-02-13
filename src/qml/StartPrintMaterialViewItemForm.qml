import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: item1
    width: 350
    height: 82

    property int filamentBayID: 0

    property bool isLabsMaterial: {
        switch(filamentBayID) {
        case 1:
            materialPage.bay1.usingExperimentalExtruder
            break;
        case 2:
            materialPage.bay2.usingExperimentalExtruder
            break;
        default:
            false
            break;
        }
    }

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

    StartPrintMaterialIconForm {
        id: startPrintMaterialIcon
        filamentBayID: parent.filamentBayID
        filamentRequired: materialRequired
    }

    Image {
        id: materialErrorAlertIcon
        z: 1
        width: sourceSize.width
        height: sourceSize.height
        anchors.right: startPrintMaterialIcon.right
        anchors.bottom: startPrintMaterialIcon.bottom
        antialiasing: false
        smooth: false
        source: "qrc:/img/error_image_overlay.png"
        visible: {
            if(filamentBayID == 1 &&
               materialPage.bay1.filamentMaterial == print_model_material ||
               materialPage.bay1.usingExperimentalExtruder) {
                // Disable material quantity check before print for now
                // until the spool quantity reading becomes reliable
                   // && materialPage.bay1.filamentQuantity > materialRequired) {
                false
            }
            else if(filamentBayID == 2 &&
                    materialPage.bay2.filamentMaterial == print_support_material) {
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

    Item {
        id: materialItem
        width: 218
        height: 82
        anchors.left: startPrintMaterialIcon.right
        anchors.leftMargin: 12

        TextSubheader {
            id: materialNameOrBayIDText
            text: {
                if(isLabsMaterial) {
                    qsTr("NOT USING BAY %1").arg(filamentBayID)
                } else if(isSpoolPresent || !bot.hasFilamentBay) {
                    materialName
                } else {
                    qsTr("BAY %1").arg(filamentBayID)
                }
            }
            anchors.top: parent.top
            anchors.topMargin: 8
            font.capitalization: Font.AllUppercase
            font.weight: Font.Bold
        }

        TextSubheader {
            id: materialColorText
            text: materialColorName
            anchors.top: materialNameOrBayIDText.bottom
            anchors.topMargin: 8
            font.capitalization: Font.AllUppercase
            font.weight: Font.Bold
            visible: {
                if(isLabsMaterial) {
                    false
                } else {
                    isSpoolPresent
                }
            }
        }

        TextSubheader {
            id: noMaterialText
            width: 210
            text: isLabsMaterial ?
                      qsTr("LABS MATERIAL LOADED") :
                      qsTr("NO MATERIAL DETECTED")
            anchors.top: materialNameOrBayIDText.bottom
            anchors.topMargin: 8
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            font.capitalization: Font.AllUppercase
            font.weight: Font.Normal
            visible: bot.hasFilamentBay && (!isSpoolPresent || isLabsMaterial)
        }

        TextSubheader {
            id: materialRequiredText
            text: {
                if(materialColorName != "Reading Spool...") {
                    qsTr("%1KG OF %2KG").arg(materialRequired).arg(materialAvailable)
                } else {
                    emptyString
                }
            }
            anchors.top: materialColorText.bottom
            anchors.topMargin: 8
            font.weight: Font.Light
            visible: {
                if(isLabsMaterial) {
                    false
                } else {
                    isSpoolPresent
                }
            }
        }
    }
}
