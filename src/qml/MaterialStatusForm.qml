import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ExtruderTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import MachineTypeEnum 1.0

Item {

    id: materialStatusForm
    width: 344
    height: 100

    RowLayout {
        id: contentContainer
        width: parent.width
        spacing: 32

        MaterialIcon {
            id: materialIcon
            smooth: false
            antialiasing: false
            Layout.alignment: Qt.AlignTop
        }

        Column {
            spacing: 4
            Layout.fillWidth: true

            TextSubheader {
                text: qsTr("MATERIAL %1").arg(filamentBayID)
            }

            TextBody {
                id: materialText
                style: TextBody.ExtraLarge
                font.weight: Font.Bold
                width: parent.width

                text: {
                    // Print paused and extruder switch not triggered. This condition is the LCD
                    // for all types of printers where we want to prompt the user to load a specific
                    // material to continue printing when paused either due to OOF or somehow simply
                    // paused without any filament in the extruder.
                    if(printPage.isPrintProcess && bot.process.stateType == ProcessStateType.Paused && !extruderFilamentPresent) {
                        qsTr("LOAD %1").arg(printMaterialName)
                    }
                    // Printers with Filament Bay (Method/X)
                    else if(bot.hasFilamentBay && filamentMaterial != 'unknown') {
                        filamentMaterialName.toUpperCase()
                    }
                    // Printers without Filament Bay (Method XL) or ones using a labs extruder
                    else if((!bot.hasFilamentBay || usingExperimentalExtruder) &&
                              (bot.loadedMaterials[filamentBayID - 1] != "unknown")) {
                        filamentMaterialName.toUpperCase()
                    } else if(usingExperimentalExtruder && extruderFilamentPresent) {
                        qsTr("LABS MATERIAL\nLOADED")
                    } else {
                        qsTr("NOT DETECTED")
                    }
                }
            }

            Column {
                id: materialDetails
                width: parent.width
                height: 40

                TextBody {
                    id: materialColor
                    style: TextBody.Base
                    font.weight: Font.Thin
                    Layout.preferredWidth: parent.width
                    wrapMode: Text.WordWrap
                    text: filamentColorName.toUpperCase()
                    visible: spoolPresent
                    width: parent.width
                }

                TextBody {
                    id: materialAmount
                    style: TextBody.Base
                    font.weight: Font.Thin
                    text: qsTr("%1KG REMAINING").arg(filamentQuantity)
                    visible: spoolPresent
                    width: parent.width
                }

                TextBody {
                    id: noTagWarningText
                    visible: {
                        bot.hasFilamentBay && !spoolPresent && filamentMaterial != 'unknown'
                    }
                    style: TextBody.Base
                    font.weight: Font.Thin
                    text: qsTr("COULD NOT READ SPOOL INFO")
                    width: parent.width
                }
            }
        }
    }

    states: [
        State {
            name: "no_extruder_detected"
            when: !extruderPresent

            PropertyChanges {
                target: contentContainer
                visible: false
            }
        },
        State {
            name: "extruder_present_material_details_unknown"
            when: extruderPresent && !bot.hasFilamentBay

            PropertyChanges {
                target: contentContainer
                visible: true
            }

            PropertyChanges {
                target: materialDetails
                visible: false
            }
        },
        State {
            name: "extruder_present_material_details_known"
            when: extruderPresent && bot.hasFilamentBay

            PropertyChanges {
                target: contentContainer
                visible: true
            }

            PropertyChanges {
                target: materialDetails
                visible: true
            }
        }
    ]
}
