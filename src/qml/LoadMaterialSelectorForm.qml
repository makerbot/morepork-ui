import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ExtruderTypeEnum 1.0

ListSelector {
    id: materialsList
    property string process: isLoadFilament ? "load" : "unload"
    model: {
        if(toolIdx == 0) {
            bot.extruderASupportedMaterials
        } else if(toolIdx == 1) {
            bot.extruderBSupportedMaterials
        }
    }
    header:
        Item {
        width: 800
        height: 120

        Rectangle {
            height: 78
            width: 84
            radius: 3
            border.width: 3
            border.color: "#f2f2f2"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#000000"

            Image {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                source: {
                    switch(toolIdx) {
                        case 0:
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
                        }
                        break;
                        case 1:
                        switch(bot.extruderBType) {
                            case ExtruderType.MK14:
                                "qrc:/img/extruder_2a.png"
                                break;
                            case ExtruderType.MK14_HOT:
                                "qrc:/img/extruder_2xa.png"
                                break;
                        }
                        break;
                    }
                }
            }
        }
    }

    delegate:
        MaterialButton {
        id: materialButton
        materialNameText: storage.updateMaterialNames(model.modelData)
        materialInfoText: ""
        smooth: false
        antialiasing: false
        onClicked: {
            startLoadForMaterial(toolIdx, false, model.modelData)
        }
    }
    footer:
        MaterialButton {
        materialNameText: qsTr("ENTER CUSTOM TEMPERATURE")
        materialInfoText: ""
        smooth: false
        antialiasing: false
        onClicked: {
            selectMaterialSwipeView.swipeToItem(LoadMaterialSettings.SelectTemperaturePage)
        }
        visible: isUsingExpExtruder(toolIdx + 1)
    }
}
