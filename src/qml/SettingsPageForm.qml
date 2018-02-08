import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0

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
                        buttonText.text: "FIRMWARE UPDATE"
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
                    text: "Step: " + bot.process.levelStep
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
                        case 0:
                            "Level State: " + bot.process.levelState
                            break;
                        case 1:
                            "Level State: " + bot.process.levelState + " LOW"
                            break;
                        case 2:
                            "Level State: " + bot.process.levelState + " HIGH"
                            break;
                        case 3:
                            "Level State: " + bot.process.levelState + " OK"
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
    }
}
