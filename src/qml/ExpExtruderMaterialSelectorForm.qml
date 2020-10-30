import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ExtruderTypeEnum 1.0

ListView {
    property string process: isLoadFilament ? "load" : "unload"
    id: materialsList
    smooth: false
    anchors.fill: parent
    boundsBehavior: Flickable.DragOverBounds
    spacing: 1
    orientation: ListView.Vertical
    flickableDirection: Flickable.VerticalFlick
    ScrollBar.vertical: ScrollBar {}
    model: {
        if(bot.extruderAType == ExtruderType.MK14_EXP) {
            expMaterialsList
        } else if(bot.extruderAType == ExtruderType.MK14_HOT_E) {
            hTExpMaterialsList
        }
    }
    delegate:
        ExpExtruderMaterialButton {
        id: materialButton
        materialNameText: model.modelData["label"]
        temperatureText: model.modelData[process] + "°C"
        smooth: false
        antialiasing: false
        onClicked: {
            startLoadUnloadExpExtruder(parseInt(temperatureText, 10))
        }
    }
    footer:
        ExpExtruderMaterialButton {
        materialNameText: qsTr("ENTER CUSTOM TEMPERATURE")
        temperatureText: ""
        smooth: false
        antialiasing: false
        onClicked: {
            selectMaterialSwipeView.swipeToItem(1)
        }
    }
}
