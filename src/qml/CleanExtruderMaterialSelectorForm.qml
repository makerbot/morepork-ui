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
        MaterialButton {
        id: materialButton
        materialNameText: model.modelData["label"]
        materialInfoText: model.modelData["temperature"] + "°C"
        smooth: false
        antialiasing: false
        onClicked: {
            startCleaning([parseInt(materialInfoText, 10)])
        }

        Component.onCompleted: {
            this.onReleased.connect(uiLogClBtn)
        }

        function uiLogClBtn() {
            console.info("MLB [=" + materialNameText + "=] clicked")
        }
    }
    footer:
        MaterialButton {
        materialNameText: qsTr("ENTER CUSTOM TEMPERATURE")
        materialInfoText: ""
        smooth: false
        antialiasing: false
        onClicked: {
            cleanExtrudersSelectMaterialSwipeView.swipeToItem(CleanExtruderSettings.TemperatureSelector)
        }
    }
}
