import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: filamentBayBaseItem
    width: 800
    height: 180
    smooth: false
    antialiasing: false
    property alias loadButton: loadButton
    property alias unloadButton: unloadButton
    property alias switch1: switch1

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

    property real filamentVolume: {
        (3.14159 * Math.pow(0.0875, 2) * filamentLength)
    }

    property real filamentQuantity: {
        switch(filamentMaterialCode) {
        case 1:
            //PLA
            ((filamentVolume * 1.25)/1000).toFixed(3)
            break;
        case 2:
            //TOUGH
            ((filamentVolume * 1.25)/1000).toFixed(3)
            break;
        case 3:
            //PVA
            ((filamentVolume * 1.20)/1000).toFixed(3)
            break;
        case 4:
            //PETG
            ((filamentVolume * 1.27)/1000).toFixed(3)
            break;
        case 5:
            //ABS
            ((filamentVolume * 1.03)/1000).toFixed(3)
            break;
        case 6:
            //HIPS
            ((filamentVolume * 1.04)/1000).toFixed(3)
            break;
        case 7:
            //PVA-M
            ((filamentVolume * 1.22)/1000).toFixed(3)
            break;
        case 0:
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
            "TOUGH"
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
        case 0:
        default:
            "UNKNOWN"
            break;
        }
    }

    property bool isUnknownMaterial: filamentMaterialName == "UNKNOWN"

    property bool isMaterialValid: {
        (goodMaterialsList.indexOf(filamentMaterialName) >= 0)
    }

    function checkSliceValid(material) {
        return (goodMaterialsList.indexOf(material) >= 0)
    }

    property var goodMaterialsList: {
        switch(filamentBayID) {
        case 1:
            ["PLA", "TOUGH", "PETG"]
            break;
        case 2:
            ["PVA"]
            break;
        default:
            []
            break;
        }
    }

    MaterialIcon {
        id: materialIconLarge
        anchors.left: parent.left
        anchors.leftMargin: 100
        anchors.verticalCenter: parent.verticalCenter
        smooth: false
        antialiasing: false
        filamentBayID: filamentBayBaseItem.filamentBayID

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
                if(spoolPresent && !isUnknownMaterial) {
                    filamentMaterialName
                }
                else {
                    ""
                }
            }
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: !isMaterialValid ?
                                              12 : 0
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 4
            font.family: "Antenna"
            font.weight: Font.Light
            font.pixelSize: 18
            smooth: false
            antialiasing: false
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
                font.family: "Antenna"
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
                        if(spoolPresent) {
                            filamentColorName
                        }
                        else if(extruderFilamentPresent) {
                            qsTr("UNKNOWN MATERIAL")
                        }
                        else {
                            qsTr("NO MATERIAL DETECTED")
                        }
                    }
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 4
                    font.family: "Antenna"
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
                }

                Text {
                    id: material_quantity_text
                    color: "#ffffff"
                    text: spoolPresent ?
                            qsTr("%1KG REMAINING").arg(filamentQuantity) :
                            ""
                    font.letterSpacing: 4
                    font.family: "Antenna"
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

    Switch {
        id: switch1
        checked: false
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 700
        visible: false

        Text {
            id: text1
            text: qsTr("Int.")
            anchors.horizontalCenterOffset: -25
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: switch1.bottom
            anchors.topMargin: 0
            color: "#ffffff"
            font.pixelSize: 15
            font.family: "Antennae"
        }

        Text {
            id: text2
            text: qsTr("Ext.")
            anchors.horizontalCenterOffset: 25
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: switch1.bottom
            anchors.topMargin: 0
            color: "#ffffff"
            font.pixelSize: 15
            font.family: "Antennae"
        }
    }
}
