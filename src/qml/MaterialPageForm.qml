import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.8
import ProcessTypeEnum 1.0


Item {
    id: item1
//    property alias filamentVideo: filamentVideo
    property alias defaultItem: itemLoadUnloadFilament
    smooth: false

    SwipeView {
        id: materialSwipeView
        smooth: false
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = extruderSwipeView.currentIndex
            extruderSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            setCurrentItem(extruderSwipeView.itemAt(itemToDisplayDefaultIndex))
            extruderSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            extruderSwipeView.itemAt(prevIndex).visible = false
        }

        // extruderSwipeView.index = 0
        Item {
            id: itemLoadUnloadFilament
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: mainSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: bot.process.type != ProcessType.Load

            FilamentBay{
                id: bay1
                anchors.top: parent.top
                anchors.topMargin: 40
                filamentBayID: 1
                filamentMaterial: "MAT"
                filamentMaterialColor: "COLOR"
                filamentQuantity: "0.0"
                load_mouseArea.onClicked:{
                    loadFilamentProcess.bayID = 0
                    loadFilamentProcess.filamentBaySwitchActive = bot.filamentBay1Switch
                    bot.loadFilament(0)
                }
                unload_mouseArea.onClicked: bot.unloadFilament(0)
            }

            FilamentBay{
                id: bay2
                anchors.top: parent.top
                anchors.topMargin: 240
                filamentBayID: 2
                filamentMaterial: "MAT"
                filamentMaterialColor: "COLOR"
                filamentQuantity: "0.0"
                load_mouseArea.onClicked:{
                    loadFilamentProcess.bayID = 1
                    loadFilamentProcess.filamentBaySwitchActive = bot.filamentBay2Switch
                    bot.loadFilament(1)
                }
                unload_mouseArea.onClicked: bot.unloadFilament(1)
            }
        }

        Item{
            id: itemLoadFilament
            visible: bot.process.type == ProcessType.Load
            LoadFilament{
                id: loadFilamentProcess

            }
        }
    }
//    Video {
//        id: filamentVideo
//        smooth: false
//        z: 3
//        loops: MediaPlayer.Infinite
//        anchors.right: parent.right
//        anchors.rightMargin: (800-((800/480)*440))/2
//        anchors.left: parent.left
//        anchors.leftMargin: (800-((800/480)*440))/2
//        anchors.top: parent.top
//        anchors.topMargin: 40
//        anchors.bottom: parent.bottom
//        autoLoad: true
//        autoPlay: false
//        source: mainSwipeView.rotation == 180 ? "" : "qrc:/vid/filament_installation.m4v"
//    }
}
