import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: rootAppWindow
    visible: true
    width: 800
    height: 480
    property alias topBar: topBar
    property alias rootItem: rootItem

    //TODO: break this into more functions (per component)
    function mainMenuBack(){
        topBar.backButton.visible = false
        topBar.image_drawerArrow.visible = false
        mainSwipeView.setCurrentIndex(0)

        topBar.backClicked.disconnect(mainMenuBack)

        printPage.printingDrawer.interactive = false
        topBar.drawerDownClicked.disconnect(printPage.printingDrawer.open)
    }

    Item{
        id: rootItem
        rotation: 180
        anchors.fill: parent
        objectName: "morepork_main_qml"
        property alias topBar: topBar
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
            image_drawerArrow.visible: false
        }

        SwipeView {
            id: mainSwipeView
            anchors.fill: parent
            anchors.topMargin: topBar.barHeight
            interactive: false
            property alias materialPage: materialPage

            Item {
                property int defaultIndex: 0

                MainMenu {
                    id: mainMenu
                    anchors.fill: parent
                    anchors.topMargin: topBar.topFadeIn.height - topBar.barHeight

                    function swipeToItem(itemToDisplayDefaultIndex){
                        var i
                        for(i = 1; i < mainSwipeView.count; i++){
                            if(mainSwipeView.itemAt(i).defaultIndex === itemToDisplayDefaultIndex){
                                if(i !== 1){
                                    mainSwipeView.moveItem(i, 1)
                                }
                                mainSwipeView.setCurrentIndex(1)
                                topBar.backButton.visible = true
                                topBar.backClicked.connect(mainMenuBack)
                                break
                            }
                        }
                    }

                    mainMenuIcon_print.mouseArea.onClicked: {
                        swipeToItem(1)
                        printPage.printingDrawer.interactive = true
                        topBar.image_drawerArrow.visible = true
                        topBar.drawerDownClicked.connect(printPage.printingDrawer.open)
                    }

                    mainMenuIcon_extruder.mouseArea.onClicked: {
                        swipeToItem(2)
                    }

                    mainMenuIcon_settings.mouseArea.onClicked: {
                        swipeToItem(3)
                    }

                    mainMenuIcon_info.mouseArea.onClicked: {
                        swipeToItem(4)
                    }

                    mainMenuIcon_material.mouseArea.onClicked: {
                        swipeToItem(5)
                        materialPage.filamentVideo.play()
                    }

                    mainMenuIcon_preheat.mouseArea.onClicked: {
                        swipeToItem(6)
                    }
                }
            }

            Item {
                property int defaultIndex: 1
                property alias topBar: topBar

                PrintPage {
                    id: printPage
                    anchors.fill: parent
                }
            }

            Item {
                property int defaultIndex: 2
                ExtruderPage {
                    id: extruderPage
                    anchors.fill: parent
                }
            }

            Item {
                property int defaultIndex: 3
                SettingsPage {
                    id: settingsPage
                    anchors.fill: parent
                    anchors.topMargin: topBar.topFadeIn.height - topBar.barHeight

                    // When buttonChangeLanguage is clicked, disconnect the back button from
                    Component.onCompleted: {
                        settingsPage.languageButtonClicked.connect(moveBackToSettings)
                    }

                    buttonChangeLanguage.onClicked: {
                        topBar.backClicked.disconnect(mainMenuBack)
                        topBar.backClicked.connect(moveBackToSettings)
                    }

                    function moveBackToSettings(){
                        settingsPage.settingsSwipeView.setCurrentIndex(0)
                        topBar.backClicked.connect(mainMenuBack)
                    }
                }
            }

            Item {
                property int defaultIndex: 4
                InfoPage {
                    id: infoPage
                    anchors.fill: parent
                    anchors.topMargin: topBar.topFadeIn.height - topBar.barHeight
                }
            }

            Item {
                property int defaultIndex: 5
                MaterialPage {
                    id: materialPage
                    anchors.fill: parent
                }
            }

            Item {
                property int defaultIndex: 6
                PreheatPage {
                    id: preheatPage
                    anchors.fill: parent
                }
            }
        }
    }
}
