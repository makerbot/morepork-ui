import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ExtruderTypeEnum 1.0
import MachineTypeEnum 1.0

Item {
    id: replaceFilterPage
    smooth: false

    property alias itemReplaceFilter: itemReplaceFilter
    property alias replace_filter_next_button: replace_filter_next_button

    LoggingItem {
        itemName: "ReplaceFilterPage.itemReplaceFilter"
        id: itemReplaceFilter
        smooth: false
        visible: true
        width: 400
        height: 420

        Rectangle {
            id: handle_top_lid_messaging
            anchors.fill: parent
            color: "#000000"
            opacity: 1

            Image {
                id: step_image
                width: sourceSize.width
                height: sourceSize.height
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/img/step_1_replace_filter.png"
                visible: true
                cache: false
                smooth: false
            }

            Text {
                id: main_text
                color: "#ffffff"
                text: qsTr("REPLACE FILTER")
                anchors.top: parent.top
                anchors.topMargin: 80
                anchors.left: step_image.right
                anchors.leftMargin: 30
                font.letterSpacing: 2
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 20
                lineHeight: 1.2
                smooth: false
                antialiasing: false
            }

            Text {
                id: instruction_text
                color: "#ffffff"
                text: qsTr("This procedure will allow you to\nreplace your filter.")
                anchors.top: main_text.bottom
                anchors.topMargin: 20
                anchors.left: step_image.right
                anchors.leftMargin: 30
                font.family: defaultFont.name
                font.pixelSize: 18
                font.weight: Font.Light
                lineHeight: 1.2
                smooth: false
                antialiasing: false
            }

            RoundedButton {
                id: replace_filter_next_button
                buttonWidth: 125
                buttonHeight: 45
                anchors.top: instruction_text.bottom
                anchors.topMargin: 20
                anchors.left: step_image.right
                anchors.leftMargin: 30
                label_size: 18
                label: qsTr("START")
                button_mouseArea.onClicked: {
                    if (itemReplaceFilter.state == "step_2") {
                        itemReplaceFilter.state = "step_3"
                    }
                    else if (itemReplaceFilter.state == "step_3") {
                        itemReplaceFilter.state = "step_4"
                    }
                    else if (itemReplaceFilter.state == "step_4") {
                        itemReplaceFilter.state = "step_5"
                    }
                    else if (itemReplaceFilter.state == "step_5") {
                        bot.resetFilterHours()
                        bot.hepaFilterPrintHours = 0
                        bot.hepaFilterChangeRequired = false
                        cleanAirSettingsSwipeView.swipeToItem(0)
                        itemReplaceFilter.state = "done"
                    }
                    else {
                        itemReplaceFilter.state = "step_2"
                    }
                }
            }
        }

        states: [
            State {
                name: "step_2"
                PropertyChanges {
                    target: step_image
                    source: "qrc:/img/step_2_remove_cables.png"
                }
                PropertyChanges {
                    target: main_text
                    text: qsTr("DISCONNECT SYSTEM")
                }
                PropertyChanges {
                    target: instruction_text
                    text: qsTr("Disconnect all cables from the printer\nand turn the power switch off.")
                }
                PropertyChanges {
                    target: replace_filter_next_button
                    label: qsTr("CONFIRM")
                }
            },
            State {
                name: "step_3"
                PropertyChanges {
                    target: step_image
                    source: "qrc:/img/step_3_remove_electronics.png"
                }
                PropertyChanges {
                    target: main_text
                    text: qsTr("REMOVE ELECTRONIC\nHOUSING")
                }
                PropertyChanges {
                    target: instruction_text
                    text: qsTr("Remove the electronics housing and\nset it aside to expose the filter.")
                }
                PropertyChanges {
                    target: replace_filter_next_button
                    label: qsTr("CONFIRM")
                }
            },
            State {
                name: "step_4"
                PropertyChanges {
                    target: step_image
                    source: "qrc:/img/step_4_remove_filter.png"
                }
                PropertyChanges {
                    target: main_text
                    text: qsTr("REPLACE HEPA +\nCARBON FILTER")
                }
                PropertyChanges {
                    target: instruction_text
                    text: qsTr("Remove both filters and replace with\nthe new set of filters.")
                }
                PropertyChanges {
                    target: replace_filter_next_button
                    label: qsTr("CONFIRM")
                }
            },
            State {
                name: "step_5"
                PropertyChanges {
                    target: step_image
                    source: "qrc:/img/step_2_remove_cables.png"
                }
                PropertyChanges {
                    target: main_text
                    text: qsTr("INSTALL ELECTRONIC\nHOUSING")
                }
                PropertyChanges {
                    target: instruction_text
                    text: qsTr("Install the electronic housing, power unit\nback on, and plug in the USB to complete\nprocedure.")
                }
                PropertyChanges {
                    target: replace_filter_next_button
                    label: qsTr("CONFIRM + RESET")
                    enabled: isFilterConnected()
                    opacity: isFilterConnected() ? 1:0.3
                }
            }
        ]
    }

}
