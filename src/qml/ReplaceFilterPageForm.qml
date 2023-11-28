import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ExtruderTypeEnum 1.0
import MachineTypeEnum 1.0

Item {
    id: replaceFilterPage
    smooth: false
    anchors.fill: parent

    property alias contentLeftSide: contentLeftSide
    property alias contentRightSide: contentRightSide
    property alias itemReplaceFilter: itemReplaceFilter
    property alias replace_filter_next_button: contentRightSide.buttonPrimary

    LoggingItem {
        itemName: "ReplaceFilter"
        id: itemReplaceFilter
        smooth: false
        visible: true

        ContentLeftSide {
            id: contentLeftSide
            visible: true
            image {
                source: "qrc:/img/step_1_replace_filter.png"
                visible: true
            }
        }

        ContentRightSide {
            id: contentRightSide
            visible: true
            textHeader {
                text: qsTr("Replace Filter")
                visible: true
            }
            textBody {
                text: qsTr("This procedure allows you to install new filters.")
                visible: true
            }
            numberedSteps {
                visible: false

            }

            buttonPrimary {
                text: qsTr("START")
                visible: true
                onClicked: {
                    if (itemReplaceFilter.state == "step_2") {
                        itemReplaceFilter.state = "step_3"
                    }
                    else if (itemReplaceFilter.state == "step_3") {
                        itemReplaceFilter.state = "step_4"
                    }
                    else if (itemReplaceFilter.state == "step_4") {
                        bot.resetFilterHours()
                        bot.hepaFilterPrintHours = 0
                        bot.hepaFilterChangeRequired = false
                        cleanAirSettingsSwipeView.swipeToItem(CleanAirSettingsPage.BasePage)
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
                    target: contentLeftSide.image
                    source: "qrc:/img/step_2_remove_cables.png"
                }

                PropertyChanges {
                    target: contentRightSide.textHeader
                    text: qsTr("Disconnect System")
                }

                PropertyChanges {
                    target: contentRightSide.textBody
                    text: qsTr("Disconnect all cables from the printer and turn the power switch off.")
                    visible: true
                }

                PropertyChanges {
                    target: contentRightSide.numberedSteps
                    visible: false
                }

                PropertyChanges {
                    target: contentRightSide.buttonPrimary
                    text: qsTr("CONFIRM")
                }
            },
            State {
                name: "step_3"

                PropertyChanges {
                    target: contentLeftSide.image
                    source: "qrc:/img/step_3_remove_electronics.png"
                }

                PropertyChanges {
                    target: contentRightSide.textHeader
                    text: qsTr("Remove Current Filters")
                }

                PropertyChanges {
                    target: contentRightSide.textBody
                    visible: false
                }

                PropertyChanges {
                    target: contentRightSide.numberedSteps
                    steps: [qsTr("Remove the electronics housing to expose the filter."),
                        qsTr("Remove both filters and replace with the new set of filters")]
                    activeSteps: [true, true]
                    visible: true
                }

                PropertyChanges {
                    target: contentRightSide.buttonPrimary
                    text: qsTr("NEXT")
                }
            },
            State {
                name: "step_4"

                PropertyChanges {
                    target: contentLeftSide.image
                    source: "qrc:/img/step_2_remove_cables.png"
                }

                PropertyChanges {
                    target: contentRightSide.textHeader
                    text: qsTr("Install Electronics Housing")
                }

                PropertyChanges {
                    target: contentRightSide.textBody
                    text: qsTr("Install the electronics housing, power unit back on, and plug in the USB to complete procedure.")
                    visible: true
                }

                PropertyChanges {
                    target: contentRightSide.numberedSteps
                    visible: false
                }

                PropertyChanges {
                    target: contentRightSide.buttonPrimary
                    text: qsTr("CONFIRM + RESET")
                    enabled: isFilterConnected()
                    opacity: isFilterConnected() ? 1:0.5
                }
            }
        ]
    }

}
