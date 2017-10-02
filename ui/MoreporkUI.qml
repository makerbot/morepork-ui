import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: window
    visible: true
    width: 800
    height: 480
    property alias drawer: drawer
    objectName: "morepork_main_qml"

    TopDrawer {
        id: drawer

        button_cancelPrint.onClicked: {
            bot.cancel()
            drawer.close()
        }

        button_pausePrint.onClicked: {
            bot.pausePrint()
            drawer.close()
        }

        mouseArea_topDrawerUp.onClicked: {
            drawer.close()
        }
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        interactive: false

        Item {
            MainMenu {
                id: mainMenu
                anchors.fill: parent

                mouseArea_topDrawerDown.onClicked: {
                    drawer.open()
                }

                mainMenuIcon_info.mouseArea.onClicked: {
                    swipeView.setCurrentIndex(1)
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
