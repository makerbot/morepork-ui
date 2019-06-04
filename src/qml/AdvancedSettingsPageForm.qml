import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0

Item {
    id: advancedSettingsPage
    smooth: false
    anchors.fill: parent

    property alias defaultItem: itemAdvancedSettings
    property alias advancedSettingsSwipeView: advancedSettingsSwipeView

    property alias buttonAdvancedInfo: buttonAdvancedInfo

    property alias buttonPreheat: buttonPreheat

    property alias buttonAssistedLeveling: buttonAssistedLeveling

    property alias buttonCopyLogs: buttonCopyLogs

    property alias copyingLogsPopup: copyingLogsPopup

    property alias copyLogsFinishedPopup: copyLogsFinishedPopup

    property alias buttonResetToFactory: buttonResetToFactory
    property alias resetFactoryConfirmPopup: resetFactoryConfirmPopup
    property bool isResetting: false
    property bool hasReset: false
    property bool isFactoryResetProcess: bot.process.type == ProcessType.FactoryResetProcess
    property bool doneFactoryReset: bot.process.type == ProcessType.FactoryResetProcess &&
                                    bot.process.stateType == ProcessStateType.Done

    property alias buttonSpoolInfo: buttonSpoolInfo

    property alias buttonColorSwatch: buttonColorSwatch

    property alias buttonRaiseLowerBuildPlate: buttonRaiseLowerBuildPlate

    property alias buttonAnalytics: buttonAnalytics

    property alias spoolInfoPage: spoolInfoPage

    property string lightBlue: "#3183af"
    property string otherBlue: "#45a2d3"

    Timer {
        id: closeResetPopupTimer
        interval: 2500
        onTriggered: {
            resetFactoryConfirmPopup.close()
            // Reset all screen positions
            if(settingsPage.settingsSwipeView.currentIndex != 0) {
                settingsPage.settingsSwipeView.swipeToItem(0)
            }
            if(settingsPage.advancedSettingsPage.advancedSettingsSwipeView.currentIndex != 0) {
                settingsPage.advancedSettingsPage.advancedSettingsSwipeView.swipeToItem(0)
            }
            if(advancedPage.advancedSettingsSwipeView.currentIndex != 0) {
                advancedPage.advancedSettingsSwipeView.swipeToItem(0)
            }
            if(mainSwipeView.currentIndex != 0) {
                mainSwipeView.swipeToItem(0)
            }
            fre.setFreStep(FreStep.Welcome)
        }
    }

    onIsFactoryResetProcessChanged: {
        if(isFactoryResetProcess){
            resetFactoryConfirmPopup.open()
            isResetting = true
        }
    }

    onDoneFactoryResetChanged: {
        if(doneFactoryReset) {
            hasReset = true
            closeResetPopupTimer.start()
        }
    }

    SwipeView {
        id: advancedSettingsSwipeView
        currentIndex: 0
        smooth: false
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = advancedSettingsSwipeView.currentIndex
            if (prevIndex == itemToDisplayDefaultIndex) {
                return;
            }
            advancedSettingsSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            setCurrentItem(advancedSettingsSwipeView.itemAt(itemToDisplayDefaultIndex))
            advancedSettingsSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            advancedSettingsSwipeView.itemAt(prevIndex).visible = false
        }

        //advancedSettingsSwipeView.index = 0
        Item {
            id: itemAdvancedSettings
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: {
                if(mainSwipeView.currentIndex == 6) {
                    mainSwipeView
                }
                else if(mainSwipeView.currentIndex == 3) {
                    settingsPage.settingsSwipeView
                }
            }
            property int backSwipeIndex: 0
            smooth: false
            visible: true

            Flickable {
                id: flickableAdvancedSettings
                smooth: false
                flickableDirection: Flickable.VerticalFlick
                interactive: true
                anchors.fill: parent
                contentHeight: columnAdvancedSettings.height

                Column {
                    id: columnAdvancedSettings
                    smooth: false
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.top: parent.top
                    spacing: 0

                    MenuButton {
                        id: buttonAdvancedInfo
                        buttonImage.source: "qrc:/img/icon_advanced_info.png"
                        buttonText.text: qsTr("SENSOR INFO")
                    }

                    MenuButton {
                        id: buttonPreheat
                        buttonImage.source: "qrc:/img/icon_preheat.png"
                        buttonText.text: qsTr("PREHEAT")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonAssistedLeveling
                        buttonImage.source: "qrc:/img/icon_assisted_leveling.png"
                        buttonText.text: qsTr("ASSISTED LEVELING")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonCopyLogs
                        buttonImage.source: "qrc:/img/icon_copy_logs.png"
                        buttonText.text: qsTr("COPY LOGS TO USB")
                        enabled: (!isProcessRunning() && storage.usbStorageConnected)
                    }

                    MenuButton {
                        id: buttonResetToFactory
                        buttonImage.anchors.leftMargin: 30
                        buttonImage.source: "qrc:/img/alert.png"
                        buttonText.text: qsTr("RESTORE FACTORY SETTINGS")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonSpoolInfo
                        buttonImage.source: "qrc:/img/icon_advanced_info.png"
                        buttonText.text: qsTr("SPOOL INFO")
                        visible: false
                    }

                    MenuButton {
                        id: buttonColorSwatch
                        buttonImage.source: "qrc:/img/icon_advanced_info.png"
                        buttonText.text: qsTr("COLOR SWATCH")
                        visible: false
                    }

                    MenuButton {
                        id: buttonRaiseLowerBuildPlate
                        buttonImage.source: "qrc:/img/icon_advanced_info.png"
                        buttonText.text: qsTr("RAISE/LOWER BUILD PLATE")
                        enabled: !isProcessRunning()
                    }

                    MenuButton {
                        id: buttonAnalytics
                        buttonImage.source: "qrc:/img/icon_printer_info.png"
                        buttonText.text: qsTr("ANALYTICS")
                    }
                }
            }
        }

        //advancedSettingsSwipeView.index = 1
        Item {
            id: advancedInfoItem
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            AdvancedInfo {

            }
        }

        //advancedSettingsSwipeView.index = 2
        Item {
            id: preheatItem
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            PreheatPage {

            }
        }

        //advancedSettingsSwipeView.index = 3
        Item {
            id: itemAssistedLeveling
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: 0
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    if(bot.process.type == ProcessType.AssistedLeveling) {
                        assistedLevel.cancelAssistedLevelingPopup.open()
                    }
                    else {
                        assistedLevel.state = "base state"
                        if(advancedSettingsSwipeView.currentIndex != 0) {
                            advancedSettingsSwipeView.swipeToItem(0)
                        }
                    }
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                bot.cancel()
                assistedLevel.state = "cancelling"
                advancedSettingsSwipeView.swipeToItem(0)
                mainSwipeView.swipeToItem(0)
            }

            AssistedLeveling {
                id: assistedLevel
                currentHES: bot.process.currentHes
                targetHESLower: bot.process.targetHesLower
                targetHESUpper: bot.process.targetHesUpper

                onProcessDone: {
                    state = "base state"
                    if(advancedSettingsSwipeView.currentIndex != 0) {
                        advancedSettingsSwipeView.swipeToItem(0)
                    }
                }
            }
        }

        //advancedSettingsSwipeView.index = 4
        Item {
            id: spoolInfoItem
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            SpoolInfoPage {
                id: spoolInfoPage
            }
        }

        //advancedSettingsSwipeView.index = 5
        Item {
            id: colorSwatchItem
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            ColorSwatchPage {
                id: colorSwatch
            }
        }

        //advancedSettingsSwipeView.index = 6
        Item {
            id: raiseLowerBuildPlateItem
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            RaiseLowerBuildPlateItem {
                id: raiseLowerBuildPlate
            }
        }

        //advancedSettingsSwipeView.index = 7
        Item {
            id: analyticsItem
            property var backSwiper: advancedSettingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            AnalyticsScreen {
                id: analyticsScreen
            }
        }

    }

    BusyPopup {
        property bool initialized: false
        property bool zipLogsInProgress: false
        property string logBundlePath: ""

        id: copyingLogsPopup
        visible: zipLogsInProgress
        busyPopupText: qsTr("COPYING LOGS TO USB...")
    }

    ModalPopup {
        property bool succeeded: false

        id: copyLogsFinishedPopup
        visible: false
        popup_contents.contentItem: Item {
            anchors.fill: parent
            TitleText {
                text: copyLogsFinishedPopup.succeeded ?
                            qsTr("FINISHED COPYING LOGS TO USB") :
                            qsTr("FAILED TO COPY LOGS TO USB")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
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
        parent: overlay
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
                        text: qsTr("RESET TO FACTORY")
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
                            bot.resetToFactory(true)
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
                        text: qsTr("CANCEL")
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
                height: isResetting ? 180 : 130
                spacing: 0
                anchors.top: parent.top
                anchors.topMargin: isResetting ? 50 : 35
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: alert_text
                    color: "#cbcbcb"
                    text: hasReset ? qsTr("RESET SUCCESSFUL") : isResetting ? qsTr("RESETTING TO FACTORY...") : qsTr("RESET TO FACTORY")
                    font.letterSpacing: 3
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: "Antennae"
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Text {
                    id: description_text
                    color: "#cbcbcb"
                    text: hasReset ? "" : isResetting ? qsTr("Please wait.") : qsTr("This will erase all history, preferences, account information and calibration settings.")
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

                BusySpinner {
                    id: resettingSpinner
                    spinnerActive: isResetting
                    spinnerSize: 64
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
