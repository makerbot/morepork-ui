import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: window
    visible: true
    width: 800
    height: 480
    objectName: "morepork_main_qml"

    SwipeView {
        id: swipeView
        anchors.fill: parent
        interactive: false

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
                            break
                        }
                    }
                }

                mainMenuIcon_print.mouseArea.onClicked: {
                    swipeToItem(1)

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

                }

                mainMenuIcon_preheat.mouseArea.onClicked: {
                    swipeToItem(6)

                }
            }
        }

        Item {
            property int defaultIndex: 1
            PrintPage {
                id: printPage
                width: parent.width
                height: parent.height

                mouseArea_back.onClicked: {
                    swipeView.setCurrentIndex(0)
                }
            }
        }

        Item {
            property int defaultIndex: 2
            ExtruderPage {
                id: extruderPage
                width: parent.width
                height: parent.height

                mouseArea_back.onClicked: {
                    swipeView.setCurrentIndex(0)
                }
            }
        }

        Item {
            property int defaultIndex: 3
            SettingsPage {
                id: settingsPage
                width: parent.width
                height: parent.height

                mouseArea_back.onClicked: {
                    swipeView.setCurrentIndex(0)
                }
            }
        }

        Item {
            property int defaultIndex: 4
            InfoPage {
                id: infoPage
                width: parent.width
                height: parent.height

                mouseArea_back.onClicked: {
                    swipeView.setCurrentIndex(0)
                }
            }
        }

        Item {
            property int defaultIndex: 5
            MaterialPage {
                id: materialPage
                width: parent.width
                height: parent.height

                mouseArea_back.onClicked: {
                    swipeView.setCurrentIndex(0)
                }
            }
        }

        Item {
            property int defaultIndex: 6
            PreheatPage {
                id: preheatPage
                width: parent.width
                height: parent.height

                mouseArea_back.onClicked: {
                    swipeView.setCurrentIndex(0)
                }
            }
        }
    }
}
