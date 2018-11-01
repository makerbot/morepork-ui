import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item {
    id: extruderPage
    property alias defaultItem: itemExtruder
    property alias extruderSwipeView: extruderSwipeView
    property bool isTopLidOpen: bot.chamberErrorCode == 45
    property alias itemAttachExtruder: itemAttachExtruder
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
                attachButton {
                    button_mouseArea.onClicked: {
                        itemAttachExtruder.extruder = extruderID
                        extruderSwipeView.swipeToItem(1)
                    }
                }
                detachButton {
                    button_mouseArea.onClicked: {
                        itemAttachExtruder.extruder = extruderID
                        extruderSwipeView.swipeToItem(1)
                    }
                }
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
                attachButton {
                    button_mouseArea.onClicked: {
                        itemAttachExtruder.extruder = extruderID
                        extruderSwipeView.swipeToItem(1)
                    }
                }
                detachButton {
                    button_mouseArea.onClicked: {
                        itemAttachExtruder.extruder = extruderID
                        extruderSwipeView.swipeToItem(1)
                    }
                }
            }
        }

        //extruderSwipeView.index = 1
        Item {
            id: itemAttachExtruder
            property var backSwiper: extruderSwipeView
            property int backSwipeIndex: 0
            property int extruder
            property bool isAttached: {
                switch(extruder) {
                case 1:
                    bot.extruderAPresent
                    break;
                case 2:
                    bot.extruderBPresent
                    break;
                default:
                    false
                    break;
                }
            }
            property bool hasAltBack: true

            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    itemAttachExtruder.skipFreStepAction()
                }

                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                extruderSwipeView.swipeToItem(0)
                mainSwipeView.swipeToItem(0)
            }

            AnimatedImage {
                id: image
                width: sourceSize.width
                height: sourceSize.height
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.verticalCenter: parent.verticalCenter
                source: switch(itemAttachExtruder.extruder) {
                        case 1:
                            "qrc:/img/attach_extruder_1.gif"
                            break;
                        case 2:
                            "qrc:/img/attach_extruder_2.gif"
                            break;
                        default:
                            ""
                            break;
                        }
                playing: extruderSwipeView.currentIndex == 1 &&
                         bot.chamberErrorCode == 45
                visible: true
                cache: false
                smooth: false

                Item {
                    id: baseItem
                    width: 400
                    height: 420
                    anchors.left: parent.right
                    anchors.leftMargin: 0
                    anchors.verticalCenter: image.verticalCenter
                    smooth: false

                    Text {
                        id: main_instruction_text
                        color: "#cbcbcb"
                        text: {
                            if(itemAttachExtruder.isAttached) {
                                (itemAttachExtruder.extruder == 1 ? "MODEL" : "SUPPORT") +
                                " EXTRUDER\nIS ATTACHED"
                            }
                            else {
                                "ATTACH " +
                                (itemAttachExtruder.extruder == 1 ? "MODEL" : "SUPPORT") +
                                "\nEXTRUDER TO SLOT " + itemAttachExtruder.extruder
                            }
                        }
                        anchors.top: parent.top
                        anchors.topMargin: 50
                        font.letterSpacing: 2
                        font.family: "Antennae"
                        font.weight: Font.Bold
                        font.pixelSize: 21
                        lineHeight: 1.2
                        smooth: false
                        antialiasing: false
                    }

                    ColumnLayout {
                        id: stepsColumnLayout
                        width: 380
                        height: 150
                        spacing: 0
                        anchors.top: main_instruction_text.bottom
                        anchors.topMargin: 25

                        BulletedListItem{
                            bulletNumber: itemAttachExtruder.isAttached ? "4" : "1"
                            bulletText: itemAttachExtruder.isAttached ?
                                          "Close the latch" : "Open the lock"
                        }

                        BulletedListItem{
                            bulletNumber: itemAttachExtruder.isAttached ? "5" : "2"
                            bulletText: itemAttachExtruder.isAttached ?
                                            "Close the lock" : "Open the handle"
                        }

                        BulletedListItem{
                            bulletNumber: itemAttachExtruder.isAttached ? "6" : "3"
                            bulletText: {
                                itemAttachExtruder.isAttached ?
                                        ("Attach swivel clip " +
                                         itemAttachExtruder.extruder) :
                                        ("Load " +
                                        (itemAttachExtruder.extruder == 1 ?
                                             "Model" : "Support") +
                                         " Extruder into Slot " +
                                         itemAttachExtruder.extruder)

                            }
                        }
                    }

                    RoundedButton {
                        id: doneButton
                        buttonWidth: {
                            if(itemAttachExtruder.extruder == 1 &&
                               itemAttachExtruder.isAttached) {
                                360
                            }
                            else if(itemAttachExtruder.extruder == 2 &&
                                itemAttachExtruder.isAttached) {
                                inFreStep ? 100 : 260
                            }
                        }
                        buttonHeight: 44
                        button_text.font.capitalization: Font.MixedCase
                        label: {
                            if(itemAttachExtruder.extruder == 1 &&
                               itemAttachExtruder.isAttached) {
                                "NEXT: Attach Support Extruder"
                            }
                            else if(itemAttachExtruder.extruder == 2 &&
                                itemAttachExtruder.isAttached) {
                                inFreStep ? "DONE" : "RUN CALIBRATION"
                            }
                            else {
                                "DEFAULT"
                            }
                        }
                        label_width: {
                            if(itemAttachExtruder.extruder == 1 &&
                               itemAttachExtruder.isAttached) {
                                360
                            }
                            else if(itemAttachExtruder.extruder == 2 &&
                                itemAttachExtruder.isAttached) {
                                250
                            }
                            else {
                                250
                            }
                        }
                        label_size: {
                            if(itemAttachExtruder.extruder == 1 &&
                               itemAttachExtruder.isAttached) {
                                15
                            }
                            else if(itemAttachExtruder.extruder == 2 &&
                                itemAttachExtruder.isAttached) {
                                18
                            }
                            else {
                                18
                            }
                        }
                        anchors.top: stepsColumnLayout.bottom
                        anchors.topMargin: 30
                        visible: {
                            itemAttachExtruder.extruder == 1 ?
                                 bot.extruderAPresent :
                                 bot.extruderBPresent
                        }
                        button_mouseArea.onClicked: {
                            if(itemAttachExtruder.extruder == 1 &&
                               itemAttachExtruder.isAttached) {
                                itemAttachExtruder.extruder = 2
                            }
                            else if(itemAttachExtruder.extruder == 2 &&
                                    itemAttachExtruder.isAttached) {
                                if(extruderSwipeView.currentIndex != 0) {
                                    extruderSwipeView.swipeToItem(0)
                                }
                                if(!inFreStep) {
                                    if(mainSwipeView.currentIndex != 3) {
                                        mainSwipeView.swipeToItem(3)
                                    }
                                    if(settingsPage.settingsSwipeView.currentIndex != 4) {
                                        settingsPage.settingsSwipeView.swipeToItem(4)
                                    }
                                }
                                else {
                                    mainSwipeView.swipeToItem(0)
                                    inFreStep = false
                                }
                            }
                        }
                    }

                    Item {
                        id: waitingItem
                        width: 350
                        height: 45
                        anchors.top: stepsColumnLayout.bottom
                        anchors.topMargin: 30
                        visible: {
                            itemAttachExtruder.extruder == 1 ?
                                 !bot.extruderAPresent :
                                 !bot.extruderBPresent
                        }

                        BusySpinner {
                            id: waitingSpinner
                            anchors.verticalCenter: parent.verticalCenter
                            spinnerActive: parent.visible
                            spinnerSize: 32
                        }

                        Text {
                            id: bulletNumber
                            text: "WAITING FOR EXTRUDER..."
                            anchors.left: waitingSpinner.right
                            anchors.leftMargin: 10
                            font.letterSpacing: 3
                            font.bold: true
                            color: "#ffffff"
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 16
                            font.family: "Antennae"
                            smooth: false
                            antialiasing: false
                        }
                    }
                }
            }

            Rectangle {
                id: remove_top_lid_messaging
                anchors.fill: parent
                color: "#000000"
                opacity: bot.chamberErrorCode != 45 ?
                             1 : 0

                AnimatedImage {
                    id: remove_top_lid_animation
                    width: sourceSize.width
                    height: sourceSize.height
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/img/remove_top_lid.gif"
                    playing: extruderSwipeView.currentIndex == 1 &&
                             bot.chamberErrorCode != 45
                    opacity: parent.opacity
                    visible: true
                    cache: false
                    smooth: false
                }

                Text {
                    id: remove_top_lid_main_instruction_text
                    color: "#cbcbcb"
                    text: {
                        if(bot.chamberErrorCode == 48) {
                            "CLOSE CHAMBER DOOR\nAND REMOVE TOP LID"
                        } else if(bot.chamberErrorCode == 0) {
                            "REMOVE TOP LID"
                        } else {
                            "???"
                        }
                    }
                    anchors.top: parent.top
                    anchors.topMargin: 200
                    anchors.left: remove_top_lid_animation.right
                    anchors.leftMargin: 50
                    font.letterSpacing: 2
                    font.family: "Antennae"
                    font.weight: Font.Bold
                    font.pixelSize: 21
                    lineHeight: 1.2
                    smooth: false
                    antialiasing: false
                }
            }
        }
    }
}
