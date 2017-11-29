import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.8

Item {
    id: item1
    property alias defaultItem: itemFilamentBay

    smooth: false

    SwipeView {
        id: materialSwipeView
        currentIndex: 0
        smooth: false
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = materialSwipeView.currentIndex
            materialSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            setCurrentItem(materialSwipeView.itemAt(itemToDisplayDefaultIndex))
            materialSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            materialSwipeView.itemAt(prevIndex).visible = false
        }

        // extruderSwipeView.index = 0
        Item {
            id: itemFilamentBay
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: mainSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: true

            FilamentBay{
                id: bay1
                visible: true
                anchors.top: parent.top
                anchors.topMargin: 40
                filamentBayID: 1
                filamentMaterial: "MAT"
                filamentMaterialColor: "COLOR"
                filamentQuantity: "0.0"
                load_mouseArea.onClicked:
                {
                    loadUnloadFilamentProcess.bayID = 1
                    bot.loadFilament(0)
                    materialSwipeView.swipeToItem(2)
                }
                unload_mouseArea.onClicked:
                {
                    loadUnloadFilamentProcess.bayID = 1
                    bot.unloadFilament(0)
                    materialSwipeView.swipeToItem(2)
                }
            }

            FilamentBay{
                id: bay2
                visible: true
                anchors.top: parent.top
                anchors.topMargin: 240
                filamentBayID: 2
                filamentMaterial: "MAT"
                filamentMaterialColor: "COLOR"
                filamentQuantity: "0.0"
                load_mouseArea.onClicked:
                {
                    loadUnloadFilamentProcess.bayID = 2
                    bot.loadFilament(1)
                    materialSwipeView.swipeToItem(2)
                }
                unload_mouseArea.onClicked:
                {
                    loadUnloadFilamentProcess.bayID = 2
                    bot.unloadFilament(1)
                    materialSwipeView.swipeToItem(2)
                }
            }
        }

        // extruderSwipeView.index = 1
        Item{
            id: itemCancelLoadFilament
            property var backSwiper: materialSwipeView
            property int backSwipeIndex: 2
            visible: false

            Rectangle {
                id: base_rectangle
                width: 720
                height: 275
                color: "#00000000"
                radius: 10
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                border.width: 1
                border.color: "#ffffff"

                ColumnLayout {
                    id: columnLayout
                    width: 484
                    height: 100
                    anchors.top: parent.top
                    anchors.topMargin: 40
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        id: cancel_text
                        color: "#cbcbcb"
                        text: "CANCEL MATERIAL LOADING?"
                        font.letterSpacing: 3
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.family: "Antennae"
                        font.weight: Font.Bold
                        font.pixelSize: 20
                    }

                    Text {
                        id: cancel_description_text
                        color: "#cbcbcb"
                        text: "Are you sure you want to cancel the material loading process?"
                        horizontalAlignment: Text.AlignHCenter
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.weight: Font.Light
                        wrapMode: Text.WordWrap
                        font.family: "Antennae"
                        font.pixelSize: 18
                    }
                }

                Rectangle {
                    id: horizontal_divider
                    width: 720
                    height: 1
                    color: "#ffffff"
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 72
                }

                Rectangle {
                    id: vertical_divider
                    x: 360
                    y: 178
                    width: 1
                    height: 72
                    color: "#ffffff"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                RowLayout {
                    id: rowLayout
                    width: 720
                    height: 72
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 0
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        id: cancel_loading_text
                        color: "#ffffff"
                        text: "CANCEL LOADING"
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: false
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: "Antennae"
                        font.pixelSize: 16

                        MouseArea {
                            id: cancel_mouseArea
                            width: 300
                            height: 75
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            onClicked: bot.loadFilamentStop()
                        }
                    }

                    Text {
                        id: continue_loading_text
                        color: "#ffffff"
                        text: "CONTINUE LOADING"
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: "Antennae"
                        font.pixelSize: 16

                        MouseArea {
                            id: continue_mouseArea
                            width: 300
                            height: 75
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: materialSwipeView.swipeToItem(2)
                        }
                    }
                }
            }
        }

        // extruderSwipeView.index = 2
        Item{
            id: itemLoadUnloadFilament
            property var backSwiper: materialSwipeView
            property int backSwipeIndex: 1
            visible: true
            LoadUnloadFilament{
                id: loadUnloadFilamentProcess
                filamentBaySwitchActive: bayID == 1 ? bot.filamentBay1Switch : bot.filamentBay2Switch
            }
        }
    }
}
