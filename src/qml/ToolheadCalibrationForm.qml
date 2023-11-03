import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import ErrorTypeEnum 1.0
import ExtruderTypeEnum 1.0
import MachineTypeEnum 1.0

LoggingItem {
    itemName: "ToolheadCalibration"
    id: calibrationPage
    width: 800
    height: 408
    property alias contentLeftSide: contentLeftSide
    property alias contentRightSide: contentRightSide
    property alias cleanExtrudersSequence: cleanExtrudersSequence
    property alias cancelCalibrationPopup: cancelCalibrationPopup
    property alias resumeManualCalibrationPopup: resumeManualCalibrationPopup
    signal processDone
    property string ax
    property string ay
    property string az
    property string bx
    property string by
    property string bz

    property int currentState: bot.process.stateType
    onCurrentStateChanged: {
        if(bot.process.type == ProcessType.CalibrationProcess) {
            switch(currentState) {
            case ProcessStateType.Cancelling:
                state = "cancelling"
                break;
            case ProcessStateType.CleaningUp:
               if (!bot.process.cancelled) {
                   getHotCalValues.start()
                   state = "calibration_finished"
               }
               break;
            case ProcessStateType.ColdCalDone:
                state = "cold_cal_done"
                bot.get_calibration_offsets()
                getColdCalValues.start()
                break;
            default:
                break;
            }
        }
        else if(bot.process.type == ProcessType.None) {
            if(state == "cancelling") {
                if(inFreStep) {
                    state = "base state"
                }
                processDone()
            }
        }
    }

    Timer {
        id: getColdCalValues
        interval: 2000
        onTriggered: {
            console.log("Get cold cal values")
            ax = bot.offsetAX.toFixed(10)
            ay = bot.offsetAY.toFixed(10)
            az = bot.offsetAZ.toFixed(10)
            bx = bot.offsetBX.toFixed(10)
            by = bot.offsetBY.toFixed(10)
            bz = bot.offsetBZ.toFixed(10)
        }
    }

    Timer {
        id: getHotCalValues
        interval: 2000
        onTriggered: {
            console.log("Get hot cal values")
            bot.get_calibration_offsets()
        }
    }

    property bool chooseMaterial: false

    ContentLeftSide {
        id: contentLeftSide
        image {
            source: "qrc:/img/calibrate_extruders.png"
            visible: true
        }
        loadingIcon {
            visible: false
        }
        visible: true
    }

    ContentRightSide {
        id: contentRightSide
        textHeader {
            text: qsTr("AUTOMATIC CALIBRATION")
            visible: true
        }
        textBody {
            text: qsTr("This is the simplest calibration that should be run " +
                       "anytime an extruder is attached to the printer.")
            visible: true
        }
        buttonPrimary {
            text: qsTr("START")
            visible: true
        }
        visible: true
    }

    CleanExtrudersSequence {
        id: cleanExtrudersSequence
        anchors.verticalCenter: parent.verticalCenter
        visible: false
        enabled: bot.process.type == ProcessType.CalibrationProcess
    }

    CleanExtruderSettings {
        id: materialSelector
        visible: false
    }

    Item {
        id: result
        visible: false
        anchors.fill: parent

        Rectangle {
            color: "#000000"
            anchors.fill: parent
        }

        ColumnLayout {
            id: heatingStatus
            visible: bot.extruderATargetTemp > 0 ||
                     bot.extruderBTargetTemp > 0 ||
                     bot.chamberTargetTemp > 0 ||
                     bot.buildplaneTargetTemp > 0 ||
                     bot.hbpTargetTemp > 0

            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            scale: 0.9
            spacing: 10

            TextHeadline {
                text: "HEATING"
            }

            TemperatureStatus {
                showComponent: TemperatureStatus.BothExtruders
            }

            RowLayout {
                spacing: 20
                TemperatureStatus {
                    showComponent: TemperatureStatus.Chamber
                }

                TemperatureStatus {
                    showComponent: TemperatureStatus.ChamberBuildPlane
                    component1.componentName: "CHAMBER BP"
                    visible:  bot.machineType != MachineType.Magma
                }
            }

            TemperatureStatus {
                showComponent: TemperatureStatus.HeatedBuildPlate
                visible: bot.machineType == MachineType.Magma
            }
        }

        TextHeadline {
            id: titleLayout
            text: {
                if(bot.process.stateType == ProcessStateType.ColdCalDone) {
                    "COLD CALIBRATION FINISHED"
                } else {
                    "COLD & HOT CALIBRATION FINISHED"
                }
            }
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.horizontalCenterOffset: 1
            anchors.topMargin: 10
            visible: !heatingStatus.visible
        }

        ColumnLayout {
            visible: !heatingStatus.visible
            id: calibrationOffsets
            spacing: -88
            width: 800
            height: 200
            scale: 0.70
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -89
            anchors.horizontalCenterOffset: -122
            anchors.horizontalCenter: parent.horizontalCenter
            AdvancedInfoCalibrationItem {
                heading.text: "COLD CALIBRATION"
                toolheadA.xOffset.value: ax
                toolheadA.yOffset.value: ay
                toolheadA.zOffset.value: az
                toolheadB.xOffset.value: bx
                toolheadB.yOffset.value: by
                toolheadB.zOffset.value: bz
                topColumn.spacing: 5
                calibration_rowLayout.spacing: -50
            }

            AdvancedInfoCalibrationItem {
                heading.text: "HOT CALIBRATION"
                topColumn.spacing: 5
                calibration_rowLayout.spacing: -50
            }
        }

        ColumnLayout {
            visible: !heatingStatus.visible
            id: setTempcolumnLayout
            width: 240
            height: children.height
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -46
            anchors.horizontalCenterOffset: 218
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12

            Row {
                id: row
                height: 100
                spacing: 5

                TextBody {
                    text: "EXT1"
                    anchors.verticalCenter: parent.verticalCenter
                }

                SpinBox {
                    id: modelExtSpinBox
                    width: 120
                    anchors.verticalCenter: parent.verticalCenter
                    font.pointSize: 10
                    font.family: "Tahoma"
                    font.bold: true
                    value: modelExtSlider.value
                    to: 250
                    stepSize: 1
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                Slider {
                    id: modelExtSlider
                    width: 100
                    anchors.verticalCenter: parent.verticalCenter
                    to: 250
                    stepSize: 5
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    value: modelExtSpinBox.value
                }
            }

            Row {
                id: row1
                height: 100
                spacing: 5

                TextBody {
                    text: "EXT2"
                    anchors.verticalCenter: parent.verticalCenter
                }

                SpinBox {
                    id: supportExtSpinBox
                    width: 120
                    anchors.verticalCenter: parent.verticalCenter
                    font.pointSize: 10
                    font.family: "Tahoma"
                    font.bold: true
                    value: supportExtSlider.value
                    to: 250
                    stepSize: 1
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                Slider {
                    id: supportExtSlider
                    width: 100
                    anchors.verticalCenter: parent.verticalCenter
                    to: 250
                    stepSize: 5
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    value: supportExtSpinBox.value
                }
            }

            Row {
                id: row2
                height: 100
                spacing: 5

                TextBody {
                    text: "CHAM"
                    anchors.verticalCenter: parent.verticalCenter
                }

                SpinBox {
                    id: chamberSpinBox
                    width: 120
                    anchors.verticalCenter: parent.verticalCenter
                    font.pointSize: 10
                    font.family: "Tahoma"
                    font.bold: true
                    value: chamberSlider.value
                    to: 100
                    stepSize: 1
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                Slider {
                    id: chamberSlider
                    width: 100
                    anchors.verticalCenter: parent.verticalCenter
                    to: 100
                    stepSize: 5
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    value: chamberSpinBox.value
                }
            }

            Row {
                id: row3
                height: 100
                spacing: 5

                TextBody {
                    text: "HBB"
                    anchors.verticalCenter: parent.verticalCenter
                }

                SpinBox {
                    id: hbbSpinBox
                    width: 120
                    anchors.verticalCenter: parent.verticalCenter
                    font.pointSize: 10
                    font.family: "Tahoma"
                    font.bold: true
                    value: hbbSlider.value
                    to: 100
                    stepSize: 1
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }

                Slider {
                    id: hbbSlider
                    width: 100
                    anchors.verticalCenter: parent.verticalCenter
                    to: 100
                    stepSize: 5
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    value: hbbSpinBox.value
                }
            }
        }

        ButtonRectanglePrimary {
            id: doHotCalButton
            visible: !heatingStatus.visible
            x: 554
            y: 279
            text: "DO HOT CAL"
            width: 200
            onClicked: {
                bot.doHotCal(true, [modelExtSpinBox.value,
                                    supportExtSpinBox.value,
                                    chamberSpinBox.value,
                                    hbbSpinBox.value])
            }
            enabled: bot.process.stateType == ProcessStateType.ColdCalDone &&
                     (modelExtSpinBox.value > 0 ||
                     supportExtSpinBox.value > 0 ||
                     chamberSpinBox.value > 0 ||
                     hbbSpinBox.value > 0)
        }

        ButtonRectanglePrimary {
            id: calDoneButton
            visible: !heatingStatus.visible
            x: 240
            y: 347
            text: {
                if(bot.process.stateType == ProcessStateType.ColdCalDone) {
                    "SKIP HOT CAL"
                } else {
                    "DONE"
                }
            }
            onClicked: {
                if(bot.process.stateType == ProcessStateType.ColdCalDone) {
                    bot.doHotCal(false, [])
                } else {
                    toolheadCalibration.processDone()
                    if(inFreStep) {
                        settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                        mainSwipeView.swipeToItem(MoreporkUI.BasePage)
                        fre.gotoNextStep(currentFreStep)
                    }
                }
            }
        }
    }

    states: [
        // Stupid stupid QML bug (quirk?) that just wont let the screen go back
        // to its default built-in "base state" at the end of the process even
        // when explicitly assigned to, unless making a clone of the base state
        // with the same name. I hate myself for spending a day tracking this
        // down convinced that it was me.
        State {
            name: "base state"

            PropertyChanges {
                target: contentLeftSide
                visible: true
                image {
                    visible: true
                }
                animatedImage {
                    visible: false
                }
                loadingIcon {
                    visible: false
                }
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                visible: true
            }

            PropertyChanges {
                target: cleanExtrudersSequence
                visible: false
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }

            PropertyChanges {
                target: result
                visible: false
            }
        },

        State {
            name: "clean_nozzles"
            when: bot.process.type == ProcessType.CalibrationProcess &&
                  (bot.process.stateType == ProcessStateType.CheckNozzleClean ||
                   bot.process.stateType == ProcessStateType.HeatingNozzle ||
                   bot.process.stateType == ProcessStateType.CleanNozzle ||
                   bot.process.stateType == ProcessStateType.FinishCleaning ||
                   bot.process.stateType == ProcessStateType.CoolingNozzle) &&
                  !chooseMaterial

            PropertyChanges {
                target: contentLeftSide
                visible: false
            }

            PropertyChanges {
                target: contentRightSide
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.image
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.animatedImage
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.loadingIcon
                visible: false
            }

            PropertyChanges {
                target: cleanExtrudersSequence
                visible: true
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },

        State {
            name: "choose_material"
            when: bot.process.type == ProcessType.CalibrationProcess &&
                  bot.process.stateType == ProcessStateType.CheckNozzleClean &&
                  chooseMaterial

            PropertyChanges {
                target: contentLeftSide
                visible: false
            }

            PropertyChanges {
                target: contentRightSide
                visible: false
            }

            PropertyChanges {
                target: cleanExtrudersSequence
                visible: false
            }

            PropertyChanges {
                target: materialSelector
                visible: true
            }
        },

        State {
            name: "remove_build_plate"
            when: bot.process.type == ProcessType.CalibrationProcess &&
                  bot.process.stateType == ProcessStateType.RemoveBuildPlate

            PropertyChanges {
                target: contentLeftSide
                visible: true
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.image
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.animatedImage
                source: ("qrc:/img/%1.gif").arg(getImageForPrinter("remove_build_plate"))
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.loadingIcon
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("CONFIRM BUILD PLATE IS REMOVED")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("The extruders need to hit precise points under the build plate.")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                text: qsTr("CONFIRM")
                visible: true
            }

            PropertyChanges {
                target: cleanExtrudersSequence
                visible: false
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },

        State {
            name: "install_build_plate"
            when: bot.process.type == ProcessType.CalibrationProcess &&
                  bot.process.stateType == ProcessStateType.InstallBuildPlate

            PropertyChanges {
                target: contentLeftSide
                visible: true
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.image
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.animatedImage
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.animatedImage
                source: ("qrc:/img/%1.gif").arg(getImageForPrinter("insert_build_plate"))
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.loadingIcon
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("INSERT BUILD PLATE AND CLOSE DOOR")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                text: qsTr("NEXT")
                visible: true
            }

            PropertyChanges {
                target: cleanExtrudersSequence
                visible: false
            }

            PropertyChanges {
                target: materialSelector
                visible: false
            }
        },
        State {
            name: "calibrating"
            when: bot.process.type == ProcessType.CalibrationProcess &&
                  bot.process.stateType == ProcessStateType.CalibratingToolheads

            PropertyChanges {
                target: contentLeftSide
                visible: true
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.image
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.animatedImage
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.loadingIcon
                icon_image: LoadingIcon.Loading
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("CALIBRATING")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("Please wait while the printer calibrates.")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                visible: false
            }
        },
        State {
            name: "calibration_finished"

            // See switch case at top of file for the logic
            // to get into this state

            PropertyChanges {
                target: contentLeftSide
                visible: false
            }

            PropertyChanges {
                target: contentRightSide
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.image
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.animatedImage
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.loadingIcon
                icon_image: LoadingIcon.Success
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("CALIBRATION SUCCESSFUL")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("This pair of extruders is now calibrated and can be used for printing.")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                text: qsTr("DONE")
                visible: true
            }

            PropertyChanges {
                target: result
                visible: true
            }
        },

        State {
            name: "cancelling"

            PropertyChanges {
                target: contentLeftSide
                visible: true
            }

            PropertyChanges {
                target: contentRightSide
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.loadingIcon
                icon_image: LoadingIcon.Loading
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.image
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.animatedImage
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("CANCELLING CALIBRATION")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("Please wait")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.buttonPrimary
                visible: false
            }
        },

        State {
            name: "cold_cal_done"
            extend: "calibration_finished"
        }
    ]

    CustomPopup {
        popupName: "CancelCalibration"
        id: cancelCalibrationPopup
        popupWidth: 720
        popupHeight: 250
        showTwoButtons: true
        left_button_text: qsTr("CANCEL CALIBRATION")
        left_button.onClicked: {
            state = "cancelling"
            bot.cancel()
            cancelCalibrationPopup.close()
        }

        right_button_text: qsTr("CONTINUE CALIBRATION")
        right_button.onClicked: {
            cancelCalibrationPopup.close()
        }

        ColumnLayout {
            id: columnLayout
            width: 590
            height: 100
            anchors.top: parent.top
            anchors.topMargin: 145
            anchors.horizontalCenter: parent.horizontalCenter

            TextHeadline {
                text: qsTr("CANCEL CALIBRATION")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            TextBody {
                text: qsTr("Are you sure you want to cancel the calibration process?")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }
        }
    }

    CustomPopup {
        popupName: "ResumeManualCalibration"
        id: resumeManualCalibrationPopup
        popupHeight: manualCalColumnLayout.height+145
        showTwoButtons: true
        left_button_text: qsTr("EXIT")
        left_button.onClicked: {
            resumeManualCalibrationPopup.close()
        }

        right_button_text: qsTr("START")
        right_button.onClicked: {
            extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.BasePage)
            extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.ManualZCalibrationPage)
            resumeManualCalibrationPopup.close()
        }

        ColumnLayout {
            id: manualCalColumnLayout
            height: children.height
            width: parent.width-80
            anchors.top: resumeManualCalibrationPopup.popupContainer.top
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Image {
                id: error_image
                width: sourceSize.width - 10
                height: sourceSize.height -10
                Layout.alignment: Qt.AlignHCenter
                source: "qrc:/img/process_error_small.png"
            }

            TextHeadline {
                text: qsTr("RESUME MANUAL Z-CALIBRATION")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            TextBody {
                text: qsTr("Would you like to restart the Manual Z-Calibration process? "+
                           "It is highly recommended for optimum print quality.")
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: parent.width
            }
        }
    }
}
