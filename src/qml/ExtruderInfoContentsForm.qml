import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    property string header: qsTr("TOOL")
    property string extType: ""
    property int serial: 0
    property int lifetimeDistance: 0
    property int shortRetractCount: 0
    property int longRetractCount: 0
    property int toolIdx: 0
    property bool extruderPresent: false

    width: extruderStats.width
    height: extruderPresent ? extruderStats.height : parent.height

    ColumnLayout {
        id: extruderStats
        spacing: 34

        TextHeadline {
            style: TextHeadline.Base
            id: extLabel
            text: header
        }

        Item {
            id: extruderNotAttached
            visible: !extruderPresent

            width: 340
            TextBody {
                wrapMode: Text.WordWrap
                style: TextBody.Base
                font.weight: Font.Bold
                font.capitalization: Font.AllUppercase
                anchors.verticalCenter: parent.verticalCenter

                text: qsTr("EXTRUDER NOT DETECTED")
            }
        }

        AdvancedInfoElement {
            visible: extruderPresent
            label: qsTr("TYPE")
            value: extType
        }

        AdvancedInfoElement {
            visible: extruderPresent
            label: qsTr("SERIAL")
            value: serial
        }

        AdvancedInfoElement {
            visible: extruderPresent
            label: qsTr("SHORT RETRACT COUNT")
            value: shortRetractCount
        }

        AdvancedInfoElement {
            visible: extruderPresent
            label: qsTr("LONG RETRACT COUNT")
            value: longRetractCount
        }

        AdvancedInfoElement {
            visible: extruderPresent
            label: qsTr("TOTAL DISTANCE EXTRUDED")
            value: lifetimeDistance + " MM"
        }

        ColumnLayout {
            visible: extruderPresent
            spacing: 20

            TextSubheader {
                text: qsTr("LIFETIME MATERIAL USAGE:")
            }

            Repeater {
                id: materialLifetimeInfo
                layer.smooth: false

                model: {
                    var modelContents = [];
                    var materialList = toolIdx ?
                        bot.extruderBMaterialList :
                        bot.extruderAMaterialList;
                    var usageList = toolIdx ?
                        bot.extruderBMaterialUsageList :
                        bot.extruderAMaterialUsageList;
                    for (var i = 0; i < materialList.length; i++) {
                        if (usageList[i] > 0) {
                            modelContents.push({
                                matName: materialList[i],
                                usedAmount: usageList[i]
                            });
                        }
                    }
                    return modelContents;
                }
                delegate: AdvancedInfoElement {
                    label: {
                        var mat = model.modelData.matName;
                        mat.toLowerCase() != 'unknown' ?
                            bot.getMaterialName(mat) : qsTr("Other")
                    }
                    value: model.modelData.usedAmount + " MM"
                }
            }
        }
    }
}
