import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: advancedInfo
    width: 800
    height: 440
    smooth: false

    RoundedButton {
        id: roundedButton
        z: 1
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        anchors.right: parent.right
        anchors.rightMargin: 25
        buttonWidth: 76
        buttonHeight: 76
        button_rectangle.radius: buttonWidth/2
        button_rectangle.smooth: true
        button_rectangle.antialiasing: true
        button_text.visible: false
        is_button_transparent: false

        Image {
            id: refresh_image
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/img/refresh.png"
            width: sourceSize.width/1.6
            height: sourceSize.height/1.6
        }

        button_mouseArea.onClicked: {
            bot.query_status()
        }

        button_mouseArea.onPressed: {
            refresh_image.source = "qrc:/img/refresh_black.png"
        }

        button_mouseArea.onReleased: {
            refresh_image.source = "qrc:/img/refresh.png"
        }
    }

    Flickable {
        id: flickableAdvancedInfo
        smooth: false
        flickableDirection: Flickable.VerticalFlick
        interactive: true
        anchors.fill: parent
        contentHeight: columnContents.height

        Column {
            id: columnContents
            smooth: false
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            spacing: 0

            AdvancedInfoToolheadsItem {
                anchors.left: parent.left
                anchors.leftMargin: 40

            }

            RowLayout {
                anchors.left: parent.left
                anchors.leftMargin: 40
                spacing: 0
                AdvancedInfoChamberItem {

                }

                AdvancedInfoMiscItem {

                }
            }

            AdvancedInfoFilamentBaysItem {
                anchors.left: parent.left
                anchors.leftMargin: 40

            }

            AdvancedInfoMotionStatusItem {
                anchors.left: parent.left
                anchors.leftMargin: 40
            }
        }
    }
}
