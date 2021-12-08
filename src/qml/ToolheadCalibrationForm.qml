import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import ErrorTypeEnum 1.0
import ExtruderTypeEnum 1.0

LoggingItem {
    itemName: "ToolheadCalibration"
    id: calibrationPage
    width: 800
    height: 440
    smooth: false
    antialiasing: false
    property alias actionButton: actionButton
    property alias cancelCalibrationPopup: cancelCalibrationPopup
    property alias continueButton: continue_mouseArea
    property alias stopButton: stop_mouseArea
    signal processDone

    property int currentState: bot.process.stateType
    onCurrentStateChanged: {
        if(bot.process.type == ProcessType.CalibrationProcess) {
            switch(currentState) {
            case ProcessStateType.Cancelling:
                state = "cancelling"
                break;
            case ProcessStateType.CleaningUp:
               if (!bot.process.cancelled) {
                   state = "calibration_finished"
               }
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
                calibrateToolheadsItem.altBack()
            }
        }
    }

    property bool chooseMaterial: false

    AnimatedImage {
        id: animated_image
        width: 400
        height: 480
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -20
        anchors.left: parent.left
        anchors.leftMargin: 0
        source: ""
        cache: false
        playing: false
        opacity: 0
        smooth: false
    }

    Image {
        id: header_image
        width: sourceSize.width
        height: sourceSize.height
        anchors.verticalCenterOffset: -20
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        source: {
            // At places where images of both the extruders are displayed
            // together we just check the model extruder since the support
            // extruder has to correspond to it for the printer to be usable,
            // to determine which version of extruders to display as a set.
            switch(bot.extruderAType) {
            case ExtruderType.MK14:
                "qrc:/img/calib_extruders.png"
                break;
            case ExtruderType.MK14_HOT:
                "qrc:/img/calib_extruders_XA.png"
                break;
            default:
                "qrc:/img/calib_extruders.png"
                break;
            }
        }
        opacity: 1.0
    }

    Item {
        id: mainItem
        width: 400
        height: 250
        visible: true
        anchors.left: parent.left
        anchors.leftMargin: header_image.width
        anchors.verticalCenter: parent.verticalCenter
        opacity: 1.0

        Text {
            id: title
            width: 350
            text: qsTr("EXTRUDER CALIBRATION")
            antialiasing: false
            smooth: false
            font.letterSpacing: 3
            wrapMode: Text.WordWrap
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            color: "#e6e6e6"
            font.family: defaultFont.name
            font.pixelSize: 26
            font.weight: Font.Bold
            lineHeight: 1.2
            opacity: 1.0
        }

        Text {
            id: subtitle
            width: 350
            wrapMode: Text.WordWrap
            anchors.top: title.bottom
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: 0
            color: "#e6e6e6"
            font.family: defaultFont.name
            font.pixelSize: 18
            font.weight: Font.Light
            text: qsTr("Use this process anytime an extruder (new or used) is attached to the printer.")
            lineHeight: 1.2
            opacity: 1.0
        }

        RoundedButton {
            id: actionButton
            label: qsTr("BEGIN CALIBRATION")
            buttonWidth: 310
            buttonHeight: 50
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: subtitle.bottom
            anchors.topMargin: 25
            opacity: 1.0
        }
    }

    LoadingIcon {
        id: loadingIcon
        anchors.verticalCenterOffset: -30
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.verticalCenter: parent.verticalCenter
        opacity: 0
    }

    CleanExtrudersSequence {
        id: cleanExtruders
        anchors.verticalCenter: parent.verticalCenter
        visible: false
    }

    CleanExtruderSettings {
        id: materialSelector
        visible: false
    }

    states: [
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
                target: animated_image
                source: ""
                opacity: 0
            }

            PropertyChanges {
                target: header_image
                opacity: 0
            }

            PropertyChanges {
                target: mainItem
                opacity: 0
            }

            PropertyChanges {
                target: loadingIcon
                opacity: 0
            }

            PropertyChanges {
                target: cleanExtruders
                visible: true
            }
        },

        State {
            name: "choose_material"
            when: bot.process.type == ProcessType.CalibrationProcess &&
                  (bot.process.stateType == ProcessStateType.CheckNozzleClean ||
                   bot.process.stateType == ProcessStateType.HeatingNozzle ||
                   bot.process.stateType == ProcessStateType.CleanNozzle ||
                   bot.process.stateType == ProcessStateType.FinishCleaning ||
                   bot.process.stateType == ProcessStateType.CoolingNozzle) &&
                   chooseMaterial

            PropertyChanges {
                target: animated_image
                source: ""
                opacity: 0
            }

            PropertyChanges {
                target: header_image
                opacity: 0
            }

            PropertyChanges {
                target: mainItem
                opacity: 0
            }

            PropertyChanges {
                target: loadingIcon
                opacity: 0
            }

            PropertyChanges {
                target: cleanExtruders
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
                target: loadingIcon
                opacity: 0
            }

            PropertyChanges {
                target: animated_image
                source: ""
                opacity: 0
            }

            PropertyChanges {
                target: header_image
                source: "qrc:/img/calib_remove_build_plate.png"
                opacity: 1.0
            }

            PropertyChanges {
                target: mainItem
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: qsTr("REMOVE BUILD PLATE")
                font.pixelSize: 22
                opacity: 1.0
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("This part of the process is performed with the build plate removed.")
                font.pixelSize: 18
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton
                label_width: 400
                buttonWidth: 400
                label: qsTr("BUILD PLATE IS REMOVED")
                opacity: 1.0
            }
        },

        State {
            name: "install_build_plate"
            when: bot.process.type == ProcessType.CalibrationProcess &&
                  bot.process.stateType == ProcessStateType.InstallBuildPlate

            PropertyChanges {
                target: loadingIcon
                opacity: 0
            }

            PropertyChanges {
                target: animated_image
                source: ""
                opacity: 0
            }

            PropertyChanges {
                target: header_image
                source: "qrc:/img/calib_insert_build_plate.png"
                opacity: 1.0
            }

            PropertyChanges {
                target: mainItem
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: qsTr("INSERT\nBUILD PLATE")
                font.pixelSize: 22
                anchors.topMargin: 20
                opacity: 1.0
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("This part of the process is performed with the build plate installed.")
                font.pixelSize: 18
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton
                label_width: 400
                label: qsTr("BUILD PLATE IS INSTALLED")
                buttonWidth: 410
                opacity: 1.0
            }
        },
        State {
            name: "calibrating"
            when: bot.process.type == ProcessType.CalibrationProcess &&
                  bot.process.stateType == ProcessStateType.CalibratingToolheads

            PropertyChanges {
                target: animated_image
                source: ""
                opacity: 0
            }

            PropertyChanges {
                target: header_image
                opacity: 0
            }

            PropertyChanges {
                target: loadingIcon
                opacity: 1.0
            }

            PropertyChanges {
                target: mainItem
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: qsTr("CALIBRATING")
                font.pixelSize: 22
                anchors.topMargin: 40
                opacity: 1
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("Please wait while the printer calibrates.")
                font.pixelSize: 18
                opacity: 1
            }

            PropertyChanges {
                target: actionButton
                opacity: 0
            }
        },
        State {
            name: "calibration_finished"

            // See switch case at top of file for the logic
            // to get into this state

            PropertyChanges {
                target: loadingIcon
                opacity: 0
            }

            PropertyChanges {
                target: animated_image
                source: ""
                opacity: 0
            }

            PropertyChanges {
                target: header_image
                source: "qrc:/img/calib_extruders.png"
                opacity: 1.0
            }

            PropertyChanges {
                target: mainItem
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: qsTr("CALIBRATION SUCCESSFUL")
                anchors.topMargin: 0
                font.pixelSize: 22
                opacity: 1.0
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("This pair of extruders are now calibrated and can now be used for printing.")
                font.pixelSize: 18
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton
                label_width: 100
                label: qsTr("DONE")
                buttonWidth: 125
                opacity: 1.0
            }
        },

        State {
            name: "cancelling"

            PropertyChanges {
                target: animated_image
                source: ""
                opacity: 0
            }

            PropertyChanges {
                target: header_image
                opacity: 0
            }

            PropertyChanges {
                target: loadingIcon
                opacity: 1.0
            }

            PropertyChanges {
                target: mainItem
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: qsTr("CANCELLING")
                anchors.topMargin: 40
                font.pixelSize: 22
                opacity: 1.0
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("Please wait.")
                font.pixelSize: 18
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton
                opacity: 0
            }
        }
    ]

    LoggingPopup {
        popupName: "CancelCalibration"
        id: cancelCalibrationPopup
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
        onOpened: {
            continue_calib_text.color = "#000000"
            continue_rectangle.color = "#ffffff"
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
                    id: stop_rectangle
                    x: 0
                    y: 0
                    width: 360
                    height: 72
                    color: "#00000000"
                    radius: 10

                    Text {
                        id: stop_calib_text
                        color: "#ffffff"
                        text: qsTr("STOP CALIBRATION")
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
                        id: stop_mouseArea
                        anchors.fill: parent
                        onPressed: {
                            stop_calib_text.color = "#000000"
                            stop_rectangle.color = "#ffffff"
                            continue_calib_text.color = "#ffffff"
                            continue_rectangle.color = "#00000000"
                        }
                        onReleased: {
                            stop_calib_text.color = "#ffffff"
                            stop_rectangle.color = "#00000000"
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
                        id: continue_calib_text
                        color: "#ffffff"
                        text: qsTr("CONTINUE")
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
                            continue_calib_text.color = "#000000"
                            continue_rectangle.color = "#ffffff"
                            stop_calib_text.color = "#ffffff"
                            stop_rectangle.color = "#00000000"
                        }
                        onReleased: {
                            continue_calib_text.color = "#ffffff"
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
                    text: qsTr("STOP CALIBRATION?")
                    font.letterSpacing: 3
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: defaultFont.name
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Text {
                    id: cancel_description_text
                    color: "#cbcbcb"
                    text: qsTr("Are you sure you want to cancel calibration?")
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
}
