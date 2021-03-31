import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ExtruderTypeEnum 1.0
import MachineTypeEnum 1.0

Item {
    id: filterStatusPage
    smooth: false

    property alias itemFilterStatus: itemFilterStatus

    Item {
        id: itemFilterStatus
        smooth: false
        visible: true
        width: 400
        height: 420

        Rectangle {
            id: filterStatus
            anchors.fill: parent
            color: "#000000"
            opacity: 1

            Image {
                id: step_image
                width: sourceSize.width
                height: sourceSize.height
                anchors.left: parent.left
                anchors.leftMargin: 60
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/img/filter.png"
                visible: true
                cache: false
                smooth: false
            }

            Text {
                id: main_text
                color: "#cbcbcb"
                text: qsTr("FILTER LIFETIME")
                anchors.top: parent.top
                anchors.topMargin: 50
                anchors.left: step_image.right
                anchors.leftMargin: 30
                font.letterSpacing: 2
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 21
                lineHeight: 1.2
                smooth: false
                antialiasing: false
            }

            Text {
                id: instruction_text
                color: "#cbcbcb"
                text: bot.hepaFilterMaxHours
                anchors.top: main_text.bottom
                anchors.topMargin: 10
                anchors.left: step_image.right
                anchors.leftMargin: 30
                font.letterSpacing: 2
                font.family: defaultFont.name
                font.pixelSize: 12
                lineHeight: 1.2
                smooth: false
                antialiasing: false
            }

            Text {
                id: main_text_2
                color: "#cbcbcb"
                text: qsTr("FILTER STATUS")
                anchors.top: instruction_text.top
                anchors.topMargin: 30
                anchors.left: step_image.right
                anchors.leftMargin: 30
                font.letterSpacing: 2
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 21
                lineHeight: 1.2
                smooth: false
                antialiasing: false

                Image {
                    id: indicator_image
                    width: sourceSize.width
                    height: sourceSize.height
                    anchors.left: parent.right
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/img/filter_change_required.png"
                    visible: bot.hepaFilterChangeRequired
                    cache: false
                    smooth: false
                }
            }

            Text {
                id: instruction_text_2
                color: "#cbcbcb"
                text: bot.hepaFilterPrintHours
                anchors.top: main_text_2.bottom
                anchors.topMargin: 10
                anchors.left: step_image.right
                anchors.leftMargin: 30
                font.letterSpacing: 2
                font.family: defaultFont.name
                font.pixelSize: 12
                lineHeight: 1.2
                smooth: false
                antialiasing: false
            }

            RoundedButton {
                id: replace_filter_button
                buttonWidth: 125
                buttonHeight: 40
                anchors.top: instruction_text_2.bottom
                anchors.topMargin: 40
                anchors.left: step_image.right
                anchors.leftMargin: 30
                label_size: 18
                label: qsTr("REPLACE FILTER")
                button_mouseArea.onClicked: {
                    cleanAirSettingsSwipeView.swipeToItem(2)
                }
            }

            RoundedButton {
                id: reset_filter_button
                buttonWidth: 125
                buttonHeight: 40
                anchors.top: replace_filter_button.bottom
                anchors.topMargin: 20
                anchors.left: step_image.right
                anchors.leftMargin: 30
                label_size: 18
                label: qsTr("RESET FILTER")
                button_mouseArea.onClicked: {
                    hepaFilterResetPopup.open()
                }
            }

        }
    }

}
