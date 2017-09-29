import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    id: window
    visible: true
    width: 800
    height: 480
    objectName: "testLayout"

    TopDrawer {
        id: drawer

        button_cancelPrint.onClicked: {
            console.log("button_cancelPrint.onClicked")
            bot.cancel()
        }

        button_pausePrint.onClicked: {
            console.log("button_pausePrint.onClicked")
            //bot.pausePrint()
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

                mainMenuIcon_info.mouseArea.onClicked: {
                    console.log("mainMenuIcon_info.mouseArea.onClicked")
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
                    console.log("mouseArea_back.onClicked")
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
