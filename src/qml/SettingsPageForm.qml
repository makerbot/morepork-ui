import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0

Item {
    id: settingsPage
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
    property alias buttonWiFi: buttonWiFi
    property alias buttonAdvancedInfo: buttonAdvancedInfo
    property alias buttonAccounts: buttonAccounts
    property alias buttonSpoolInfo: buttonSpoolInfo
    property alias buttonCopyLogs: buttonCopyLogs
    property alias copyingLogsPopup: copyingLogsPopup
    property alias copyLogsFinishedPopup: copyLogsFinishedPopup
    property alias buttonResetToFactory: buttonResetToFactory
    property alias buttonColorSwatch: buttonColorSwatch
    property alias buttonPrinterName: buttonPrinterName
    property alias namePrinter: namePrinter
    property alias resetFactoryConfirmPopup: resetFactoryConfirmPopup
    property bool isResetting: false
    property bool hasReset: false
    property bool isFactoryResetProcess: bot.process.type == ProcessType.FactoryResetProcess
    property bool doneFactoryReset: bot.process.type == ProcessType.FactoryResetProcess &&
                                    bot.process.stateType == ProcessStateType.Done
    property alias signInPage: signInPage
    property alias wifiPage: wifiPage
    property string lightBlue: "#3183af"
    property string otherBlue: "#45a2d3"
    property alias spoolInfoPage: spoolInfoPage

    smooth: false
    Timer {
        id: closeResetPopupTimer
        interval: 2500
        onTriggered: {
            resetFactoryConfirmPopup.close()
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
        id: settingsSwipeView
        currentIndex: 0
        smooth: false
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = settingsSwipeView.currentIndex
            if (prevIndex == itemToDisplayDefaultIndex) {
                return;
            }

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
                        opacity: !isProcessRunning() ? 1 : 0.3
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
                        opacity: !isProcessRunning() ? 1 : 0.3
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonWiFi
                        buttonImage.source: "qrc:/img/icon_wifi.png"
                        buttonText.text: "WiFi"
                        Switch {
                            id: switchWifi
                            indicator: Rectangle {
                                    implicitWidth: 68
                                    implicitHeight: 35
                                    x: switchWifi.leftPadding
                                    y: parent.height / 2 - height / 2
                                    radius: 17
                                    color: switchWifi.checked ? lightBlue : "#ffffff"
                                    border.color: switchWifi.checked ? "#3183af" : "#cccccc"

                                    Rectangle {
                                        x: switchWifi.checked ? parent.width - width - 3 : 3
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 32
                                        height: 32
                                        radius: 16
                                        color: switchWifi.down ? "#cccccc" : "#ffffff"
                                        border.color: switchWifi.checked ? lightBlue : "#999999"
                                    }
                                }
                            checked: bot.net.wifiEnabled
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 50

                            onClicked: {
                                if(switchWifi.checked) {
                                    bot.toggleWifi(true)
                                }
                                else if(!switchWifi.checked) {
                                    bot.toggleWifi(false)
                                }
                            }
                        }
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
                        id: buttonAccounts
                        buttonImage.source: "qrc:/img/icon_authorize_account.png"
                        buttonText.text: "AUTHORIZE MAKERBOT ACCOUNT"
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonSpoolInfo
                        buttonImage.source: "qrc:/img/icon_advanced_info.png"
                        buttonText.text: "SPOOL INFO"
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        property bool enabled: (!isProcessRunning() &&
                                                storage.usbStorageConnected)
                        id: buttonCopyLogs

                        buttonImage.source: "qrc:/img/icon_advanced_info.png"
                        buttonText.text: "COPY LOGS TO USB"
                        opacity: enabled ? 1 : 0.3
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonResetToFactory
                        buttonImage.anchors.leftMargin: 30
                        buttonImage.source: "qrc:/img/alert.png"
                        buttonText.text: "RESET TO FACTORY"
                        opacity: !isProcessRunning() ? 1 : 0.3
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonColorSwatch
                        buttonImage.anchors.leftMargin: 30
                        buttonImage.source: "qrc:/img/icon_advanced_info.png"
                        buttonText.text: "COLOR SWATCH"
                    }

                    Item { width: parent.width; height: 1; smooth: false;
                        Rectangle { color: "#505050"; smooth: false; anchors.fill: parent }
                    }

                    MenuButton {
                        id: buttonPrinterName
                        buttonImage.anchors.leftMargin: 30
                        buttonImage.source: "qrc:/img/icon_advanced_info.png"
                        buttonText.text: "PRINTER NAME"
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
                if(bot.process.type == ProcessType.AssistedLeveling) {
                    assistedLevel.cancelAssistedLevelingPopup.open()
                }
                else {
                    assistedLevel.state = "base state"
                    settingsSwipeView.swipeToItem(0)
                }
            }

            AssistedLeveling {
                id: assistedLevel
                currentHES: bot.process.currentHes
                targetHESLower: bot.process.targetHesLower
                targetHESUpper: bot.process.targetHesUpper

                onProcessDone: {
                    state = "base state"
                    if(settingsSwipeView.currentIndex != 0) {
                        settingsSwipeView.swipeToItem(0)
                    }
                }
            }
        }

        //settingsSwipeView.index = 3
        Item {
            id: firmwareUpdateItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    settingsSwipeView.swipeToItem(0)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                bot.cancel()
                settingsSwipeView.swipeToItem(0)
                mainSwipeView.swipeToItem(0)
            }

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
                if(!inFreStep) {
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
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                bot.cancel()
                toolheadCalibration.state = "base state"
                settingsSwipeView.swipeToItem(0)
                mainSwipeView.swipeToItem(0)
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
            id: wifiItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false
            property bool hasAltBack: true

            function altBack() {
                if(!inFreStep) {
                    settingsSwipeView.swipeToItem(0)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                settingsSwipeView.swipeToItem(0)
                mainSwipeView.swipeToItem(0)
            }

            WiFiPageForm {
                id: wifiPage

            }

        }

        //settingsSwipeView.index = 6
        Item {
            id: advancedInfoItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            AdvancedInfo {

            }
        }

        //settingsSwipeView.index = 7
        Item {
            id: accountsItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    signInPage.backToSettings()
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                signInPage.backToSettings()
                mainSwipeView.swipeToItem(0)
            }

            SignInPage {
                id: signInPage
            }
        }

        //settingsSwipeView.index = 8
        Item {
            id: spoolInfoItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            SpoolInfoPage {
                id: spoolInfoPage
            }
        }

        //settingsSwipeView.index = 9
        Item {
            id: colorSwatchItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            smooth: false
            visible: false

            ColorSwatchPage {
                id: colorSwatch
            }
        }

        //settingsSwipeView.index = 10
        Item {
            id: namePrinterItem
            property var backSwiper: settingsSwipeView
            property int backSwipeIndex: 0
            property bool hasAltBack: true
            smooth: false
            visible: false

            function altBack() {
                if(!inFreStep) {
                    settingsSwipeView.swipeToItem(0)
                }
                else {
                    skipFreStepPopup.open()
                }
            }

            function skipFreStepAction() {
                settingsSwipeView.swipeToItem(0)
                mainSwipeView.swipeToItem(0)
            }

            NamePrinterPage {
                id: namePrinter
            }
        }
    }

    BusyPopup {
        property bool initialized: false
        property bool zipLogsInProgress: false
        property string logBundlePath: ""

        id: copyingLogsPopup
        visible: zipLogsInProgress
        busyPopupText: "COPYING LOGS TO USB..."
    }

    ModalPopup {
        property bool succeeded: false

        id: copyLogsFinishedPopup
        visible: false
        popup_contents.contentItem: Item {
            anchors.fill: parent
            TitleText {
                text: copyLogsFinishedPopup.succeeded ?
                            "FINISHED COPYING LOGS TO USB" :
                            "FAILED TO COPY LOGS TO USB"
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
                        indicator: Rectangle {
                                implicitWidth: 26
                                implicitHeight: 26
                                x: clearCalibrationSettings.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 3
                                border.color: clearCalibrationSettings.down ? otherBlue : lightBlue

                                Rectangle {
                                    width: 14
                                    height: 14
                                    x: 6
                                    y: 6
                                    radius: 2
                                    color: clearCalibrationSettings.down ? otherBlue : lightBlue
                                    visible: clearCalibrationSettings.checked
                                }
                            }
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

                        contentItem: Item {
                                implicitWidth: 64
                                implicitHeight: 64

                                Item {
                                    id: item
                                    x: parent.width / 2 - 32
                                    y: parent.height / 2 - 32
                                    width: 64
                                    height: 64
                                    opacity: busyIndicator.running ? 1 : 0

                                    Behavior on opacity {
                                        OpacityAnimator {
                                            duration: 250
                                        }
                                    }

                                    RotationAnimator {
                                        target: item
                                        running: busyIndicator.visible && busyIndicator.running
                                        from: 0
                                        to: 360
                                        loops: Animation.Infinite
                                        duration: 1500
                                    }

                                    Repeater {
                                        id: repeater
                                        model: 6

                                        Rectangle {
                                            x: item.width / 2 - width / 2
                                            y: item.height / 2 - height / 2
                                            implicitWidth: 2
                                            implicitHeight: 16
                                            radius: 0
                                            color: "#ffffff"
                                            transform: [
                                                Translate {
                                                    y: -Math.min(item.width, item.height) * 0.5 + 5
                                                },
                                                Rotation {
                                                    angle: index / repeater.count * 360
                                                    origin.x: 1
                                                    origin.y: 8
                                                }
                                            ]
                                        }
                                    }
                                }
                            }


                    }
                }
            }
        }
    }
}
