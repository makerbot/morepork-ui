import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ExtruderTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import MachineTypeEnum 1.0

Item {
    id: filamentBayBaseItem
    width: 800
    height: 180
    smooth: false
    antialiasing: false
    property alias loadButton: loadButton
    property alias unloadButton: unloadButton

    property int filamentBayID: 0
    property bool spoolDetailsReady: {
        switch(filamentBayID) {
        case 1:
            bot.spoolADetailsReady
            break;
        case 2:
            bot.spoolBDetailsReady
            break;
        default:
            false
            break;
        }
    }

    property string tagUID: {
        switch(filamentBayID) {
        case 1:
            bot.filamentBayATagUID
            break;
        case 2:
            bot.filamentBayBTagUID
            break;
        default:
            "Unknown"
            break;
        }
    }

    property bool tagVerified: {
        switch(filamentBayID) {
        case 1:
            bot.filamentBayATagVerified
            break;
        case 2:
            bot.filamentBayBTagVerified
            break;
        default:
            false
            break;
        }
    }

    property bool tagVerificationDone: {
        switch(filamentBayID) {
        case 1:
            bot.filamentBayATagVerificationDone
            break;
        case 2:
            bot.filamentBayBTagVerificationDone
            break;
        default:
            false
            break;
        }
    }

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

    property bool extruderFilamentPresent: {
        switch(filamentBayID) {
        case 1:
            bot.extruderAFilamentPresent
            break;
        case 2:
            bot.extruderBFilamentPresent
            break;
        default:
            false
            break;
        }
    }

    property string filamentColorName: {
        switch(filamentBayID) {
        case 1:
            bot.spoolAColorName
            break;
        case 2:
            bot.spoolBColorName
            break;
        default:
            "Unknown Color"
            break;
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

    property int filamentMaterialCode: {
        switch(filamentBayID) {
        case 1:
            bot.spoolAMaterial
            break;
        case 2:
            bot.spoolBMaterial
            break;
        default:
            0
            break;
        }
    }

    property real filamentLength: {
        switch(filamentBayID) {
        case 1:
            bot.spoolAAmountRemaining/10
            break;
        case 2:
            bot.spoolBAmountRemaining/10
            break;
        default:
            0.0
            break;
        }
    }

    property real filamentQuantity: {
        // convert length from cm to mm
        // convert linear density from g/mm to kg/mm
        // multiply to yield mass in kg

        switch(filamentBayID) {
        case 1:
            ((filamentLength*10) * (bot.spoolALinearDensity/1000)).toFixed(3)
            break;
        case 2:
            ((filamentLength*10) * (bot.spoolBLinearDensity/1000)).toFixed(3)
            break;
        default:
            0
            break;
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
                    ["PLA", "Tough", "PETG", "ESD", "NYLON", "TPU", "NYLON-CF", "NYLON-12-CF", "ABS", "ASA", "PC-ABS", "PC-ABS-FR", "ABS-R"]
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

    MaterialIcon {
        id: materialIconLarge
        anchors.left: parent.left
        anchors.leftMargin: 100
        anchors.verticalCenter: parent.verticalCenter
        smooth: false
        antialiasing: false

        Image {
            id: materialErrorAlertIcon
            z: 1
            width: 30
            height: 30
            anchors.bottom: materialType_text.top
            anchors.bottomMargin: 7
            anchors.horizontalCenter: materialType_text.horizontalCenter
            antialiasing: false
            smooth: false
            source: "qrc:/img/alert.png"
            visible: !isMaterialValid && !isUnknownMaterial && spoolPresent
        }

        Text {
            id: materialType_text
            color: "#ffffff"
            text: {
                if(usingExperimentalExtruder) {
                    "LABS"
                } else if(spoolPresent && !isUnknownMaterial) {
                    filamentMaterialName
                }
                else {
                    ""
                }
            }
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: {
                if (usingExperimentalExtruder) {
                    0
                } else if(!isMaterialValid) {
                    12
                } else {
                    0
                }
            }
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 4
            font.family: defaultFont.name
            font.weight: Font.Light
            font.pixelSize: 18
            smooth: false
            antialiasing: false
            scale: {
                if(width > 125) {
                    0.75
                } else {
                    1
                }
            }
        }

        ColumnLayout {
            id: columnLayout
            width: 360
            height: 150
            anchors.left: parent.left
            anchors.leftMargin: 250
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 5
            spacing: 5
            smooth: false
            antialiasing: false

            Text {
                id: material_bay_text
                color: "#cbcbcb"
                text: qsTr("MATERIAL BAY %1").arg(filamentBayID)
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                font.letterSpacing: 5
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 20
                smooth: false
                antialiasing: false
            }

            RowLayout {
                id: rowLayout
                width: 300
                height: 30
                spacing: 10
                smooth: false
                antialiasing: false

                Text {
                    id: materialColor_text
                    color: "#ffffff"
                    text: {
                        if(printPage.isPrintProcess &&
                           bot.process.stateType == ProcessStateType.Paused &&
                           !extruderFilamentPresent &&
                           !spoolPresent &&
                           filamentMaterialName.toLowerCase() != printMaterialName) {
                            qsTr("INSERT %1 TO CONTINUE").arg(printMaterialName)
                        }
                        else if(spoolPresent) {
                            filamentColorName
                        }
                        else if(extruderFilamentPresent) {
                            usingExperimentalExtruder ?
                                 qsTr("LABS MATERIAL LOADED") :
                                 qsTr("UNKNOWN MATERIAL")
                        }
                        else {
                            qsTr("NO MATERIAL DETECTED")
                        }
                    }
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 4
                    font.family: defaultFont.name
                    font.weight: Font.Light
                    font.pixelSize: 18
                    smooth: false
                    antialiasing: false
                }
            }

            RowLayout {
                id: rowLayout2
                width: 300
                height: 31
                spacing: 10
                smooth: false
                antialiasing: false
                opacity: (spoolPresent &&
                         filamentColorName != "Reading Spool...") ?
                             1.0 : 0

                FilamentIcon {
                    id: filament_icon
                    filamentBayID: filamentBayBaseItem.filamentBayID
                    opacity: spoolPresent ? 1 : 0
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    id: material_quantity_text
                    color: "#ffffff"
                    text: spoolPresent ?
                            qsTr("%1KG REMAINING").arg(filamentQuantity) :
                            ""
                    font.letterSpacing: 4
                    font.family: defaultFont.name
                    font.weight: Font.Light
                    font.pixelSize: 18
                    smooth: false
                    antialiasing: false
                }
            }

            Item {
                id: item1
                width: 300
                height: 3
                visible: true
                smooth: false
                antialiasing: false
            }

            RowLayout {
                id: rowLayout1
                width: 300
                height: 60
                spacing: 30
                smooth: false
                antialiasing: false

                RoundedButton {
                    id: loadButton
                    buttonWidth: extruderFilamentPresent ?
                                      135 : 120
                    buttonHeight: 50
                    label: extruderFilamentPresent ?
                               qsTr("PURGE") : qsTr("LOAD")
                }

                RoundedButton {
                    id: unloadButton
                    buttonWidth: 150
                    buttonHeight: 50
                    label: qsTr("UNLOAD")
                }
            }
        }
    }
}
