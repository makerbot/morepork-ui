import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: rootAppWindow
    visible: true
    width: 800
    height: 480
    property alias topBar: topBar
    property var currentItem: mainMenu

    function setCurrentItem(currentItem_) {
        currentItem = currentItem_
    }

    Item{
        id: rootItem
        rotation: 180
        anchors.fill: parent
        objectName: "morepork_main_qml"
        z: 0

        Rectangle {
            id: rectangle
            color: "#000000"
            z: -1
            anchors.fill: parent
        }

        TopBarForm{
            id: topBar
            z: 1
            width: parent.width
            backButton.visible: false
            imageDrawerArrow.visible: false

            onBackClicked: {
                currentItem.backSwiper.swipeToItem(currentItem.backSwipeIndex)
            }
        }

        SwipeView {
            id: mainSwipeView
            anchors.fill: parent
            anchors.topMargin: topBar.barHeight
            interactive: false
            property alias materialPage: materialPage

            function swipeToItem(itemToDisplayDefaultIndex){
                if(itemToDisplayDefaultIndex === 0){
                    mainSwipeView.setCurrentIndex(0)
                    topBar.backButton.visible = false
                    topBar.imageDrawerArrow.visible = false
                    printPage.printingDrawer.interactive = false
                }
                else {
                    var i
                    for(i = 1; i < mainSwipeView.count; i++){
                        if(mainSwipeView.itemAt(i).defaultIndex === itemToDisplayDefaultIndex){
                            if(i !== 1){
                                mainSwipeView.moveItem(i, 1)
                            }
                            setCurrentItem(mainSwipeView.itemAt(1).defaultItem)
                            mainSwipeView.setCurrentIndex(1)
                            topBar.backButton.visible = true
                            break
                        }
                    }
                }
            }

            Item {
                property int defaultIndex: 0

                MainMenu {
                    id: mainMenu
                    anchors.fill: parent

                    mainMenuIcon_print.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(1)
                        printPage.printingDrawer.interactive = true
                        topBar.imageDrawerArrow.visible = true
                        topBar.drawerDownClicked.connect(printPage.printingDrawer.open)
                    }

                    mainMenuIcon_extruder.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(2)
                    }

                    mainMenuIcon_settings.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(3)
                    }

                    mainMenuIcon_info.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(4)
                    }

                    mainMenuIcon_material.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(5)
                        materialPage.filamentVideo.play()
                    }

                    mainMenuIcon_preheat.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(6)
                    }
                }
            }

            Item {
                property int defaultIndex: 1
                property alias defaultItem: printPage.defaultItem
                PrintPage {
                    id: printPage
                    anchors.fill: parent
                }
            }

            Item {
                property int defaultIndex: 2
                property alias defaultItem: extruderPage.defaultItem
                ExtruderPage {
                    id: extruderPage
                    anchors.fill: parent
                }
            }

            Item {
                property int defaultIndex: 3
                property alias defaultItem: settingsPage.defaultItem
                SettingsPage {
                    id: settingsPage
                    anchors.fill: parent
                    anchors.topMargin: topBar.topFadeIn.height - topBar.barHeight
                }
            }

            Item {
                property int defaultIndex: 4
                property alias defaultItem: infoPage.defaultItem
                InfoPage {
                    id: infoPage
                    anchors.fill: parent
                    anchors.topMargin: topBar.topFadeIn.height - topBar.barHeight
                }
            }

            Item {
                property int defaultIndex: 5
                property alias defaultItem: materialPage.defaultItem
                MaterialPage {
                    id: materialPage
                    anchors.fill: parent
                }
            }

            Item {
                property int defaultIndex: 6
                property alias defaultItem: preheatPage.defaultItem
                PreheatPage {
                    id: preheatPage
                    anchors.fill: parent
                }
            }
        }
    }
}
