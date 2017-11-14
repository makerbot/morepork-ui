import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: settingsPageForm
    property int pageLevel: 1
    property alias settingsSwipeView: settingsSwipeView
    property alias defaultItem: itemSettings
    smooth: false

    SwipeView {
        id: settingsSwipeView
        smooth: false
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = settingsSwipeView.currentIndex
            settingsSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            setCurrentItem(settingsSwipeView.itemAt(itemToDisplayDefaultIndex))
            settingsSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            settingsSwipeView.itemAt(prevIndex).visible = false
        }

        // settingsSwipeView.index = 0
        Item {
            id: itemSettings
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: mainSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            Flickable {
                id: flickableSettings
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnSettings.height

                Column {
                    id: columnSettings
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MoreporkButton {
                        id: buttonChangeLanguage
                        buttonText.text: qsTr("Change Language") + cpUiTr.emptyStr
                        onClicked: {
                            settingsSwipeView.swipeToItem(1)
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
            smooth: false
            visible: false

            Flickable {
                id: flickableLanguages
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnLanguages.height

                Column {
                    id: columnLanguages
                    smooth: false
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

                    Item { width: parent.width; height: 1; smooth: false; Rectangle { color: "#505050"; smooth: false; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonSpanish
                        buttonText.text: "Espanol"
                        onClicked: {
                            cpUiTr.selectLanguage("es")
                        }
                    }

                    Item { width: parent.width; height: 1; smooth: false; Rectangle { color: "#505050"; smooth: false; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonFrench
                        buttonText.text: "Francais"
                        onClicked: {
                            cpUiTr.selectLanguage("fr")
                        }
                    }

                    Item { width: parent.width; height: 1; smooth: false; Rectangle { color: "#505050"; smooth: false; anchors.fill: parent } }

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
