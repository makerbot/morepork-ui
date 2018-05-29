import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: extruderPage
    property alias defaultItem: itemExtruder
    smooth: false

    SwipeView {
        id: extruderSwipeView
        currentIndex: 0
        smooth: false
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = extruderSwipeView.currentIndex
            extruderSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            setCurrentItem(extruderSwipeView.itemAt(itemToDisplayDefaultIndex))
            extruderSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            extruderSwipeView.itemAt(prevIndex).visible = false
        }

        //extruderSwipeView.index = 0
        Item {
            id: itemExtruder
            property var backSwiper: mainSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            Extruder {
                id: extruder1
                extruderID: 1
                extruderPresent: bot.extruderAPresent
                extruderTemperature: bot.extruderACurrentTemp
                filamentPresent: bot.extruderAFilamentPresent
                extruderUsage: "0H"
                extruderSerialNo: "000-000"
                filamentColor: 0
                filamentColorText: "COLOR"
            }

            Extruder {
                id: extruder2
                anchors.left: extruder1.right
                anchors.leftMargin: 0
                extruder_image.anchors.leftMargin: 30
                extruderID: 2
                extruderPresent: bot.extruderBPresent
                extruderTemperature: bot.extruderBCurrentTemp
                filamentPresent: bot.extruderBFilamentPresent
                extruderUsage: "0H"
                extruderSerialNo: "000-000"
                filamentColor: 0
                filamentColorText: "COLOR"
            }
        }

        //extruderSwipeView.index = 1
        Item {
            id: itemAttachExtruder
            property var backSwiper: extruderSwipeView
            property int backSwipeIndex: 0
            property alias extruder: baseItem.extruder
            smooth: false
            visible: false

            Image {
                id: image
                width: sourceSize.width
                height: sourceSize.height
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/img/extruder_heating.png"
                smooth: false

                Item {
                    id: baseItem
                    width: 400
                    height: 420
                    anchors.left: parent.left
                    anchors.leftMargin: 400
                    anchors.verticalCenter: image.verticalCenter
                    smooth: false
                    property int extruder

                    Text {
                        id: main_instruction_text
                        color: "#cbcbcb"
                        text: "ATTACH EXTRUDER " + parent.extruder
                        anchors.top: parent.top
                        anchors.topMargin: 110
                        font.letterSpacing: 4
                        font.family: "Antennae"
                        font.weight: Font.Bold
                        font.pixelSize: 19
                        lineHeight: 1.35
                        smooth: false
                        antialiasing: false
                    }

                    Text {
                        id: instruction_description_text
                        width: 320
                        height: 105
                        color: "#cbcbcb"
                        text: "Open the latch labeled " + parent.extruder
                            + " and insert a " + (parent.extruder == 1 ? "support" : "material")
                            + " extruder into the slot. Then close the latch and snap it into place."
                        anchors.top: parent.top
                        anchors.topMargin: 155
                        wrapMode: Text.WordWrap
                        font.family: "Antennae"
                        font.weight: Font.Light
                        font.pixelSize: 17
                        lineHeight: 1.35
                        smooth: false
                        antialiasing: false
                    }

                    RoundedButton {
                        id: doneButton
                        buttonWidth: 100
                        buttonHeight: 45
                        label: "DONE"
                        label_size: 18
                        anchors.top: parent.top
                        anchors.topMargin: 250
                        button_mouseArea.onClicked: {
                            extruderSwipeView.swipeToItem(0)
                        }
                    }
                }
            }
        }
    }
}
