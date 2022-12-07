import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import FreStepEnum 1.0
import ExtruderTypeEnum 1.0
import MachineTypeEnum 1.0

Item {
    id: materialPage
    anchors.fill: parent
    smooth: false
    property alias bay1: bay1
    property alias bay2: bay2
    property alias materialSwipeView: materialSwipeView
    property alias loadMaterialSettingsPage: loadMaterialSettingsPage
    property alias loadUnloadFilamentProcess: loadUnloadFilamentProcess

    property alias cancelLoadUnloadPopup: cancelLoadUnloadPopup
    property alias cancel_mouseArea: cancel_mouseArea
    property alias cancel_rectangle: cancel_rectangle
    property alias continue_mouseArea: continue_mouseArea
    property alias continue_rectangle: continue_rectangle

    property alias materialWarningPopup: materialWarningPopup
    property alias ok_unk_mat_loading_mouseArea: ok_mat_warning_mouseArea

    property alias materialPageDrawer: materialPageDrawer
    property bool isLoadFilament: false
    property int toolIdx: 0
    property bool startLoadUnloadFromUI: false
    property bool isLoadUnloadProcess: bot.process.type == ProcessType.Load ||
                                       bot.process.type == ProcessType.Unload ||
                                       bot.process.isLoadUnloadWhilePaused
    property alias waitUntilUnloadedPopup: waitUntilUnloadedPopup
    property alias closeWaitUntilUnloadedPopup: closeWaitUntilUnloadedPopup
    property bool isTopLoading: bot.topLoadingWarning
    property bool isSpoolValidityCheckPending: bot.spoolValidityCheckPending
    property bool isMaterialMismatch: false

    property alias moistureWarningPopup: moistureWarningPopup

    property alias uncapped1CExtruderAlert: uncapped1CExtruderAlert
    property bool restartPendingAfterExtruderReprogram: false

    onIsLoadUnloadProcessChanged: {
        if(isLoadUnloadProcess &&
           !startLoadUnloadFromUI &&
           // Error 1041 OOF at extruder was triggering
           // the UI to move to material page for some
           // reason, quick hack to fix this.
           (bot.process.errorCode != 1041)) {
            if(mainSwipeView.currentIndex != MoreporkUI.MaterialPage){
                mainSwipeView.swipeToItem(MoreporkUI.MaterialPage)
            }
            enableMaterialDrawer()
            if(materialSwipeView.currentIndex != MaterialPage.LoadUnloadPage){
                materialSwipeView.swipeToItem(MaterialPage.LoadUnloadPage)
            }
            switch(bot.process.type) {
            case ProcessType.Load:
                isLoadFilament = true
                break;
            case ProcessType.Unload:
                isLoadFilament = false
                break;
            case ProcessType.Print:
                isLoadFilament = bot.process.isLoad
                break;
            }
        }
        else {
            startLoadUnloadFromUI = false
            materialWarningPopup.close()
            cancelLoadUnloadPopup.close()
        }
    }

    // There is a weird race condition when resetting the bool
    // (bot.topLoadingWarning) immediately after it is set,
    // where the bool is actually reset but the qml side property
    // pointing to the bool(isTopLoading) doesn't reflect it and
    // understandably no changed() signal (qml side) is emitted
    // either. This delay seems to eliminate this race condition(?)
    // and with this the qml side property reflects the change
    // correctly. Not happy that I spent two days tracking this down.

    // C++ property --changes--> qml property changes --> on qml property
    // change, call a function that changes the c++ property --> c++ property
    // is changed by function --> qml property does not change.
    Timer {
        id: respondTopLoadingWarning
        interval: 100
        onTriggered: {
            bot.acknowledgeMaterial(true)
        }
    }

    onIsTopLoadingChanged: {
        if(isTopLoading) {
            if(isUsingExpExtruder(loadUnloadFilamentProcess.bayID) ||
                    !bot.hasFilamentBay) {
                respondTopLoadingWarning.start()
            } else {
                if(cancelLoadUnloadPopup.opened) {
                    cancelLoadUnloadPopup.close()
                }
                materialWarningPopup.open()
            }
        }
        else {
            materialWarningPopup.close()
        }
    }

    onIsSpoolValidityCheckPendingChanged: {
        if(isSpoolValidityCheckPending) {
            if(cancelLoadUnloadPopup.opened) {
                cancelLoadUnloadPopup.close()
            }
            checkSpoolValidityTimer.start()
        }
        else {
            materialWarningPopup.close()
        }
    }

    Timer {
        id: checkSpoolValidityTimer
        interval: 100
        onTriggered: {
            checkSpoolValidity()
        }
    }

    function checkSpoolValidity() {
        // The case when the bot is already loaded and
        // we get spool check notification from kaiten.
        if(bot.process.type == ProcessType.Load) {
            // if material is valid immediately acknowledge and
            // continue with loading material
            if(loadUnloadFilamentProcess.materialValidityCheck()) {
                bot.acknowledgeMaterial(true)
                if(materialWarningPopup.opened) {
                    materialWarningPopup.close()
                }
            }
            // if material not valid open popup
            else {
                materialWarningPopup.open()
            }
        }
    }

    onIsMaterialMismatchChanged: {
        if(cancelLoadUnloadPopup.opened) {
            cancelLoadUnloadPopup.close()
        }
        if(isMaterialMismatch && bot.process.type == ProcessType.Load) {
            materialWarningPopup.open()
        }
    }

    function exitMaterialChange() {
        if(bot.process.type == ProcessType.Load) {
            cancelLoadUnloadPopup.open()
        }
        else if(bot.process.type == ProcessType.Unload) {
            if(bot.process.isProcessCancellable) {
                cancelLoadUnloadPopup.open()
            }
            else {
                waitUntilUnloadedPopup.open()
                closeWaitUntilUnloadedPopup.start()
            }
        }
        else if(printPage.isPrintProcess) {
            // If load/unload completed successfully and the user wants
            // to go back don't show any popup, just reset the page state
            // and go back.
            if(bot.process.stateType == ProcessStateType.Paused) {
                loadUnloadFilamentProcess.state = "base state"
                materialSwipeView.swipeToItem(MaterialPage.BasePage)
                // If cancelled out of load/unload while in print process
                // enable print drawer to set UI back to printing state.
                setDrawerState(false)
                activeDrawer = printPage.printingDrawer
                setDrawerState(true)
            }
            else {
                cancelLoadUnloadPopup.open()
            }
        }
        // If load/unload completed successfully and the user wants
        // to go back don't show any popup, just reset the page state
        // and go back.
        else if(bot.process.type == ProcessType.None) {
            loadUnloadFilamentProcess.state = "base state"
            loadUnloadFilamentProcess.isExternalLoadUnload = false
            materialSwipeView.swipeToItem(MaterialPage.BasePage)
            setDrawerState(false)
        }
    }

    MaterialPageDrawer {
        id: materialPageDrawer
    }

    enum SwipeIndex {
        BasePage,
        LoadMaterialSettingsPage,
        LoadUnloadPage
    }

    LoggingSwipeView {
        id: materialSwipeView
        logName: "materialSwipeView"
        currentIndex: MaterialPage.BasePage

        // MaterialPage.BasePage
        Item {
            id: itemFilamentBay
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: mainSwipeView
            property int backSwipeIndex: MoreporkUI.BasePage
            smooth: false

            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 43
                    FilamentBay {
                        id: bay1
                        visible: true
                        filamentBayID: 1
                    }
                    FilamentBay {
                        id: bay2
                        visible: true
                        filamentBayID: 2
                    }
            }
        }

        // MaterialPage.LoadMaterialSettingsPage
        Item {
            id: itemSelectMaterial
            property var backSwiper: materialSwipeView
            property int backSwipeIndex: MaterialPage.BasePage
            visible: false

            LoadMaterialSettings {
                id: loadMaterialSettingsPage
            }
        }

        // MaterialPage.LoadUnloadPage
        Item {
            id: itemLoadUnloadFilament
            property var backSwiper: materialSwipeView
            property int backSwipeIndex: MaterialPage.BasePage
            property bool hasAltBack: true
            visible: false

            function altBack() {
                if(!inFreStep) {
                    exitMaterialChange()
                }
                else {
                    if(bot.process.type == ProcessType.Load ||
                       bot.process.type == ProcessType.Unload ||
                       bot.process.type == ProcessType.None) {
                        skipFreStepPopup.open()
                    }
                    else {
                        if(bot.process.type == ProcessType.Print) {
                            cancelLoadUnloadPopup.open()
                        }
                    }
                }
            }

            function skipFreStepAction() {
                materialChangeCancelled = true
                bot.cancel()
                loadUnloadFilamentProcess.state = "base state"
                materialSwipeView.swipeToItem(MaterialPage.BasePage)
                setDrawerState(false)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
            }

            LoadUnloadFilament {
                id: loadUnloadFilamentProcess
                bayFilamentSwitch: bayID == 1 ?
                                    bot.filamentBayAFilamentPresent :
                                    bot.filamentBayBFilamentPresent

                // Check if user feeds filament into bay slot while
                // kaiten is waiting for 'acknowledge_material' process
                // method to proceed and display material warning popup
                // in that case.
                onBayFilamentSwitchChanged: {
                    if(bot.process.type == ProcessType.Load &&
                       bayFilamentSwitch &&
                       isSpoolValidityCheckPending &&
                       !isMaterialMismatch) {
                        materialWarningPopup.open()
                    }
                }

                extruderFilamentSwitch: bayID == 1 ?
                                    bot.extruderAFilamentPresent :
                                    bot.extruderBFilamentPresent
                onProcessDone: {
                    state = "base state"
                    isExternalLoadUnload = false
                    materialSwipeView.swipeToItem(MaterialPage.BasePage)
                    setDrawerState(false)
                    // If load/unload process completes successfully while,
                    // in print process enable print drawer to set UI back,
                    // to printing state.
                    if(printPage.isPrintProcess) {
                        activeDrawer = printPage.printingDrawer
                        setDrawerState(true)
                        // Go to print page directly after loading
                        // but if unloading stay on material page
                        if(isLoadFilament) {
                            mainSwipeView.swipeToItem(MoreporkUI.PrintPage)

                        }
                    }
                }
            }
        }
    }

    LoggingPopup {
        popupName: "MaterialWarning"
        id: materialWarningPopup
        width: 800
        height: 480
        modal: true
        dim: false
        focus: true
        parent: overlay
        closePolicy: Popup.CloseOnPressOutside
        background: Rectangle {
            id: popupBackgroundDim_mat_warning_popup
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
            isMaterialMismatch = false
        }

        Rectangle {
            id: basePopupItem_mat_warning_popup
            color: "#000000"
            rotation: rootItem.rotation == 180 ? 180 : 0
            width: 720
            height: isMaterialMismatch ? 250 : 280
            radius: 10
            border.width: 2
            border.color: "#ffffff"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                id: horizontal_divider_mat_warning_popup
                width: 720
                height: 2
                color: "#ffffff"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 72
                visible: !isMaterialMismatch
            }

            Rectangle {
                id: vertical_divider_mat_warning_popup
                x: 359
                y: 328
                width: 2
                height: 72
                color: "#ffffff"
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.horizontalCenter: parent.horizontalCenter
                visible: false
            }

            Item {
                id: buttonBar_mat_warning_popup
                width: 720
                height: 72
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                visible: !isMaterialMismatch

                Rectangle {
                    id: ok_rectangle_mat_warning_popup
                    x: 0
                    y: 0
                    width: 720
                    height: 72
                    color: "#00000000"
                    radius: 10

                    Text {
                        id: ok_text_mat_warning_popup
                        color: "#ffffff"
                        text: qsTr("OK")
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: false
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: defaultFont.name
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    LoggingMouseArea {
                        logText: "material_warning_popup: [OK]"
                        id: ok_mat_warning_mouseArea
                        anchors.fill: parent
                        onPressed: {
                            ok_text_mat_warning_popup.color = "#000000"
                            ok_rectangle_mat_warning_popup.color = "#ffffff"
                        }
                        onReleased: {
                            ok_text_mat_warning_popup.color = "#ffffff"
                            ok_rectangle_mat_warning_popup.color = "#00000000"
                        }
                    }
                }
            }

            ColumnLayout {
                id: columnLayout_mat_warning_popup
                width: 680
                height: isMaterialMismatch ? 135 : 150
                anchors.top: parent.top
                anchors.topMargin: isMaterialMismatch ? 60 : 35
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: title_text_mat_warning_popup
                    color: "#cbcbcb"
                    text: {
                        if(isMaterialMismatch) {
                            if (loadUnloadFilamentProcess.currentActiveTool == 1) {
                                if (bot.machineType != MachineType.Fire &&
                                        (materialPage.bay1.filamentMaterial == "abs" ||
                                         materialPage.bay1.filamentMaterial == "asa")) {
                                    qsTr("UNSUPPORTED MATERIAL DETECTED")
                                } else {
                                    qsTr("MODEL MATERIAL REQUIRED")
                                }
                            } else if (loadUnloadFilamentProcess.currentActiveTool == 2) {
                                qsTr("SUPPORT MATERIAL REQUIRED")
                            }
                        } else {
                            qsTr("MATERIAL NOT SUPPORTED")
                        }
                    }
                    font.letterSpacing: 3
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: defaultFont.name
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Text {
                    id: description_text_mat_warning_popup
                    color: "#cbcbcb"
                    text: {
                        if(isMaterialMismatch) {
                            if(loadUnloadFilamentProcess.currentActiveTool == 1) {
                                switch (bot.extruderAType) {
                                case ExtruderType.MK14:
                                    // This is a special case when V1 extruder is being used on
                                    // a V2 printer and the user tries to load a V2 hot extruder
                                    // specific material. This warning can be made generic for
                                    // all such materials.
                                    if (bot.machineType != MachineType.Fire &&
                                        (materialPage.bay1.filamentMaterial == "abs" ||
                                         materialPage.bay1.filamentMaterial == "asa")) {
                                        qsTr("Only PLA, Tough and PETG model material are compatible with a Model 1A Extruder. Insert a Model 1XA Extruder to print ABS or ASA.")
                                    } else {
                                        qsTr("Only PLA, Tough and PETG model material are compatible in material bay 1. Insert MakerBot model material in material bay 1 to continue.")
                                    }
                                    break;
                                case ExtruderType.MK14_HOT:
                                    qsTr("Only ABS and ASA model material are compatible in material bay 1. Insert MakerBot model material in material bay 1 to continue.")
                                    break;
                                case ExtruderType.MK14_COMP:
                                    qsTr("Only %1 model materials are compatible in material bay 1. Insert MakerBot model material in material bay 1 to continue.").arg(materialPage.bay1.supportedMaterials.map(bot.getMaterialName).join(", "))
                                    break;
                                default:
                                    defaultString
                                    break;
                                }
                            } else if(loadUnloadFilamentProcess.currentActiveTool == 2) {
                                switch (bot.extruderBType) {
                                case ExtruderType.MK14:
                                    qsTr("Only PVA support material is compatible in material bay 2. Insert PVA support material in material bay 2 to continue.")
                                    break;
                                case ExtruderType.MK14_HOT:
                                    qsTr("Only SR-30 support material is compatible in material bay 2. Insert MakerBot SR-30 support material in material bay 2 to continue.")
                                    break;
                                default:
                                    defaultString
                                    break;
                                }
                            }
                        } else {
                            if(loadUnloadFilamentProcess.currentActiveTool == 1) {
                                qsTr("The Performance Model extruder is only compatible with\n" +
                                "MakerBot Method materials. To use 3rd Party Materials, please\n" +
                                "use a MakerBot Labs Extruder. Learn more at Makerbot.com/Labs")
                            } else if(loadUnloadFilamentProcess.currentActiveTool == 2) {
                                qsTr("The Performance Support extruder is only compatible with\n" +
                                "MakerBot Method support materials.")
                            }
                            else {
                                defaultString
                            }
                        }
                    }
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.weight: Font.Light
                    wrapMode: Text.WordWrap
                    font.family: defaultFont.name
                    font.pixelSize: 20
                    lineHeight: 1.4
                }
            }
        }
    }

    LoggingPopup {
        popupName: "CancelLoadUnload"
        id: cancelLoadUnloadPopup
        width: 800
        height: 480
        modal: true
        dim: false
        focus: true
        parent: overlay
        closePolicy: Popup.CloseOnPressOutside
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

        Rectangle {
            id: basePopupItem
            color: "#000000"
            rotation: rootItem.rotation == 180 ? 180 : 0
            width: 720
            height: 220
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
            }

            Item {
                id: buttonBar
                width: 720
                height: 72
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                Rectangle {
                    id: cancel_rectangle
                    x: 0
                    y: 0
                    width: 360
                    height: 72
                    color: "#00000000"
                    radius: 10

                    Text {
                        id: cancel_loading_text
                        color: "#ffffff"
                        text: isLoadFilament ? qsTr("CANCEL LOADING") : qsTr("CANCEL UNLOADING")
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: false
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: defaultFont.name
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    LoggingMouseArea {
                        logText: "[_" + cancel_loading_text.text + "|]"
                        id: cancel_mouseArea
                        anchors.fill: parent
                        onPressed: {
                            cancel_loading_text.color = "#000000"
                            cancel_rectangle.color = "#ffffff"
                        }
                        onReleased: {
                            cancel_loading_text.color = "#ffffff"
                            cancel_rectangle.color = "#00000000"
                        }
                    }
                }

                Rectangle {
                    id: continue_rectangle
                    x: 360
                    y: 0
                    width: 360
                    height: 72
                    color: "#00000000"
                    radius: 10

                    Text {
                        id: continue_loading_text
                        color: "#ffffff"
                        text: isLoadFilament ? qsTr("CONTINUE LOADING") : qsTr("CONTINUE UNLOADING")
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: defaultFont.name
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    LoggingMouseArea {
                        logText: "[|" + continue_loading_text.text + "_]"
                        id: continue_mouseArea
                        anchors.fill: parent
                        onPressed: {
                            continue_loading_text.color = "#000000"
                            continue_rectangle.color = "#ffffff"
                        }
                        onReleased: {
                            continue_loading_text.color = "#ffffff"
                            continue_rectangle.color = "#00000000"
                        }
                    }
                }
            }

            ColumnLayout {
                id: columnLayout
                width: 590
                height: 100
                anchors.top: parent.top
                anchors.topMargin: 25
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: cancel_text
                    color: "#cbcbcb"
                    text: isLoadFilament ? qsTr("CANCEL MATERIAL LOADING?") :
                                           qsTr("CANCEL MATERIAL UNLOADING?")
                    font.letterSpacing: 3
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: defaultFont.name
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Text {
                    id: cancel_description_text
                    color: "#cbcbcb"
                    text: qsTr("Are you sure you want to cancel the material %1 process?").arg(
                                    isLoadFilament ? qsTr("loading") : qsTr("unloading"))
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.weight: Font.Light
                    wrapMode: Text.WordWrap
                    font.family: defaultFont.name
                    font.pixelSize: 18
                    lineHeight: 1.3
                }
            }
        }
    }

    Timer {
        id: closeWaitUntilUnloadedPopup
        interval: 3000
        onTriggered: {
            waitUntilUnloadedPopup.close()
        }
    }

    LoggingPopup {
        popupName: "WaitUntilUnloaded"
        id: waitUntilUnloadedPopup
        width: 800
        height: 480
        modal: true
        dim: false
        focus: true
        parent: overlay
        closePolicy: Popup.CloseOnPressOutside
        background: Rectangle {
            id: popupBackgroundDim1
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

        Rectangle {
            id: basePopupItem1
            color: "#000000"
            rotation: rootItem.rotation == 180 ? 180 : 0
            width: 720
            height: 100
            radius: 10
            border.width: 2
            border.color: "#ffffff"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: popup_content_text
                color: "#cbcbcb"
                text: qsTr("Please wait until the unloading process completes.")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                font.family: defaultFont.name
                font.pixelSize: 18
                lineHeight: 1.3
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    CustomPopup {
        popupName: "MoistureSensitiveMaterialAlert"
        id: moistureWarningPopup
        popupWidth: 720
        popupHeight: 320
        showOneButton: true
        full_button_text: qsTr("OK")
        full_button.onClicked: {
            moistureWarningPopup.close()
        }

        ColumnLayout {
            id: columnLayout_moisture_warning_popup
            width: 590
            height: children.height
            spacing: 20
            anchors.top: parent.top
            anchors.topMargin: 115
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: alert_text_moisture_warning_popup
                color: "#cbcbcb"
                text: qsTr("MOISTURE SENSITIVE MATERIAL DETECTED")
                font.letterSpacing: 3
                Layout.alignment: Qt.AlignHCenter
                font.family: defaultFont.name
                font.weight: Font.Bold
                font.pixelSize: 20
            }

            Text {
                id: description_text_moisture_warning_popup
                color: "#cbcbcb"
                text: {
                    qsTr("The detected material is prone to absorbing moisture " +
                         "from the air. Always keep the material sealed in the " +
                         "material bay, an air tight bag or case. If exposed for " +
                         "more than 15 minutes, you can use the material drying " +
                         "feature located in advanced settings on this printer.")
                }
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
                font.weight: Font.Light
                wrapMode: Text.WordWrap
                font.family: defaultFont.name
                font.pixelSize: 18
                font.letterSpacing: 1
                lineHeight: 1.3
            }
        }
    }

    CustomPopup {
        property bool extruderAPresent: bot.extruderAPresent

        popupName: "Uncapped1CExtruderAlert"
        id: uncapped1CExtruderAlert
        popupWidth: 750
        popupHeight: {
            if(popupState == "reprogrammed" || popupState == "restart_pending") {
                300
            } else {
                400
            }
        }
        property string popupState: "base state"
        showTwoButtons: true
        left_button_text: {
            if(popupState == "base state" || popupState == "reprogrammed") {
                qsTr("BACK")
            }
        }
        left_button.onClicked: {
            uncapped1CExtruderAlert.close()
            if(popupState == "reprogrammed") {
                restartPendingAfterExtruderReprogram = true
            }
        }

        right_button_text: {
            if(popupState == "base state") {
                qsTr("CONFIRM")
            } else if(popupState == "reprogrammed" || popupState == "restart_pending") {
                qsTr("RESTART NOW")
            }
        }

        right_button.onClicked: {
            if(popupState == "base state") {
                // 0x00050002 = 327682 (mk14c, subtype 2)
                bot.writeExtruderEeprom(0, 1, 327682)
                popupState = "reprogrammed"
            } else if(popupState == "reprogrammed" || popupState == "restart_pending") {
                bot.reboot()
            }
        }

        onExtruderAPresentChanged: {
            // Upon removal of the 1C extruder...
            if(!extruderAPresent) {
                // equivalent to activating the above "BACK" button
                uncapped1CExtruderAlert.close()
            }
        }

        onClosed: {
            popupState = "base state"
        }

        ColumnLayout {
            id: columnLayout_uncapped_1c_extruder_popup
            width: 650
            height: 320
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0

            Image {
                id: error_image
                width: sourceSize.width - 10
                height: sourceSize.height -10
                source: "qrc:/img/extruder_material_error.png"
                Layout.alignment: Qt.AlignHCenter
            }

            TextHeadline {
                id: title
                text: qsTr("NOZZLE CAP INSTALLED?")
                Layout.alignment: Qt.AlignHCenter
            }

            TextBody {
                id: description
                text: qsTr("<b>1C Extruder</b> requires a nozzle cap for " +
                           "<b>ABS-R</b>. Have you installed the nozzle cap?" +
                           "<br><br>\"CONFIRM\" will reprogram the extruder. " +
                           "You will need to restart the printer afterwards." +
                           "<br><br>Please call our Customer Support team to " +
                           "have a cap shipped for you to upgrade.")
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
            }

            states: [
                State {
                    name: "reprogrammed"
                    when: uncapped1CExtruderAlert.popupState == "reprogrammed"

                    PropertyChanges {
                        target: error_image
                        source: "qrc:/img/process_complete_small.png"
                    }

                    PropertyChanges {
                        target: title
                        text: qsTr("REPROGRAMMED SUCCESSFULLY")
                    }

                    PropertyChanges {
                        target: description
                        text: qsTr("You will need to restart the printer before using this extruder.")
                    }

                    PropertyChanges {
                        target: columnLayout_uncapped_1c_extruder_popup
                        height: 200
                        anchors.topMargin: 80
                    }
                },
                State {
                    name: "restart_pending"
                    when: uncapped1CExtruderAlert.popupState == "restart_pending"

                    PropertyChanges {
                        target: error_image
                        source: "qrc:/img/extruder_material_error.png"
                    }

                    PropertyChanges {
                        target: title
                        text: qsTr("RESTART REQUIRED")
                    }

                    PropertyChanges {
                        target: description
                        text: qsTr("You will need to restart the printer before using this extruder.")
                    }

                    PropertyChanges {
                        target: columnLayout_uncapped_1c_extruder_popup
                        height: 200
                        anchors.topMargin: 80
                    }
                }
            ]
        }
    }
}
