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
    property bool statsReady: false

    property bool showStats: extruderPresent && statsReady

    width: 350
    height: extruderStats.height

    ColumnLayout {
        id: extruderStats
        spacing: 25
        width: parent.width

        TextHeadline {
            style: TextHeadline.Base
            id: extLabel
            text: header
        }

        Item {
            id: statsNotReady
            visible: !showStats

            width: 340
            TextBody {
                wrapMode: Text.WordWrap
                style: TextBody.Base
                font.weight: Font.Bold
                font.capitalization: Font.AllUppercase
                anchors.verticalCenter: parent.verticalCenter

                text: {
                    extruderPresent ?
                        qsTr("LOADING EXTRUDER STATS...") :
                        qsTr("EXTRUDER NOT DETECTED")
                }

                BusySpinner {
                    id: extruderStatsLoadingSpinner
                    visible: extruderPresent
                    anchors.left: parent.right
                    anchors.leftMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    spinnerSize: 24
                }
            }
        }

        AdvancedInfoElement {
            visible: showStats
            label: qsTr("TYPE")
            value: extType
        }

        AdvancedInfoElement {
            visible: showStats
            label: qsTr("SERIAL")
            value: serial
        }

        AdvancedInfoElement {
            visible: showStats
            label: qsTr("SHORT RETRACT COUNT")
            value: shortRetractCount
        }

        AdvancedInfoElement {
            visible: showStats
            label: qsTr("LONG RETRACT COUNT")
            value: longRetractCount
        }

        AdvancedInfoElement {
            visible: showStats
            label: qsTr("TOTAL DISTANCE EXTRUDED")
            value: lifetimeDistance + " MM"
        }

        Column {
            id: matLifetimeInfo
            visible: showStats
            spacing: 20

            TextSubheader {
                width: 360
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.WordWrap
                text: qsTr("MATERIAL USAGE BREAKDOWN:")
            }

            Repeater {
                id: matUsage
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
                    if (modelContents.length == 0) {
                        modelContents.push({
                            matName: "",
                            usedAmount: 0
                        });
                    }
                    return modelContents;
                }
                delegate: AdvancedInfoElement {
                    // this seems to just want some height value and doesnt
                    // especially care what that value is, or else everything
                    // just stacks on top of each other...
                    height: 1
                    label: {
                        if (model.modelData.usedAmount > 0) {
                            var mat = model.modelData.matName;
                            return mat.toLowerCase() != 'unknown' ?
                                bot.getMaterialName(mat) : qsTr("Other")
                        } else {
                            return qsTr("NO MATERIALS USED");
                        }
                    }
                    value: model.modelData.usedAmount > 0 ?
                        model.modelData.usedAmount + " MM" : ""
                }
            }
        }
    }
}
