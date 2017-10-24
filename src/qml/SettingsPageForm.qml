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

        function swipeToItem(itemToDisplayDefaultIndex){
            if(itemToDisplayDefaultIndex === 0){
                settingsSwipeView.setCurrentIndex(0)
                setCurrentItem(settingsSwipeView.itemAt(0))
            }
            else {
                var i
                for(i = 1; i < settingsSwipeView.count; i++){
                    if(settingsSwipeView.itemAt(i).defaultIndex === itemToDisplayDefaultIndex){
                        if(i !== 1){
                            settingsSwipeView.moveItem(i, 1)
                        }
                        setCurrentItem(settingsSwipeView.itemAt(1))
                        settingsSwipeView.setCurrentIndex(1)
                        break
                    }
                }
            }
        }

        Item {
            id: itemSettings
            property int defaultIndex: 0
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
                            settingsSwipeView.swipeToItem(1)
                       }
                    }
                }
            }
        }

        Item {
            property int defaultIndex: 1
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
                        buttonText.text: qsTr("English")
                        onClicked: {
                            cpUiTr.selectLanguage("en")
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonSpanish
                        buttonText.text: qsTr("Espanol")
                        onClicked: {
                            cpUiTr.selectLanguage("es")
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonFrench
                        buttonText.text: qsTr("Francais")
                        onClicked: {
                            cpUiTr.selectLanguage("fr")
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonItalian
                        buttonText.text: qsTr("Italiano")
                        onClicked: {
                            cpUiTr.selectLanguage("it")
                        }
                    }
                }
            }
        }
    }
}
