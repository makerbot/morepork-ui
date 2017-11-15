import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    property alias defaultItem: itemLoadUnloadFilament
    smooth: false

    SwipeView {
        id: extruderSwipeView
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
            visible: false

            Flickable {
                id: flickableLanguages
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnLanguages.height

                Column {
                    id: columnLanguages
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MoreporkButton {
                        id: buttonLoadFilamentLeft
                        buttonText.text: "Left Extruder Load Filament"
                        onClicked: {
                            bot.loadFilament(1)
                        }
                    }

                    Item { width: parent.width; height: 1; smooth: false; Rectangle { color: "#505050"; smooth: false; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonUnloadFilamentLeft
                        buttonText.text: "Left Extruder Unload Filament"
                        onClicked: {
                            bot.unloadFilament(1)
                        }
                    }

                    Item { width: parent.width; height: 1; smooth: false; Rectangle { color: "#505050"; smooth: false; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonLoadFilamentRight
                        buttonText.text: "Right Extruder Load Filament"
                        onClicked: {
                            bot.loadFilament(0)
                        }
                    }

                    Item { width: parent.width; height: 1; smooth: false; Rectangle { color: "#505050"; smooth: false; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonUnloadFilamentRight
                        buttonText.text: "Right Extruder Unload Filament"
                        onClicked: {
                            bot.unloadFilament(0)
                        }
                    }
                }
            }
        }
    }

}
