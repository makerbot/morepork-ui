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
    property alias buttonAdvancedInfo: buttonAdvancedInfo

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

                    MenuButton {
                        id: buttonChangeLanguage
                        buttonImage.source: "qrc:/img/icon_change_language.png"
                        buttonText.text: "CHANGE LANGUAGE"
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonAssistedLeveling
                        buttonImage.source: "qrc:/img/icon_assisted_leveling.png"
                        buttonText.text: "ASSISTED LEVELING"
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonFirmwareUpdate
                        buttonImage.source: "qrc:/img/icon_software_update.png"
                        buttonText.text: "SOFTWARE UPDATE"
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonCalibrateToolhead
                        buttonImage.source: "qrc:/img/icon_calibrate_toolhead.png"
                        buttonText.text: "CALIBRATE TOOLHEADS"
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonAdvancedInfo
                        buttonImage.source: "qrc:/img/icon_advanced_info.png"
                        buttonText.text: "ADVANCED INFO"
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

                    MenuButton {
                        id: buttonEnglish
                        buttonImage.source: "qrc:/img/icon_change_language.png"
                        buttonText.text: "English"
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonSpanish
                        buttonImage.source: "qrc:/img/icon_change_language.png"
                        buttonText.text: "Espanol"
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonFrench
                        buttonImage.source: "qrc:/img/icon_change_language.png"
                        buttonText.text: "Francais"
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonItalian
                        buttonImage.source: "qrc:/img/icon_change_language.png"
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
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                bot.cancel()
                settingsSwipeView.swipeToItem(0)
            }

            AssistedLeveling {
                currentHES: bot.process.currentHes
                targetHESLower: bot.process.targetHesLower
                targetHESUpper: bot.process.targetHesUpper

                onProcessDone: {
                    state = "base state"
                    settingsSwipeView.swipeToItem(0)
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
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(bot.process.type == ProcessType.CalibrationProcess) {
                    toolheadCalibration.cancelCalibrationPopup.open()
                }
                else {
                    toolheadCalibration.state = "base state"
                    if(settingsSwipeView.currentIndex != 0) {
                        settingsSwipeView.swipeToItem(0)
                    }
                }
            }

            ToolheadCalibration {
                id: toolheadCalibration
                onProcessDone: {
                    state = "base state"
                    settingsSwipeView.swipeToItem(0)
                }
            }
        }

        //settingsSwipeView.index = 5
        Item {
            id: advancedInfoItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            AdvancedInfo {

            }
        }
    }
}
