import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: item1
    width: 350
    height: 65

    property int filamentBayID: 0
    property bool materialMismatchCheck: {
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

    property string materialRequiredName: {
        switch(filamentBayID) {
        case 1:
            print_model_material_name
            break;
        case 2:
            print_support_material_name
            break;
        default:
            "MAT"
            break;
        }
    }

    property string materialAvailableName: {
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
        materialMatch: !materialMismatchCheck
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
        visible: materialMismatchCheck
    }

    Item {
        id: materialItem
        width: 218
        height: 82
        anchors.left: startPrintMaterialIcon.right
        anchors.leftMargin: 20

        TextSubheader {
            id: materialNameOrBayIDText
            text: {
                if(isLabsMaterial) {
                    qsTr("NOT USING BAY %1").arg(filamentBayID)
                } else {//if(isSpoolPresent || !bot.hasFilamentBay) {
                    materialRequiredName
                } /*else {
                    qsTr("BAY %1").arg(filamentBayID)
                }*/
            }
            anchors.top: parent.top
            anchors.topMargin: 8
            font.capitalization: Font.AllUppercase
            font.weight: Font.Bold
        }

        /*TextSubheader {
            id: materialColorText
            text: materialColorName
            anchors.top: materialNameOrBayIDText.bottom
            anchors.topMargin: 8
            font.capitalization: Font.AllUppercase
            font.weight: Font.Bold
            visible: {
                if(isLabsMaterial || materialMismatchCheck) {
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
            visible: false//bot.hasFilamentBay && (!isSpoolPresent || isLabsMaterial)
        }*/

        TextSubheader {
            id: materialRequiredText
            text: qsTr("%1 GRAMS").arg(materialRequired*1000)
            anchors.top: materialNameOrBayIDText.bottom
            anchors.topMargin: 8
            font.weight: Font.Light
            opacity: 0.7
            visible: {
                if(isLabsMaterial) {
                    false
                } else {
                    !materialMismatchCheck
                }
            }
        }
    }
}
