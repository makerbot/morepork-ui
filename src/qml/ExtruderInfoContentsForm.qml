import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ColumnLayout {
    property string header: qsTr("TOOL")
    property string extType: ""
    property int serial: 0
    property int lifetimeDistance: 0
    property int shortRetractCount: 0
    property int longRetractCount: 0
    property int toolIdx: 0

    Layout.preferredWidth: parent.width
    spacing: 34

    TextHeadline {
        style: TextHeadline.Base
        id: extLabel
        text: header
    }

    AdvancedInfoElement {
        label: qsTr("TYPE")
        value: extType
    }

    AdvancedInfoElement {
        label: qsTr("SERIAL")
        value: serial
    }

    AdvancedInfoElement {
        label: qsTr("SHORT RETRACT COUNT")
        value: shortRetractCount
    }

    AdvancedInfoElement {
        label: qsTr("LONG RETRACT COUNT")
        value: longRetractCount
    }

    AdvancedInfoElement {
        label: qsTr("TOTAL DISTANCE EXTRUDED")
        value: lifetimeDistance + " MM"
    }

    ColumnLayout {
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

