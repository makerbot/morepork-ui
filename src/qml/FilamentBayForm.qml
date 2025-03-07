import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ExtruderTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import MachineTypeEnum 1.0

Item {
    id: filamentBayBaseItem
    height: 408
    width: 360
    smooth: false
    antialiasing: false
    property alias attachExtruderButton: attachExtruderButton
    property alias loadButton: loadButton
    property alias unloadButton: unloadButton
    property alias purgeButton: purgeButton

    property int filamentBayID: 0

    property string idxAsAxis: {
        switch (filamentBayID) {
            case 1:
                "A"
                break
            case 2:
                "B"
                break
            default:
                "A"
        }
    }

    property string filamentColor: {
        if(!bot.hasFilamentBay || usingExperimentalExtruder) {
            expExtruderColor
        } else {
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
    }

    property int filamentPercent: {
        if(!bot.hasFilamentBay || usingExperimentalExtruder) {
            100
        } else {
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
    }

    property string filamentMaterialName: {
        if (!bot.hasFilamentBay || bot.loadedMaterialNames[filamentBayID - 1] != 'UNKNOWN') {
            bot.loadedMaterialNames[filamentBayID - 1]
        } else {
            bot['spool%1MaterialName'.arg(idxAsAxis)]
        }
    }

    property string filamentMaterial: {
        if (!bot.hasFilamentBay || bot.loadedMaterials[filamentBayID - 1] != 'unknown') {
            bot.loadedMaterials[filamentBayID - 1]
        } else {
            bot['spool%1Material'.arg(idxAsAxis)]
        }
    }

    property bool skipMaterialChecks: {
        usingExperimentalExtruder || !bot.hasFilamentBay ||
        settings.getSkipFilamentNags()
    }

    property bool isUnknownMaterial: {
        !skipMaterialChecks && filamentMaterial == "unknown"
    }

    property bool isMaterialValid: {
        skipMaterialChecks ||
        supportedMaterials.indexOf(filamentMaterial) >= 0
    }

    property bool materialError: {
        spoolPresent && !isMaterialValid
    }

    function checkSliceValid(material) {
        return usingExperimentalExtruder ||
            supportedMaterials.indexOf(material) >= 0;
    }

    property var supportedMaterials: bot["extruder%1SupportedMaterials".arg(idxAsAxis)]

    property string printMaterial : {
        switch(filamentBayID) {
        case 1:
            printPage.print_model_material
            break;
        case 2:
            printPage.print_support_material
            break;
        default:
            emptyString
            break;
        }
    }

    property string printMaterialName : {
        switch(filamentBayID) {
        case 1:
            printPage.print_model_material_name
            break;
        case 2:
            printPage.print_support_material_name
            break;
        default:
            emptyString
            break;
        }
    }

    property bool usingExperimentalExtruder: {
        switch(filamentBayID) {
        case 1:
            bot.extruderAType == ExtruderType.MK14_EXP ||
            bot.extruderAType == ExtruderType.MK14_HOT_E
            break;
        case 2:
            bot.extruderBType == ExtruderType.MK14_EXP ||
            bot.extruderBType == ExtruderType.MK14_HOT_E
            break;
        default:
            false
            break;
        }
    }

    property string expExtruderColor: "#FF4800"

    property bool extruderPresent: bot["extruder%1Present".arg(idxAsAxis)]
    property int extruderTemperature: bot["extruder%1CurrentTemp".arg(idxAsAxis)]
    property bool spoolDetailsReady: bot["spool%1DetailsReady".arg(idxAsAxis)]
    property bool spoolPresent: bot["filamentBay%1TagPresent".arg(idxAsAxis)]
    property bool extruderFilamentPresent: bot["extruder%1FilamentPresent".arg(idxAsAxis)]
    property bool bayFilamentPresent: bot["filamentBay%1FilamentPresent".arg(idxAsAxis)]
    property string filamentColorName: bot["spool%1ColorName".arg(idxAsAxis)]
    property real filamentLength: bot["spool%1AmountRemaining".arg(idxAsAxis)]/10
    // convert length from cm to mm, convert linear density from g/mm to kg/mm, multiply to yield mass in kg
    property real filamentQuantity: ((filamentLength*10) * (bot["spool%1LinearDensity".arg(idxAsAxis)]/1000)).toFixed(3)

    Rectangle {
        color: "#000000"
        anchors.fill: parent
    }

    ColumnLayout {
        anchors.fill: parent

        ExtruderStatus {

        }

        MaterialStatus {

        }

        // Buttons
        ColumnLayout {
            width: 300
            height: 60
            spacing: 16
            smooth: false
            antialiasing: false

            ButtonRectanglePrimary {
                id: attachExtruderButton
                text: qsTr("ATTACH EXTRUDER")
                visible: !extruderPresent
            }

            // This is just an informational button and cannot
            // be clicked. Why you ask?
            ButtonRectanglePrimary {
                id: materialErrorInformationalButton
                text: qsTr("MATERIAL INCOMPATIBLE")
                enabled: false
                visible: extruderPresent && materialError
            }

            ButtonRectanglePrimary {
                id: dummySpacingButton
                opacity: 0
                enabled: false
                visible: attachExtruderButton.visible ||
                         materialErrorInformationalButton.visible
            }

            // These all are relevant only when an extruder is installed
            // and there is no material error. Unload will be disabled
            // when there is a material error which seems counter-intuitive
            // but the user wouldn't have been able to load an incompatible
            // material into the extruder in the first place to end up wanting
            // to unload it later. Material error concept is only applicable
            // for printers with filament bay.
            ColumnLayout {
                spacing: 16
                smooth: false
                antialiasing: false
                visible: extruderPresent && !materialError

                ButtonRectanglePrimary {
                    id: loadButton
                    text: qsTr("LOAD")
                    visible: !extruderFilamentPresent ||
                             (!bot.hasFilamentBay && filamentMaterial == "unknown")
                }

                ButtonRectangleSecondary {
                    id: unloadButton
                    text: qsTr("UNLOAD")
                }

                ButtonRectangleSecondary {
                    id: purgeButton
                    text: qsTr("PURGE")
                    visible: bot.hasFilamentBay ? extruderFilamentPresent :
                             (extruderFilamentPresent && filamentMaterial != "unknown")
                }
            }
        }
    }
}
