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
    smooth: false
    property alias bay1: bay1
    property alias bay2: bay2
    property alias defaultItem: itemFilamentBay
    property alias materialSwipeView: materialSwipeView
    property alias expExtruderSettingsPage: expExtruderSettingsPage
    property alias loadUnloadFilamentProcess: loadUnloadFilamentProcess

    property alias cancelLoadUnloadPopup: cancelLoadUnloadPopup
    property alias cancel_mouseArea: cancel_mouseArea
    property alias cancel_rectangle: cancel_rectangle
    property alias continue_mouseArea: continue_mouseArea
    property alias continue_rectangle: continue_rectangle

    property alias noExtruderPopup: noExtruderPopup
    property int extruderIDnoExtruderPopup
    property alias attach_extruder_mouseArea_no_extruder_popup: attach_extruder_mouseArea_no_extruder_popup
    property alias cancel_mouseArea_no_extruder_popup: cancel_mouseArea_no_extruder_popup

    property alias materialWarningPopup: materialWarningPopup
    property alias ok_unk_mat_loading_mouseArea: ok_mat_warning_mouseArea

    property alias materialPageDrawer: materialPageDrawer
    property bool isLoadFilament: false
    property bool startLoadUnloadFromUI: false
    property bool isLoadUnloadProcess: bot.process.type == ProcessType.Load ||
                                       bot.process.type == ProcessType.Unload ||
                                       bot.process.isLoadUnloadWhilePaused
    property alias waitUntilUnloadedPopup: waitUntilUnloadedPopup
    property alias closeWaitUntilUnloadedPopup: closeWaitUntilUnloadedPopup
    property bool isTopLoading: bot.topLoadingWarning
    property bool isSpoolValidityCheckPending: bot.spoolValidityCheckPending
    property bool isMaterialMismatch: false

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
        id: respondExpExtruderTopLoading
        interval: 100
        onTriggered: {
            bot.acknowledgeMaterial(true)
        }
    }

    onIsTopLoadingChanged: {
        if(isTopLoading) {
            if(loadUnloadFilamentProcess.bayID == 1 &&
               bay1.usingExperimentalExtruder) {
                respondExpExtruderTopLoading.start()
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

    enum PageIndex {
        BasePage,
        ExpExtruderSettingsPage,
        LoadUnloadPage
    }

    SwipeView {
        id: materialSwipeView
        currentIndex: MaterialPage.BasePage
        smooth: false
        anchors.fill: parent
        interactive: false

        function swipeToItem(itemToDisplayDefaultIndex) {
            var prevIndex = materialSwipeView.currentIndex
            materialSwipeView.itemAt(itemToDisplayDefaultIndex).visible = true
            setCurrentItem(materialSwipeView.itemAt(itemToDisplayDefaultIndex))
            materialSwipeView.setCurrentIndex(itemToDisplayDefaultIndex)
            materialSwipeView.itemAt(prevIndex).visible = false
        }

        // MaterialPage.BasePage
        Item {
            id: itemFilamentBay
            // backSwiper and backSwipeIndex are used by backClicked
            property var backSwiper: mainSwipeView
            property int backSwipeIndex: MoreporkUI.BasePage
            smooth: false
            visible: true

            FilamentBay {
                id: bay1
                visible: true
                anchors.top: parent.top
                anchors.topMargin: 25
                filamentBayID: 1
            }

            FilamentBay {
                id: bay2
                visible: true
                anchors.top: parent.top
                anchors.topMargin: 225
                filamentBayID: 2
            }
        }

        // MaterialPage.ExpExtruderSettingsPage
        Item {
            id: itemExpExtruderSettings
            property var backSwiper: materialSwipeView
            property int backSwipeIndex: MaterialPage.BasePage
            visible: false

            ExpExtruderSettings {
                id: expExtruderSettingsPage
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
                        // Go to print page directly after loading or
                        // unloading during a print.
                        mainSwipeView.swipeToItem(MoreporkUI.PrintPage)
                    }
                }
            }
        }
    }

    Popup {
        id: noExtruderPopup
        width: 800
        height: 480
        modal: true
        dim: false
        focus: true
        parent: overlay
        closePolicy: Popup.CloseOnPressOutside
        background: Rectangle {
            id: popupBackgroundDim_no_extruder_popup
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
            id: basePopupItem_no_extruder_popup
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
                id: horizontal_divider_no_extruder_popup
                width: 720
                height: 2
                color: "#ffffff"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 72
            }

            Rectangle {
                id: vertical_divider_no_extruder_popup
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
                id: buttonBar_no_extruder_popup
                width: 720
                height: 72
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0

                Rectangle {
                    id: cancel_rectangle_no_extruder_popup
                    x: 0
                    y: 0
                    width: 360
                    height: 72
                    color: "#00000000"
                    radius: 10

                    Text {
                        id: cancel_text_no_extruder_popup
                        color: "#ffffff"
                        text: qsTr("CANCEL")
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

                    MouseArea {
                        id: cancel_mouseArea_no_extruder_popup
                        anchors.fill: parent
                        onPressed: {
                            cancel_text_no_extruder_popup.color = "#000000"
                            cancel_rectangle_no_extruder_popup.color = "#ffffff"
                        }
                        onReleased: {
                            cancel_text_no_extruder_popup.color = "#ffffff"
                            cancel_rectangle_no_extruder_popup.color = "#00000000"
                        }
                    }
                }

                Rectangle {
                    id: attach_extruder_rectangle_no_extruder_popup
                    x: 360
                    y: 0
                    width: 360
                    height: 72
                    color: "#00000000"
                    radius: 10

                    Text {
                        id: attach_extruder_text_no_extruder_popup
                        color: "#ffffff"
                        text: qsTr("ATTACH EXTRUDER")
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: defaultFont.name
                        font.pixelSize: 18
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MouseArea {
                        id: attach_extruder_mouseArea_no_extruder_popup
                        anchors.fill: parent
                        onPressed: {
                            attach_extruder_text_no_extruder_popup.color = "#000000"
                            attach_extruder_rectangle_no_extruder_popup.color = "#ffffff"
                        }
                        onReleased: {
                            attach_extruder_text_no_extruder_popup.color = "#ffffff"
                            attach_extruder_rectangle_no_extruder_popup.color = "#00000000"
                        }
                    }
                }
            }

            ColumnLayout {
                id: columnLayout_no_extruder_popup
                width: 590
                height: 100
                anchors.top: parent.top
                anchors.topMargin: 25
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: title_text_no_extruder_popup
                    color: "#cbcbcb"
                    text: qsTr("NO EXTRUDER DETECTED")
                    font.letterSpacing: 3
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: defaultFont.name
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Text {
                    id: description_text_no_extruder_popup
                    color: "#cbcbcb"
                    text: {
                        qsTr("Please attach a %1 Performance extruder into slot %2").arg(
                            extruderIDnoExtruderPopup == 1 ? qsTr("Model 1") : qsTr("Support 2")).arg(
                            extruderIDnoExtruderPopup == 1 ? qsTr("one") : qsTr("two"))
                    }
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

    Popup {
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

                    MouseArea {
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
                                if (bot.machineType == MachineType.Lava &&
                                        (materialPage.bay1.filamentMaterialName == "ABS" ||
                                         materialPage.bay1.filamentMaterialName == "ASA")) {
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
                                    if (bot.machineType == MachineType.Lava &&
                                        (materialPage.bay1.filamentMaterialName == "ABS" ||
                                         materialPage.bay1.filamentMaterialName == "ASA")) {
                                        qsTr("Only PLA, Tough and PETG model material are compatible with a Model 1A Extruder. Insert a Model 1XA Extruder to print ABS or ASA.")
                                    } else {
                                        qsTr("Only PLA, Tough and PETG model material are compatible in material bay 1. Insert MakerBot model material in material bay 1 to continue.")
                                    }
                                    break;
                                case ExtruderType.MK14_HOT:
                                    qsTr("Only ABS and ASA model material are compatible in material bay 1. Insert MakerBot model material in material bay 1 to continue.")
                                    break;
                                case ExtruderType.MK14_COMP:
                                    qsTr("Only %1 model materials are compatible in material bay 1. Insert MakerBot model material in material bay 1 to continue.").arg(materialPage.bay1.goodMaterialsList.join(", "))
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

    Popup {
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

                    MouseArea {
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

                    MouseArea {
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

    Popup {
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
}
