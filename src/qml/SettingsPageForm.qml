import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: settingsPageForm
    property int pageLevel: 1
    property alias settingsSwipeView: settingsSwipeView
    property alias defaultItem: itemSettings

    SwipeView {
        id: settingsSwipeView
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = printSwipeView.currentIndex
            printSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            setCurrentItem(printSwipeView.itemAt(itemToDisplayDefaultIndex))
            printSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            printSwipeView.itemAt(prevIndex).visible = false
            console.log(printSwipeView.currentItem.backSwiper + ", " + printSwipeView.currentItem.backSwipeIndex)
        }

        // settingsSwipeView.index = 0
        Item {
            id: itemSettings
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: mainSwipeView
            property int backSwipeIndex: 0

            Flickable {
                id: flickableSettings
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnSettings.height

                Column {
                    id: columnSettings
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MoreporkButton {
                        id: buttonChangeLanguage
                        buttonText.text: qsTr("Change Language") + cpUiTr.emptyStr
                        onClicked: {
                            settingsSwipeView.swipeForward(1)
                       }
                    }
                }
            }
        }

        // settingsSwipeView.index = 1
        Item {
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0

            Flickable {
                id: flickableLanguages
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnLanguages.height

                Column {
                    id: columnLanguages
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MoreporkButton {
                        id: buttonEnglish
                        buttonText.text: "English"
                        onClicked: {
                            cpUiTr.selectLanguage("en")
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonSpanish
                        buttonText.text: "Espanol"
                        onClicked: {
                            cpUiTr.selectLanguage("es")
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonFrench
                        buttonText.text: "Francais"
                        onClicked: {
                            cpUiTr.selectLanguage("fr")
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonItalian
                        buttonText.text: "Italiano"
                        onClicked: {
                            cpUiTr.selectLanguage("it")
                        }
                    }
                }
            }
        }
    }
}
