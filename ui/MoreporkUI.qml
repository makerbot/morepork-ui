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
            MainMenu {
                id: mainMenu
                anchors.fill: parent

                mainMenuIcon_print.mouseArea.onClicked: {
                    swipeView.setCurrentIndex(1)
                }

                mainMenuIcon_info.mouseArea.onClicked: {
                    swipeView.setCurrentIndex(2)
                }
            }
        }

        Item {
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
            InfoPage {
                id: infoPage
                width: parent.width
                height: parent.height

                mouseArea_back.onClicked: {
                    swipeView.setCurrentIndex(0)
                }
            }
        }
    }

//    Loader{
//        id: ld;
//        anchors.fill: parent;
//    }
}
