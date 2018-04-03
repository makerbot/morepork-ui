import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    id: settingsPageForm
    property alias settingsSwipeView: settingsSwipeView
    property alias defaultItem: itemSettings
    property alias buttonChangeLanguage: buttonChangeLanguage
    property alias buttonEnglish: buttonEnglish
    property alias buttonSpanish: buttonSpanish
    property alias buttonFrench: buttonFrench
    property alias buttonItalian: buttonItalian
    property alias buttonAssistedLeveling: buttonAssistedLeveling
    property alias buttonFirmwareUpdate: buttonFirmwareUpdate
    property alias buttonCalibrateToolhead: buttonCalibrateToolhead

    smooth: false

    SwipeView {
        id: settingsSwipeView
        currentIndex: 0
        smooth: false
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = settingsSwipeView.currentIndex
            settingsSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            setCurrentItem(settingsSwipeView.itemAt(itemToDisplayDefaultIndex))
            settingsSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            settingsSwipeView.itemAt(prevIndex).visible = false
        }

        // settingsSwipeView.index = 0
        Item {
            id: itemSettings
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: mainSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            Flickable {
                id: flickableSettings
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnSettings.height

                Column {
                    id: columnSettings
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MoreporkButton {
                        id: buttonChangeLanguage
                        buttonText.text: qsTr("Change Language") + cpUiTr.emptyStr
                    }

                    Item { width: parent.width; height: 1; smooth: false; Rectangle { color: "#505050"; smooth: false; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonAssistedLeveling
                        buttonText.text: "Assisted Leveling"
                    }

                    Item { width: parent.width; height: 1; smooth: false; Rectangle { color: "#505050"; smooth: false; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonFirmwareUpdate
                        buttonText.text: "SOFTWARE UPDATE"
                    }

                    Item { width: parent.width; height: 1; smooth: false; Rectangle { color: "#505050"; smooth: false; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonCalibrateToolhead
                        buttonText.text: "CALIBRATE TOOLHEADS"
                    }
                }
            }
        }

        // settingsSwipeView.index = 1
        Item {
            id: itemLanguages
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            Flickable {
                id: flickableLanguages
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnLanguages.height

                Column {
                    id: columnLanguages
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MoreporkButton {
                        id: buttonEnglish
                        buttonText.text: "English"
                    }

                    Item { width: parent.width; height: 1; smooth: false; Rectangle { color: "#505050"; smooth: false; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonSpanish
                        buttonText.text: "Espanol"
                    }

                    Item { width: parent.width; height: 1; smooth: false; Rectangle { color: "#505050"; smooth: false; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonFrench
                        buttonText.text: "Francais"
                    }

                    Item { width: parent.width; height: 1; smooth: false; Rectangle { color: "#505050"; smooth: false; anchors.fill: parent } }

                    MoreporkButton {
                        id: buttonItalian
                        buttonText.text: "Italiano"
                    }
                }
            }
        }

        // settingsSwipeView.index = 2
        Item {
            id: itemAssistedLeveling
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            Text {
                color: "#ffffff"
                text: "Bot Not in Assisted Leveling Process"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                visible: bot.process.type != ProcessType.AssistedLeveling
                antialiasing: false
                smooth: false
                font.letterSpacing: 3
                font.family: "Antenna"
                font.weight: Font.Light
                font.pixelSize: 21
            }

            ColumnLayout {
                id: columnLayout
                anchors.fill: parent
                visible: bot.process.type == ProcessType.AssistedLeveling

                Text {
                    id: text5
                    color: "#ffffff"
                    text: "Step: " + bot.process.stepStr
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    antialiasing: false
                    smooth: false
                    font.letterSpacing: 3
                    font.family: "Antenna"
                    font.weight: Font.Light
                    font.pixelSize: 21
                }

                Text {
                    id: text1
                    color: "#ffffff"
                    text: "Current HES: " + bot.process.currentHes
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    antialiasing: false
                    smooth: false
                    font.letterSpacing: 3
                    font.family: "Antenna"
                    font.weight: Font.Light
                    font.pixelSize: 21
                }

                Text {
                    id: text2
                    color: "#ffffff"
                    text: "Target HES Upper: " + bot.process.targetHesUpper
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    antialiasing: false
                    smooth: false
                    font.letterSpacing: 3
                    font.family: "Antenna"
                    font.weight: Font.Light
                    font.pixelSize: 21
                }

                Text {
                    id: text3
                    color: "#ffffff"
                    text: "Target HES Lower: " + bot.process.targetHesLower
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    antialiasing: false
                    smooth: false
                    font.letterSpacing: 3
                    font.family: "Antenna"
                    font.weight: Font.Light
                    font.pixelSize: 21
                }

                Text {
                    id: text4
                    color: "#ffffff"
                    text: {
                        switch(bot.process.levelState)
                        {
                        case 1:
                            "Level State: LOW"
                            break;
                        case 2:
                            "Level State: HIGH"
                            break;
                        case 3:
                            "Level State: OK"
                            break;
                        default:
                            "Level State: " + bot.process.levelState
                            break;
                        }
                    }
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    antialiasing: false
                    smooth: false
                    font.letterSpacing: 3
                    font.family: "Antenna"
                    font.weight: Font.Light
                    font.pixelSize: 21
                }
            }
        }

        //settingsSwipeView.index = 3
        Item {
            id: firmwareUpdateItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            FirmwareUpdatePage {

            }
        }

        //settingsSwipeView.index = 4
        Item {
            id: calibrateToolheadsItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            Rectangle {
                color: "#000000"
                anchors.fill: parent
            }

            Switch {
                id: toolheadA
                anchors.horizontalCenterOffset: -250
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                Text{
                    text: "Toolhead A/1"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -20
                    color: "#ffffff"
                    font.family: "Antennae"
                    font.weight: Font.Light
                    font.pixelSize: 18
                }
            }

            Switch {
                id: toolheadB
                anchors.horizontalCenterOffset: -50
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                Text{
                    text: "Toolhead B/2"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -20
                    color: "#ffffff"
                    font.family: "Antennae"
                    font.weight: Font.Light
                    font.pixelSize: 18
                }
            }

            RoundedButton {
                id: xyCalibrateButton
                anchors.top: parent.top
                anchors.topMargin: 90
                anchors.horizontalCenterOffset: -150
                anchors.horizontalCenter: parent.horizontalCenter
                buttonWidth: 240
                buttonHeight: 50
                label: "XY Calibrate"
                button_mouseArea.onClicked: {
                    if(toolheadA.checked && toolheadB.checked) {
                        bot.calibrateToolheads(["a","b"], ["x","y"])
                    }
                    else if(toolheadA.checked) {
                        bot.calibrateToolheads(["a"], ["x","y"])
                    }
                    else if(toolheadB.checked) {
                        bot.calibrateToolheads(["b"], ["x","y"])
                    }
                }
            }

            RoundedButton {
                id: zCalibrateButton
                anchors.horizontalCenterOffset: -150
                anchors.top: parent.top
                anchors.topMargin: 165
                anchors.horizontalCenter: parent.horizontalCenter
                buttonWidth: 200
                buttonHeight: 50
                label: "Z Calibrate"
                button_mouseArea.onClicked: {
                    if(toolheadA.checked && toolheadB.checked) {
                        bot.calibrateToolheads(["a","b"], ["z"])
                    }
                    else if(toolheadA.checked) {
                        bot.calibrateToolheads(["a"], ["z"])
                    }
                    else if(toolheadB.checked) {
                        bot.calibrateToolheads(["b"], ["z"])
                    }
                }
            }

            RoundedButton {
                id: buildPlateAttached
                anchors.top: parent.top
                anchors.topMargin: 235
                anchors.horizontalCenterOffset: -150
                anchors.horizontalCenter: parent.horizontalCenter
                buttonWidth: 240
                buttonHeight: 75
                label: "BUILD PLATE ATTACHED"
                button_mouseArea.onClicked: {
                    bot.buildPlateState(true)
                }
            }

            RoundedButton {
                id: buildPlateRemoved
                anchors.horizontalCenterOffset: -150
                anchors.top: parent.top
                anchors.topMargin: 325
                anchors.horizontalCenter: parent.horizontalCenter
                buttonWidth: 220
                buttonHeight: 75
                label: "BUILD PLATE REMOVED"
                button_mouseArea.onClicked: {
                    bot.buildPlateState(false)
                }
            }

            Text {
                id: currentStepText
                text: bot.process.stepStr
                color: "#ffffff"
                font.family: "Antennae"
                font.pixelSize: 18
                font.weight: Font.Light
                anchors.left: parent.left
                anchors.leftMargin: 500
                anchors.top: parent.top
                anchors.topMargin: 210
            }
        }
    }
}
