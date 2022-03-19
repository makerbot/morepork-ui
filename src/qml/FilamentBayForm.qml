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
        if(usingExperimentalExtruder) {
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
        if(usingExperimentalExtruder) {
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
        switch(filamentMaterialCode) {
        case 1:
            "PLA"
            break;
        case 2:
            "Tough"
            break;
        case 3:
            "PVA"
            break;
        case 4:
            "PETG"
            break;
        case 5:
            "ABS"
            break;
        case 6:
            "HIPS"
            break;
        case 7:
            "PVA-M"
            break;
        case 8:
            "SR-30"
            break;
        case 9:
            "ASA"
            break;
        case 10:
            "ESD"
            break;
        case 11:
            "NYLON"
            break;
        case 12:
            "PC-ABS"
            break;
        case 13:
            "PC-ABS-FR"
            break;
        case 14:
            "NYLON-CF"
            break;
        case 15:
            "TPU"
            break;
        case 16:
            "NYLON-12-CF"
            break;
        case 17:
            "RapidRinse"
            break;
        case 18:
            "ABS-R"
            break;
        case 0:
        default:
            "UNKNOWN"
            break;
        }
    }

    property bool isUnknownMaterial: {
        (usingExperimentalExtruder ||
         settings.getSkipFilamentNags()) ?
              false :
              filamentMaterialName == "UNKNOWN"
    }

    property bool isMaterialValid: {
        (usingExperimentalExtruder ||
         settings.getSkipFilamentNags()) ?
              true :
              (goodMaterialsList.indexOf(filamentMaterialName) >= 0)
    }

    function checkSliceValid(material) {
        return (usingExperimentalExtruder ?
                    true :
                    (goodMaterialsList.indexOf(material) >= 0))
    }

    property var goodMaterialsList: {
        // The materials valid for a bay/extruder depends
        // on the extruder attached. The materials are
        // extruder specific and not machine specific, but
        // the extruders are themselves machine specific,
        // so in theory the materials are also machine
        // specific. e.g. hot extruders can never be attached
        // to V1 printers so ABS/SR-30 can't be used on V1
        // without some warranty voiding creativity. This logic
        // shouldn't get too broken since an extruder should
        // always be attached to a printer anytime the user
        // wants to print or load which are the only times the
        // material checks can block something.
        switch(filamentBayID) {
        case 1:
            switch (bot.extruderAType) {
            case ExtruderType.MK14:
                ["PLA", "Tough", "PETG", "NYLON", "TPU"]
                break;
            case ExtruderType.MK14_HOT:
                ["ABS", "ASA", "PC-ABS", "PC-ABS-FR", "ABS-R"]
                break;
            case ExtruderType.MK14_COMP:
                if(bot.machineType == MachineType.Fire) {
                    ["PLA", "Tough", "PETG", "ESD", "NYLON", "TPU", "NYLON-CF", "NYLON-12-CF"]
                } else {
                    ["PLA", "Tough", "PETG", "ESD", "NYLON", "TPU", "NYLON-CF", "NYLON-12-CF", "ABS", "ASA", "PC-ABS", "PC-ABS-FR"]
                }
                break;
            default:
                []
                break;
            }
            break;
        case 2:
            switch (bot.extruderBType) {
            case ExtruderType.MK14:
                ["PVA"]
                break;
            case ExtruderType.MK14_HOT:
                ["SR-30", "HIPS", "RapidRinse"]
                break;
            default:
                []
                break;
            }
            break;
        default:
            []
            break;
        }
    }

    property string printMaterialName : {
        switch(filamentBayID) {
        case 1:
            printPage.print_model_material
            break;
        case 2:
            printPage.print_support_material
            break;
        default:
            ""
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
            false
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
    property string tagUID: bot["filamentBay%1TagUID".arg(idxAsAxis)]
    property bool tagVerified: bot["filamentBay%1TagVerified".arg(idxAsAxis)]
    property bool tagVerificationDone: bot["filamentBay%1TagVerificationDone".arg(idxAsAxis)]
    property bool spoolPresent: bot["filamentBay%1TagPresent".arg(idxAsAxis)]
    property bool extruderFilamentPresent: bot["extruder%1FilamentPresent".arg(idxAsAxis)]
    property string filamentColorName: bot["spool%1ColorName".arg(idxAsAxis)]
    property int filamentMaterialCode: bot["spool%1Material".arg(idxAsAxis)]
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
            state: {
                if(!extruderPresent) {
                    "no_extruder_detected"
                }
            }
        }

        // Buttons
        ColumnLayout {
            width: 300
            height: 60
            spacing: 16
            smooth: false
            antialiasing: false

            ButtonRectanglePrimary {
                id: loadButton
                text: qsTr("LOAD")
                logKey: text
                visible: !extruderFilamentPresent
            }

            ButtonRectangleSecondary {
                id: unloadButton
                text: qsTr("UNLOAD")
                logKey: text
            }

            ButtonRectangleSecondary {
                id: purgeButton
                text: qsTr("PURGE")
                logKey: text
                visible: extruderFilamentPresent
            }
        }
    }
}
