import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

MenuTemplateForm {
    id: settingsPageForm
    image_drawerArrow.visible: false
    property int pageLevel: 1

    mouseArea_back.onClicked: {
        if(settingsPageForm.pageLevel === 2) {
            swipeView.setCurrentIndex(0)
        }
        settingsPageForm.pageLevel = 1
    }

    SwipeView {
        id: swipeView
        anchors.top: topFadeIn.bottom
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex){
            var i
            for(i = 1; i < swipeView.count; i++){
                if(swipeView.itemAt(i).defaultIndex === itemToDisplayDefaultIndex){
                    if(i !== 1){
                        swipeView.moveItem(i, 1)
                    }
                    swipeView.setCurrentIndex(1)
                    settingsPageForm.pageLevel = 2
                    break
                }
            }
        }

        Item {
            property int defaultIndex: 0
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
                        onClicked: swipeView.swipeToItem(1)
                    }
                }
            }
        }

        Item {
            property int defaultIndex: 1
            property alias settingsPageForm: settingsPageForm

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
                            swipeView.setCurrentIndex(0)
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonSpanish
                        buttonText.text: qsTr("Espanol")
                        onClicked: {
                            cpUiTr.selectLanguage("es")
                            swipeView.setCurrentIndex(0)
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonFrench
                        buttonText.text: qsTr("Francais")
                        onClicked: {
                            cpUiTr.selectLanguage("fr")
                            swipeView.setCurrentIndex(0)
                        }
                    }

                    Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonItalian
                        buttonText.text: qsTr("Italiano")
                        onClicked: {
                            cpUiTr.selectLanguage("it")
                            swipeView.setCurrentIndex(0)
                        }
                    }
                }
            }
        }
    }
}
