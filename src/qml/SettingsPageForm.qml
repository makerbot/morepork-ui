import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

MenuTemplateForm {
    id: settingsPageForm
    image_drawerArrow.visible: false

    Flickable {
        id: flickable
        anchors.top: topFadeIn.bottom
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        interactive: true
        flickableDirection: Flickable.VerticalFlick
        contentHeight: column.height

        Column {
            id: column
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            spacing: 1

            Button {
                id: buttonEnglish
                height: 80
                text: qsTr("Pause Print")
                background: Rectangle {
                    color: "#000000"
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

            Button {
                id: buttonSpanish
                height: 80
                text: qsTr("Pause Print")
                background: Rectangle {
                    color: "#000000"
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

            Button {
                id: buttonFrench
                height: 80
                text: qsTr("Pause Print")
                background: Rectangle {
                    color: "#000000"
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

            Button {
                id: buttonItalian
                height: 80
                text: qsTr("Pause Print")
                background: Rectangle {
                    color: "#000000"
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
