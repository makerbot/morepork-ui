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

        Loader{
            id: mainLoader
            source: "MainMenu.qml"
            anchors.fill: parent
            anchors.topMargin: topBar.barHeight
        }

        Connections{
            target: mainLoader.item
            ignoreUnknownSignals: true
            onOpenPrintPage: {mainLoader.source = "PrintPage.qml"}
            onOpenExtruderPage: {mainLoader.source = "ExtruderPage.qml"}
            onOpenSettingsPage: {mainLoader.source = "SettingsPage.qml"}
            onOpenInfoPage: {mainLoader.source = "InfoPage.qml"}
            onOpenMaterialPage: {mainLoader.source = "MaterialPage.qml"}
            onOpenPreheatPage: {mainLoader.source = "PreheatPage.qml"}
        }

//        SwipeView {
//            id: mainSwipeView
//            anchors.fill: parent
//            anchors.topMargin: topBar.barHeight
//            interactive: false
//            property alias materialPage: materialPage

//            function swipeToItem(itemToDisplayDefaultIndex) {
//                var prevIndex = mainSwipeView.currentIndex
//                mainSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
//                if(itemToDisplayDefaultIndex === 0) {
//                    mainSwipeView.setCurrentIndex(0)
//                    topBar.backButton.visible = false
//                    topBar.imageDrawerArrow.visible = false
//                    printPage.printingDrawer.interactive = false
//                }
//                else {
//                    mainSwipeView.itemAt(itemToDisplayDefaultIndex).defaultItem.visible = true
//                    setCurrentItem(mainSwipeView.itemAt(itemToDisplayDefaultIndex).defaultItem)
//                    mainSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
//                    topBar.backButton.visible = true
//                }
//                mainSwipeView.itemAt(prevIndex).visible = false
//            }

//            // mainSwipeView.index = 0
//            Item {
//                MainMenu {
//                    id: mainMenu
//                    anchors.fill: parent

//                    mainMenuIcon_print.mouseArea.onClicked: {
//                        mainSwipeView.swipeToItem(1)
//                        printPage.printingDrawer.interactive = true
//                        topBar.imageDrawerArrow.visible = true
//                        topBar.drawerDownClicked.connect(printPage.printingDrawer.open)
//                    }

//                    mainMenuIcon_extruder.mouseArea.onClicked: {
//                        mainSwipeView.swipeToItem(2)
//                    }

//                    mainMenuIcon_settings.mouseArea.onClicked: {
//                        mainSwipeView.swipeToItem(3)
//                    }

//                    mainMenuIcon_info.mouseArea.onClicked: {
//                        mainSwipeView.swipeToItem(4)
//                    }

//                    mainMenuIcon_material.mouseArea.onClicked: {
//                        mainSwipeView.swipeToItem(5)
//                        materialPage.filamentVideo.play()
//                    }

//                    mainMenuIcon_preheat.mouseArea.onClicked: {
//                        mainSwipeView.swipeToItem(6)
//                    }
//                }
//            }

//            // mainSwipeView.index = 1
//            Item {
//                property alias defaultItem: printPage.defaultItem
//                visible: false
//                PrintPage {
//                    id: printPage
//                    anchors.fill: parent
//                }
//            }

//            // mainSwipeView.index = 2
//            Item {
//                property int defaultIndex: 2
//                property alias defaultItem: extruderPage.defaultItem
//                visible: false
//                ExtruderPage {
//                    id: extruderPage
//                    anchors.fill: parent
//                }
//            }

//            // mainSwipeView.index = 3
//            Item {
//                property int defaultIndex: 3
//                property alias defaultItem: settingsPage.defaultItem
//                visible: false
//                SettingsPage {
//                    id: settingsPage
//                    anchors.fill: parent
//                    anchors.topMargin: topBar.topFadeIn.height - topBar.barHeight
//                }
//            }

//            // mainSwipeView.index = 4
//            Item {
//                property int defaultIndex: 4
//                property alias defaultItem: infoPage.defaultItem
//                visible: false
//                InfoPage {
//                    id: infoPage
//                    anchors.fill: parent
//                    anchors.topMargin: topBar.topFadeIn.height - topBar.barHeight
//                }
//            }

//            // mainSwipeView.index = 5
//            Item {
//                property int defaultIndex: 5
//                property alias defaultItem: materialPage.defaultItem
//                visible: false
//                MaterialPage {
//                    id: materialPage
//                    anchors.fill: parent
//                }
//            }

//            // mainSwipeView.index = 6
//            Item {
//                property int defaultIndex: 6
//                property alias defaultItem: preheatPage.defaultItem
//                visible: false
//                PreheatPage {
//                    id: preheatPage
//                    anchors.fill: parent
//                }
//            }
//        }
    }
}
