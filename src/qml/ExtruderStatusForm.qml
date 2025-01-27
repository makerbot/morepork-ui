import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ExtruderTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import MachineTypeEnum 1.0

Item {
    id: extruderStatusForm
    width: 344
    height: 100

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    RowLayout {
        spacing: 32
        Image {
            id: extruderIDImage
            source: {
                if(extruderPresent) {
                    switch(filamentBayID) {
                        case 1:
                        switch(bot.extruderAType) {
                            case ExtruderType.MK14:
                                "qrc:/img/extruder_1a.png"
                                break;
                            case ExtruderType.MK14_HOT:
                                "qrc:/img/extruder_1xa.png"
                                break;
                            case ExtruderType.MK14_EXP:
                                "qrc:/img/extruder_labs.png"
                                break;
                            case ExtruderType.MK14_COMP:
                                "qrc:/img/extruder_1c.png"
                                break;
                            case ExtruderType.MK14_HOT_E:
                                "qrc:/img/extruder_labs_ht.png"
                                break;
                            default:
                                "qrc:/img/broken.png"
                                break;
                        }
                        break;
                        case 2:
                        switch(bot.extruderBType) {
                            case ExtruderType.MK14: {
                                if (bot.extruderBIsSupportExtruder) {
                                    "qrc:/img/extruder_2a.png"
                                } else {
                                    "qrc:/img/extruder_1a.png"
                                }
                                break;
                            }
                            case ExtruderType.MK14_HOT:
                                if (bot.extruderBIsSupportExtruder) {
                                    "qrc:/img/extruder_2xa.png"
                                } else {
                                    "qrc:/img/extruder_1xa.png"
                                }
                                break;
                            case ExtruderType.MK14_EXP:
                                "qrc:/img/extruder_labs.png"
                                break;
                            case ExtruderType.MK14_COMP:
                                "qrc:/img/extruder_1c.png"
                                break;
                            default:
                                "qrc:/img/broken.png"
                                break;
                        }
                        break;
                        default:
                            break;
                    }
                } else {
                    "qrc:/img/extruder_material_error.png"
                }
            }
        }

        ColumnLayout {
            TextSubheader {
                id: extruderNumberText
                text: qsTr("EXTRUDER %1").arg(filamentBayID)
            }

            TextSubheader {
                id: extruderTempText
                text: qsTr("TEMP: %1C").arg(extruderTemperature)
            }

            TextBody {
                id: extruderNotDetectedText
                visible: false
                style: TextBody.ExtraLarge
                font.weight: Font.Bold
                text: qsTr("NOT DETECTED")
            }
        }
    }

    states: [
        State {
            name: "no_extruder_detected"
            when: !extruderPresent

            PropertyChanges {
                target: extruderTempText
                visible: false
            }

            PropertyChanges {
                target: extruderNotDetectedText
                visible: true
            }
        },

        State {
            name: "extruder_detected"
            when: extruderPresent

            PropertyChanges {
                target: extruderTempText
                visible: true
            }

            PropertyChanges {
                target: extruderNotDetectedText
                visible: false
            }
        }
    ]
}
