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

            Button {
                id: buttonEnglish
                height: 100
                text: qsTr("Pause Print")
                spacing: 0
                background: Rectangle {
                    color: buttonEnglish.down ? "#0a0a0a" : "#050505"
                }
                contentItem: Text {
                    text: qsTr("English")
                    font.family: "Antenna"
                    font.letterSpacing: 3
                    font.weight: Font.Light
                    font.pointSize: 30
                    color: "#a0a0a0"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                anchors.right: parent.right
                anchors.left: parent.left
                onClicked: cpUiTr.selectLanguage("en")
            }

            Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

            Button {
                id: buttonSpanish
                height: 100
                text: qsTr("Pause Print")
                background: Rectangle {
                    color: buttonSpanish.down ? "#0a0a0a" : "#050505"
                }
                contentItem: Text {
                    text: qsTr("Espanol")
                    font.family: "Antenna"
                    font.letterSpacing: 3
                    font.weight: Font.Light
                    font.pointSize: 30
                    color: "#a0a0a0"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                anchors.right: parent.right
                anchors.left: parent.left
                onClicked: cpUiTr.selectLanguage("es")
            }

            Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

            Button {
                id: buttonFrench
                height: 100
                text: qsTr("Pause Print")
                background: Rectangle {
                    color: buttonFrench.down ? "#0a0a0a" : "#050505"
                }
                contentItem: Text {
                    text: qsTr("Francais")
                    font.family: "Antenna"
                    font.letterSpacing: 3
                    font.weight: Font.Light
                    font.pointSize: 30
                    color: "#a0a0a0"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                anchors.right: parent.right
                anchors.left: parent.left
                onClicked: cpUiTr.selectLanguage("fr")
            }

            Item { width: parent.width; height: 1; Rectangle { color: "#505050"; anchors.fill: parent } }

            Button {
                id: buttonItalian
                height: 100
                text: qsTr("Pause Print")
                background: Rectangle {
                    color: buttonItalian.down ? "#0a0a0a" : "#050505"
                }
                contentItem: Text {
                    text: qsTr("Italiano")
                    font.family: "Antenna"
                    font.letterSpacing: 3
                    font.weight: Font.Light
                    font.pointSize: 30
                    color: "#a0a0a0"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                anchors.right: parent.right
                anchors.left: parent.left
                onClicked: cpUiTr.selectLanguage("it")
            }
        }
    }
}
