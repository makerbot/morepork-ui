import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0

Item {
    id: extruderPage
    property alias defaultItem: itemExtruder
    property alias extruderSwipeView: extruderSwipeView
    property bool isTopLidOpen: bot.chamberErrorCode == 45
    property alias itemAttachExtruder: itemAttachExtruder
    property alias handle_top_lid_next_button: handle_top_lid_next_button
    property alias attach_extruder_next_button: attach_extruder_next_button
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
                extruderSerialNo: "000-000"

                // References to parent properties from a child
                // should only be made at the place of the child's
                // component's usage within the parent. Qt Creator/QML
                // will NOT complain referring a "parent" property
                // from within the child's own implementation file as
                // long as it is available to it atleast at one place
                // of usage throughout the project. But then
                // using the component elsewhere wil not work as the
                // "parent" referred in the implementaion file isn't
                // accessible in the new scope.
                attachButton {
                    button_mouseArea.onClicked: {
                        itemAttachExtruder.extruder = extruderID
                        itemAttachExtruder.state = "base state"
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
                extruderSerialNo: "000-000"

                // References to parent properties from a child
                // should only be made at the place of the child's
                // component's usage within the parent. Qt Creator/QML
                // will NOT complain referring a "parent" property
                // from within the child's own implementation file as
                // long as it is available to it atleast at one place
                // of usage throughout the project. But then
                // using the component elsewhere wil not work as the
                // "parent" referred in the implementaion file isn't
                // accessible in the new scope.
                attachButton {
                    button_mouseArea.onClicked: {
                        itemAttachExtruder.extruder = extruderID
                        itemAttachExtruder.state = "base state"
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
                    itemAttachExtruder.state = "base state"
                    extruderSwipeView.swipeToItem(0)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                extruderSwipeView.swipeToItem(0)
                mainSwipeView.swipeToItem(0)
            }

            Rectangle {
                id: handle_top_lid_messaging
                anchors.fill: parent
                color: "#000000"
                opacity: 1

                Image {
                    id: handle_top_lid_image
                    width: sourceSize.width
                    height: sourceSize.height
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    source: {
                        if(itemAttachExtruder.state == "base state") {
                            "qrc:/img/remove_top_lid.png"
                        }
                        else if(itemAttachExtruder.state == "close_top_lid") {
                            "qrc:/img/error_close_lid.png"
                        }
                    }
                    visible: true
                    cache: false
                    smooth: false
                }

                Text {
                    id: handle_top_lid_main_instruction_text
                    color: "#cbcbcb"
                    text: {
                        if(itemAttachExtruder.state == "close_top_lid") {
                            if(bot.chamberErrorCode == 48) {
                                "CLOSE CHMABER DOOR"
                            }
                            else if(bot.chamberErrorCode == 45) {
                                "PLACE TOP LID"
                            }
                            else if(bot.chamberErrorCode == 0) {
                                "PLACE TOP LID"
                            }
                        }
                        else if(itemAttachExtruder.state == "base state") {
                            if(bot.chamberErrorCode == 48) {
                                "CLOSE CHAMBER DOOR"
                            }
                            if(bot.chamberErrorCode == 45) {
                                "REMOVE TOP LID"
                            }
                            else if(bot.chamberErrorCode == 0) {
                                "REMOVE TOP LID"
                            }
                        }
                    }
                    anchors.top: parent.top
                    anchors.topMargin: 150
                    anchors.left: handle_top_lid_image.right
                    anchors.leftMargin: 50
                    font.letterSpacing: 2
                    font.family: "Antennae"
                    font.weight: Font.Bold
                    font.pixelSize: 21
                    lineHeight: 1.2
                    smooth: false
                    antialiasing: false
                }

                RoundedButton {
                    id: handle_top_lid_next_button
                    buttonWidth: {
                        if(itemAttachExtruder.state == "base state") {
                            125
                        }
                        else if(itemAttachExtruder.state == "close_top_lid") {
                            if(itemAttachExtruder.extruder == 2) {
                                inFreStep ? 125 : 275
                            }
                        }
                        else {
                            125
                        }
                    }
                    buttonHeight: 50
                    anchors.top: handle_top_lid_main_instruction_text.bottom
                    anchors.topMargin: 50
                    anchors.left: handle_top_lid_image.right
                    anchors.leftMargin: 50
                    label_size: 18
                    label: {
                        if(itemAttachExtruder.state == "base state") {
                            "NEXT"
                        }
                        else if(itemAttachExtruder.state == "close_top_lid") {
                            if(itemAttachExtruder.extruder == 2) {
                                inFreStep ? "DONE" : "RUN CALIBRATION"
                            }
                        }
                        else {
                            "DEFAULT"
                        }
                    }
                    disable_button: {
                        if(itemAttachExtruder.state == "base state") {
                            (bot.chamberErrorCode == 0 ||
                             bot.chamberErrorCode == 48)
                        }
                        else if(itemAttachExtruder.state == "close_top_lid") {
                            (bot.chamberErrorCode == 45 ||
                             bot.chamberErrorCode == 48)
                        }
                        else {
                            false
                        }
                    }
                }
            }

            AnimatedImage {
                id: attach_extruder_image
                width: sourceSize.width
                height: sourceSize.height
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.verticalCenter: parent.verticalCenter
                source: ""
                playing: {
                    extruderSwipeView.currentIndex == 1 &&
                    (itemAttachExtruder.state == "attach_extruder_step1" ||
                     itemAttachExtruder.state == "attach_extruder_step2" ||
                     itemAttachExtruder.state == "attach_swivel_clips")
                }
                visible: true
                cache: false
                smooth: false
                opacity: 0

                Item {
                    id: baseItem
                    width: 400
                    height: 420
                    anchors.left: parent.right
                    anchors.leftMargin: 0
                    anchors.verticalCenter: attach_extruder_image.verticalCenter
                    smooth: false

                    Text {
                        id: main_instruction_text
                        color: "#cbcbcb"
                        text: ""
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

                    Text {
                        id: sub_instruction_text
                        color: "#cbcbcb"
                        text: ""
                        anchors.top: main_instruction_text.bottom
                        anchors.topMargin: 25
                        font.family: "Antennae"
                        font.weight: Font.Light
                        font.pixelSize: 18
                        lineHeight: 1.1
                        smooth: false
                        antialiasing: false
                        opacity: 0
                    }

                    ColumnLayout {
                        id: stepsColumnLayout
                        width: 380
                        height: 150
                        spacing: 0
                        anchors.top: main_instruction_text.bottom
                        anchors.topMargin: 25

                        BulletedListItem {
                            id: step1
                            bulletNumber: ""
                            bulletText: ""
                        }

                        BulletedListItem {
                            id: step2
                            bulletNumber: ""
                            bulletText: ""
                        }

                        BulletedListItem {
                            id: step3
                            bulletNumber: ""
                            bulletText: ""
                        }
                    }

                    Item {
                        id: waitingItem
                        width: 350
                        height: 45
                        anchors.top: stepsColumnLayout.bottom
                        anchors.topMargin: 40
                        visible: false

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

                    RoundedButton {
                        id: attach_extruder_next_button
                        anchors.top: stepsColumnLayout.bottom
                        anchors.topMargin: 35
                        buttonHeight: 50
                        button_text.font.capitalization: Font.MixedCase
                    }
                }
            }

            states: [
                State {
                    name: "attach_extruder_step1"

                    PropertyChanges {
                        target: attach_extruder_image
                        source: {
                            itemAttachExtruder.extruder == 1 ?
                                        "qrc:/img/attach_extruder_1_step1.gif" :
                                        "qrc:/img/attach_extruder_2_step1.gif"
                        }
                        opacity: 1
                    }

                    PropertyChanges {
                        target: handle_top_lid_messaging
                        opacity: 0
                    }

                    PropertyChanges {
                        target: main_instruction_text
                        text: {
                            if(itemAttachExtruder.extruder == 1) {
                                "INSERT THE MODEL\nEXTRUDER INTO SLOT 1"
                            }
                            else {
                                "INSERT THE SUPPORT\nEXTRUDER INTO SLOT 2"
                            }
                        }
                    }

                    PropertyChanges {
                        target: step1
                        bulletNumber: "1"
                        bulletText: "Flip open the lock"
                    }

                    PropertyChanges {
                        target: step2
                        bulletNumber: "2"
                        bulletText: "Flip open the front latch"
                    }

                    PropertyChanges {
                        target: step3
                        bulletNumber: "3"
                        bulletText: itemAttachExtruder.extruder == 1 ?
                                        "Insert the Model 1 Extruder into\nSlot 1" :
                                        "Insert the Support 2 Extruder into\nSlot 2"
                    }

                    PropertyChanges {
                        target: attach_extruder_next_button
                        label: "NEXT"
                        label_width: 125
                        label_size: 18
                        buttonWidth: 125
                        visible: {
                            itemAttachExtruder.extruder == 1 ?
                                 bot.extruderAPresent :
                                 bot.extruderBPresent
                        }
                    }

                    PropertyChanges {
                        target: waitingItem
                        visible: {
                            itemAttachExtruder.extruder == 1 ?
                                 !bot.extruderAPresent :
                                 !bot.extruderBPresent
                        }
                    }
                },

                State {
                    name: "attach_extruder_step2"

                    PropertyChanges {
                        target: handle_top_lid_messaging
                        opacity: 0
                    }

                    PropertyChanges {
                        target: attach_extruder_image
                        source: {
                            itemAttachExtruder.extruder == 1 ?
                                        "qrc:/img/attach_extruder_1_step2.gif" :
                                        "qrc:/img/attach_extruder_2_step2.gif"
                        }
                        opacity: 1
                    }

                    PropertyChanges {
                        target: main_instruction_text
                        text: "LOCK THE EXTRUDER\nIN PLACE AND ATTACH\nTHE SWIVEL CLIP"
                    }

                    PropertyChanges {
                        target: step1
                        bulletNumber: "4"
                        bulletText: "Close the front latch"
                    }

                    PropertyChanges {
                        target: step2
                        bulletNumber: "5"
                        bulletText: "Flip the lock closed"
                    }

                    PropertyChanges {
                        target: step3
                        bulletNumber: "6"
                        bulletText: itemAttachExtruder.extruder == 1 ?
                                        "Attach swivel clip 1" :
                                        "Attach swivel clip 2"
                    }

                    PropertyChanges {
                        target: attach_extruder_next_button
                        label: {
                            if(itemAttachExtruder.extruder == 1 &&
                               itemAttachExtruder.isAttached) {
                                "NEXT: Attach Support Extruder"
                            }
                            else if(itemAttachExtruder.extruder == 2 &&
                                itemAttachExtruder.isAttached) {
                                "NEXT"
                            }
                        }
                        label_width: {
                            if(itemAttachExtruder.extruder == 1 &&
                               itemAttachExtruder.isAttached) {
                                360
                            }
                            else if(itemAttachExtruder.extruder == 2 &&
                                itemAttachExtruder.isAttached) {
                                125
                            }
                        }

                        label_size: {
                            if(itemAttachExtruder.extruder == 1 &&
                               itemAttachExtruder.isAttached) {
                                16
                            }
                            else if(itemAttachExtruder.extruder == 2 &&
                                itemAttachExtruder.isAttached) {
                                18
                            }
                        }

                        buttonWidth: {
                            if(itemAttachExtruder.extruder == 1 &&
                               itemAttachExtruder.isAttached) {
                                380
                            }
                            else if(itemAttachExtruder.extruder == 2 &&
                                itemAttachExtruder.isAttached) {
                                125
                            }
                        }

                        visible: {
                            itemAttachExtruder.extruder == 1 ?
                                 bot.extruderAPresent :
                                 bot.extruderBPresent
                        }
                    }

                    PropertyChanges {
                        target: waitingItem
                        visible: false
                    }
                },

                State {
                    name: "attach_swivel_clips"

                    PropertyChanges {
                        target: attach_extruder_image
                        source: "qrc:/img/attach_extruder_swivel_clips.gif"
                        opacity: 1
                    }

                    PropertyChanges {
                        target: main_instruction_text
                        anchors.topMargin: 80
                        text: "ENSURE THE MATERIAL\nCLIPS ARE ATTACHED"
                    }

                    PropertyChanges {
                        target: sub_instruction_text
                        text: "The material clips guide the material\ninto the correct extruders."
                        opacity: 1
                    }

                    PropertyChanges {
                        target: attach_extruder_next_button
                        anchors.topMargin: -60
                        label: "NEXT"
                        label_width: 125
                        label_size: 18
                        buttonWidth: 125
                        visible: true
                    }

                    PropertyChanges {
                        target: stepsColumnLayout
                        opacity: 0
                    }

                    PropertyChanges {
                        target: handle_top_lid_messaging
                        opacity: 0
                    }
                },

                State {
                    name: "close_top_lid"

                    PropertyChanges {
                        target: attach_extruder_image
                        opacity: 0
                    }

                    PropertyChanges {
                        target: handle_top_lid_messaging
                        opacity: 1
                    }
                }
            ]
        }
    }
}
