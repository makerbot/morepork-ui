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
    property var activeDrawer

    function setCurrentItem(currentItem_) {
        currentItem = currentItem_
    }

    function goBack(){
        if(currentItem.hasAltBack){
            currentItem.altBack()
        }
        else{
            currentItem.backSwiper.swipeToItem(currentItem.backSwipeIndex)
        }
    }

    function disableDrawer()
    {
        topBar.backButton.visible = false
        topBar.imageDrawerArrow.visible = false
        activeDrawer.interactive = false
        topBar.drawerDownClicked.disconnect(activeDrawer.open)
    }

    Item{
        id: rootItem
        smooth: false
        rotation: 180
        anchors.fill: parent
        objectName: "morepork_main_qml"
        z: 0

        Rectangle {
            id: rectangle
            color: "#000000"
            smooth: false
            z: -1
            anchors.fill: parent
        }

        Drawer{
            id: backSwipe
            width: rootAppWindow.width
            height: rootAppWindow.height
            edge: rootItem.rotation == 180 ? Qt.RightEdge : Qt.LeftEdge
            dim: false
            opacity: 0
            interactive: mainSwipeView.currentIndex
            onOpened:
            {
                position = 0
                goBack()
                close()
            }
        }

        TopBarForm{
            id: topBar
            z: 1
            width: parent.width
            smooth: false
            backButton.visible: false
            imageDrawerArrow.visible: false

            onBackClicked: {
                goBack()
            }
        }

        SwipeView {
            id: mainSwipeView
            anchors.fill: parent
            anchors.topMargin: topBar.barHeight
            interactive: false
            transform: Translate {
                        x: backSwipe.position * mainSwipeView.width * 1.5
                    }
            property alias materialPage: materialPage
            smooth: false

            function swipeToItem(itemToDisplayDefaultIndex) {
                var prevIndex = mainSwipeView.currentIndex
                mainSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
                if(itemToDisplayDefaultIndex === 0) {
                    mainSwipeView.setCurrentIndex(0)
                    disableDrawer()
                }
                else {
                    mainSwipeView.itemAt(itemToDisplayDefaultIndex).defaultItem.visible = true
                    setCurrentItem(mainSwipeView.itemAt(itemToDisplayDefaultIndex).defaultItem)
                    mainSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
                    topBar.backButton.visible = true
                }
                mainSwipeView.itemAt(prevIndex).visible = false
            }

            // mainSwipeView.index = 0
            Item {
                smooth: false
                MainMenu {
                    id: mainMenu
                    anchors.fill: parent

                    mainMenuIcon_print.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(1)
                        activeDrawer = printPage.printingDrawer
                        activeDrawer.interactive = true
                        topBar.imageDrawerArrow.visible = true
                        topBar.drawerDownClicked.connect(activeDrawer.open)
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
                        activeDrawer = materialPage.materialPageDrawer
                    }

                    mainMenuIcon_preheat.mouseArea.onClicked: {
                        mainSwipeView.swipeToItem(6)
                    }
                }
            }

            // mainSwipeView.index = 1
            Item {
                property alias defaultItem: printPage.defaultItem
                smooth: false
                visible: false
                PrintPage {
                    id: printPage
                    smooth: false
                    anchors.fill: parent
                }
            }

            // mainSwipeView.index = 2
            Item {
                property int defaultIndex: 2
                property alias defaultItem: extruderPage.defaultItem
                smooth: false
                visible: false
                ExtruderPage {
                    id: extruderPage
                    anchors.fill: parent
                }
            }

            // mainSwipeView.index = 3
            Item {
                property int defaultIndex: 3
                property alias defaultItem: settingsPage.defaultItem
                smooth: false
                visible: false
                SettingsPage {
                    id: settingsPage
                    smooth: false
                    anchors.fill: parent
                    anchors.topMargin: topBar.topFadeIn.height - topBar.barHeight
                }
            }

            // mainSwipeView.index = 4
            Item {
                property int defaultIndex: 4
                property alias defaultItem: infoPage.defaultItem
                smooth: false
                visible: false
                InfoPage {
                    id: infoPage
                    anchors.fill: parent
                    anchors.topMargin: topBar.topFadeIn.height - topBar.barHeight
                }
            }

            // mainSwipeView.index = 5
            Item {
                property int defaultIndex: 5
                property alias defaultItem: materialPage.defaultItem
                smooth: false
                visible: false
                MaterialPage {
                    id: materialPage
                    smooth: false
                    anchors.fill: parent
                }
            }

            // mainSwipeView.index = 6
            Item {
                property int defaultIndex: 6
                property alias defaultItem: preheatPage.defaultItem
                smooth: false
                visible: false
                PreheatPage {
                    id: preheatPage
                    smooth: false
                    anchors.fill: parent
                }
            }
        }
    }
}
