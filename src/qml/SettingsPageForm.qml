import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

MenuTemplateForm {
    id: settingsPageForm
    image_drawerArrow.visible: false

    Flickable {
        id: flickable
        flickableDirection: Flickable.VerticalFlick
        interactive: true
        anchors.top: topFadeIn.bottom
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        contentHeight: column.height

        Column {
            id: column
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            spacing: 0

            MoreporkButton {
                id: buttonEnglish
                buttonText.text: qsTr("English")
                onClicked: cpUiTr.selectLanguage("en")
            }

            Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

            MoreporkButton {
                id: buttonSpanish
                buttonText.text: qsTr("Espanol")
                onClicked: cpUiTr.selectLanguage("es")
            }

            Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

            MoreporkButton {
                id: buttonFrench
                buttonText.text: qsTr("Francais")
                onClicked: cpUiTr.selectLanguage("fr")
            }

            Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

            MoreporkButton {
                id: buttonItalian
                buttonText.text: qsTr("Italiano")
                onClicked: cpUiTr.selectLanguage("it")
            }
        }
    }
}
