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
    property alias buttonResetToFactory: buttonResetToFactory
    property alias resetFactoryConfirmPopup: resetFactoryConfirmPopup
    property bool isResetting: false
    property bool hasReset: false
    property bool doneFactoryReset: bot.process.type == ProcessType.FactoryResetProcess &&
                                    bot.process.stateType == ProcessStateType.Done

    smooth: false
    Timer {
        id: closeResetPopupTimer
        interval: 2500
        onTriggered: {
            resetFactoryConfirmPopup.close()
            mainSwipeView.swipeToItem(0)
        }
    }

    onDoneFactoryResetChanged: {
        if(doneFactoryReset) {
            hasReset = true
            closeResetPopupTimer.start()
        }
    }

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

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonResetToFactory
                        buttonImage.anchors.leftMargin: 30
                        buttonImage.source: "qrc:/img/alert.png"
                        buttonText.text: "RESET TO FACTORY"
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
            smooth: false
            visible: false

            ToolheadCalibration {

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

    Popup {
        id: resetFactoryConfirmPopup
        width: 800
        height: 480
        modal: true
        dim: false
        focus: true
        closePolicy: Popup.NoAutoClose
        background: Rectangle {
            id: popupBackgroundDim
            color: "#000000"
            rotation: rootItem.rotation == 180 ? 180 : 0
            opacity: 0.5
            anchors.fill: parent
        }
        enter: Transition {
            NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.InQuad; from: 0.0; to: 1.0 }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.InQuad; from: 1.0; to: 0.0 }
        }

        onClosed: {
            isResetting = false
            hasReset = false
            clearCalibrationSettings.checked = false
        }

        Rectangle {
            id: basePopupItem
            color: "#000000"
            rotation: rootItem.rotation == 180 ? 180 : 0
            width: 720
            height: 265
            radius: 10
            border.width: 2
            border.color: "#ffffff"
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: rotation == 180 ? 55 : -55
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                id: horizontal_divider
                width: 720
                height: 2
                color: "#ffffff"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 72
                visible: !isResetting
            }

            Rectangle {
                id: vertical_divider
                x: 359
                y: 328
                width: 2
                height: 72
                color: "#ffffff"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !isResetting
            }

            Item {
                id: buttonBar
                width: 720
                height: 72
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                visible: !isResetting

                Rectangle {
                    id: yes_rectangle
                    x: 0
                    y: 0
                    width: 360
                    height: 72
                    color: "#00000000"
                    radius: 10

                    Text {
                        id: yes_text
                        color: "#ffffff"
                        text: "YES"
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: false
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: "Antennae"
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MouseArea {
                        id: yes_mouseArea
                        anchors.fill: parent
                        onPressed: {
                            yes_text.color = "#000000"
                            yes_rectangle.color = "#ffffff"
                        }
                        onReleased: {
                            yes_text.color = "#ffffff"
                            yes_rectangle.color = "#00000000"
                        }
                        onClicked: {
                            bot.resetToFactory(clearCalibrationSettings.checked)
                            isResetting = true
                        }
                    }
                }

                Rectangle {
                    id: no_rectangle
                    x: 360
                    y: 0
                    width: 360
                    height: 72
                    color: "#00000000"
                    radius: 10

                    Text {
                        id: no_text
                        color: "#ffffff"
                        text: "NO"
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: "Antennae"
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MouseArea {
                        id: no_mouseArea
                        anchors.fill: parent
                        onPressed: {
                            no_text.color = "#000000"
                            no_rectangle.color = "#ffffff"
                        }
                        onReleased: {
                            no_text.color = "#ffffff"
                            no_rectangle.color = "#00000000"
                        }
                        onClicked: {
                            resetFactoryConfirmPopup.close()
                        }
                    }
                }
            }

            ColumnLayout {
                id: columnLayout
                width: 590
                height: 160
                spacing: 0
                anchors.top: parent.top
                anchors.topMargin: isResetting ? 50 : 25
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: alert_text
                    color: "#cbcbcb"
                    text: hasReset ? "RESET SUCCESSFUL" : isResetting ? "RESETTING TO FACTORY..." : "RESET TO FACTORY"
                    font.letterSpacing: 3
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: "Antennae"
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Item {
                    id: emptyItem
                    width: 10
                    height: 10
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    visible: !hasReset
                }

                Text {
                    id: description_text
                    color: "#cbcbcb"
                    text: hasReset ? "" : isResetting ? "Please wait." : "Are you sure?"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.weight: Font.Light
                    wrapMode: Text.WordWrap
                    font.family: "Antennae"
                    font.pixelSize: 18
                    lineHeight: 1.3
                    visible: !hasReset
                }

                RowLayout {
                    id: rowLayout
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    visible: !hasReset

                    CheckBox {
                        id: clearCalibrationSettings
                        checked: false
                        visible: !isResetting && !hasReset
                    }

                    Text {
                        id: clear_calibration_settings_text
                        color: "#cbcbcb"
                        text: "Clear calibration settings"
                        font.letterSpacing: 2
                        font.family: "Antennae"
                        font.weight: Font.Light
                        font.pixelSize: 16
                        visible: !isResetting && !hasReset
                    }

                    BusyIndicator {
                        id: busyIndicator
                        running: isResetting && !hasReset
                        visible: isResetting && !hasReset
                    }
                }
            }
        }
    }
}
