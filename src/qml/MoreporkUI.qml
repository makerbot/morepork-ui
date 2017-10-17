import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: rootAppWindow
    visible: true
    width: 800
    height: 480
    property alias topBar: topBar

    Rectangle {
        id: rectangle
        color: "#000000"
        z: -1
        anchors.fill: parent
    }

    TopBarForm{
        id: topBar
        width: parent.width
        backButton.visible: false
        image_drawerArrow.visible: false
        z: 1

//        Component.onCompleted: {
//            topBar.onBackClicked.connect(sayHello)
//        }
    }

    function mainMenuBack(){
        topBar.backButton.visible = false
        topBar.image_drawerArrow.visible = false
        swipeView.setCurrentIndex(0)
        printPage.printingDrawer.interactive = false
        topBar.onBackClicked.disconnect(mainMenuBack)
    }

    SwipeView {
        id: swipeView
        objectName: "morepork_main_qml"
        anchors.fill: parent
        anchors.topMargin: topBar.barHeight
        interactive: false
        rotation: 180
        property alias materialPage: materialPage

        Item {
            property int defaultIndex: 0

            MainMenu {
                id: mainMenu
                anchors.fill: parent

                function swipeToItem(itemToDisplayDefaultIndex){
                    var i
                    for(i = 1; i < swipeView.count; i++){
                        if(swipeView.itemAt(i).defaultIndex === itemToDisplayDefaultIndex){
                            if(i !== 1){
                                swipeView.moveItem(i, 1)
                            }
                            swipeView.setCurrentIndex(1)
                            topBar.backButton.visible = true
                            topBar.onBackClicked.connect(mainMenuBack)
                            break
                        }
                    }
                }

                mainMenuIcon_print.mouseArea.onClicked: {
                    swipeToItem(1)
                    printPage.printingDrawer.interactive = true
                    topBar.image_drawerArrow.visible = true
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
                property alias topBar: topBar
                onLanguageButtonClicked: {
                    settingsPage.settingsSwipeView.setCurrentIndex(0)
                    topBar.onBackClicked.connect(mainMenuBack)
                }

                // When buttonChangeLanguage is clicked, disconnect the back button from
                buttonChangeLanguage.onClicked: {
                    topBar.onBackClicked.disconnect(mainMenuBack)
                    topBar.onBackClicked.connect(moveBackToSettings)
                }

                function moveBackToSettings(){
                    settingsPage.settingsSwipeView.setCurrentIndex(0)
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
