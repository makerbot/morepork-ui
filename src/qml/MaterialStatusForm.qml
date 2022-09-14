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
        id: rowLayout
        spacing: 32
        MaterialIcon {
            id: materialIcon
            smooth: false
            antialiasing: false
        }

        ColumnLayout {
            TextSubheader {
                text: qsTr("MATERIAL %1").arg(filamentBayID)
            }

            RowLayout {
                spacing: 5

                TextBody {
                    id: materialText
                    style: TextBody.ExtraLarge
                    font.weight: Font.Bold
                    text: {
                        if(bot.hasFilamentBay && spoolPresent && !isUnknownMaterial) {
                            filamentMaterialName.toUpperCase()
                        } else if(!bot.hasFilamentBay || isUsingExpExtruder(filamentBayID)) {
                            if(bot.loadedMaterials[filamentBayID - 1] != "unknown") {
                                bot.loadedMaterialNames[filamentBayID - 1].toUpperCase()
                            }
                            // Case when OOF and print is paused. Loaded materials is "unknown"
                            // as the extruder switch is not triggered.
                            else if(printPage.isPrintProcess && bot.process.stateType == ProcessStateType.Paused) {
                                qsTr("LOAD %1").arg(printMaterialName)
                            }
                        } else {
                            qsTr("NOT DETECTED")
                        }
                    }
                }

                Image {
                    id: materialErrorAlertIcon
                    width: 30
                    height: 30
                    antialiasing: false
                    smooth: false
                    source: "qrc:/img/alert.png"
                    visible: !isMaterialValid && !isUnknownMaterial && spoolPresent
                }
            }

            ColumnLayout {
                id: materialDetails
                width: 212
                height: 40

                TextBody {
                    id: materialColor
                    style: TextBody.Base
                    font.weight: Font.Thin
                    Layout.preferredWidth: parent.width
                    wrapMode: Text.WordWrap
                    text: {
                        if(printPage.isPrintProcess &&
                           bot.process.stateType == ProcessStateType.Paused &&
                           !extruderFilamentPresent &&
                           !spoolPresent &&
                           filamentMaterial != printMaterial) {
                            qsTr("INSERT %1 TO CONTINUE").arg(printMaterialName)
                        } else if(spoolPresent) {
                            filamentColorName.toUpperCase()
                        } else if(extruderFilamentPresent) {
                            usingExperimentalExtruder ?
                                 qsTr("LABS MATERIAL LOADED") :
                                 qsTr("UNKNOWN MATERIAL")
                        } else {
                            ""
                        }
                    }
                }

                TextBody {
                    id: materialAmount
                    style: TextBody.Base
                    font.weight: Font.Thin
                    text: spoolPresent ?
                            qsTr("%1KG REMAINING").arg(filamentQuantity) :
                              ""
                }
            }
        }
    }
    states: [
        State {
            name: "no_extruder_detected"
            when: !extruderPresent

            PropertyChanges {
                target: rowLayout
                visible: false
            }
        },
        State {
            name: "extruder_present_material_details_unknown"
            when: extruderPresent && !bot.hasFilamentBay

            PropertyChanges {
                target: rowLayout
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
                target: rowLayout
                visible: true
            }

            PropertyChanges {
                target: materialDetails
                visible: true
            }
        }
    ]
}
