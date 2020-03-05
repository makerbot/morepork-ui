import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ListView {
    id: materialsList
    smooth: false
    anchors.fill: parent
    boundsBehavior: Flickable.DragOverBounds
    spacing: 1
    orientation: ListView.Vertical
    flickableDirection: Flickable.VerticalFlick
    ScrollBar.vertical: ScrollBar {}
    model: nozzleCleaningTempList
    delegate:
        ExpExtruderMaterialButton {
        id: materialButton
        materialNameText: model.modelData["label"]
        temperatureText: model.modelData["temperature"] + "°C"
        smooth: false
        antialiasing: false
        onClicked: {
            startCleaning([parseInt(temperatureText, 10)])
        }
    }
    footer:
        ExpExtruderMaterialButton {
        materialNameText: qsTr("ENTER CUSTOM TEMPERATURE")
        temperatureText: ""
        smooth: false
        antialiasing: false
        onClicked: {
            cleanExtrudersSelectMaterialSwipeView.swipeToItem(1)
        }
    }
}
