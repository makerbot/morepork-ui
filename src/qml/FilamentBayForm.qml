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
        case 0:
            0
            break;
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
        default:
            0
            break;
        }
    }

    property string filamentMaterialName: {
        switch(filamentMaterialCode) {
        case 0:
            " "
            break;
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
        default:
            "Unknown Material"
            break;
        }
    }

    onSpoolPresentChanged: {
        getSpoolInfoTimer.restart()
    }

    Timer {
        id: getSpoolInfoTimer
        interval: 2000
        onTriggered: {
            bot.getSpoolInfo(filamentBayID-1)
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

        Text {
            id: materialType_text
            color: "#ffffff"
            text: {
                if(spoolPresent) {
                    filamentMaterialName
                }
                else {
                    ""
                }
            }
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
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
            spacing: 5
            smooth: false
            antialiasing: false

            Text {
                id: material_bay_text
                color: "#cbcbcb"
                text: "MATERIAL BAY " + filamentBayID
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
                        else {
                            "NO MATERIAL DETECTED"
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
                height: 30
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
                            filamentQuantity +
                            "KG" + " REMAINING" :
                            " "
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
                               "PURGE" : "LOAD"
                }

                RoundedButton {
                    id: unloadButton
                    buttonWidth: 150
                    buttonHeight: 50
                    label: "UNLOAD"
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
            text: "Int."
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
            text: "Ext."
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
