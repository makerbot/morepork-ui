import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0
import ErrorTypeEnum 1.0

Item {
    id: calibrationPage
    width: 800
    height: 440
    smooth: false
    antialiasing: false
    property alias actionButton: actionButton
    property alias actionButton2: actionButton2
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
        source: "qrc:/img/calib_extruders.png"
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
            text: "EXTRUDER CALIBRATION"
            antialiasing: false
            smooth: false
            font.letterSpacing: 3
            wrapMode: Text.WordWrap
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            color: "#e6e6e6"
            font.family: "Antenna"
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
            font.family: "Antenna"
            font.pixelSize: 18
            font.weight: Font.Light
            text: "Use this process anytime an extruder (new or used) is attached to the printer."
            lineHeight: 1.2
            opacity: 1.0
        }

        RoundedButton {
            id: actionButton
            label: "BEGIN CALIBRATION"
            buttonWidth: 310
            buttonHeight: 50
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: subtitle.bottom
            anchors.topMargin: 25
            opacity: 1.0
        }

        RoundedButton {
            id: actionButton2
            label: "SKIP"
            buttonWidth: 120
            buttonHeight: 50
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: actionButton.bottom
            anchors.topMargin: 15
            opacity: 0.0
        }

        RowLayout {
            id: temperatureDisplay
            anchors.top: subtitle.bottom
            anchors.topMargin: 25
            width: children.width
            height: 35
            anchors.left: parent.left
            anchors.leftMargin: 0
            spacing: 10
            opacity: 0

            Text {
                id: extruder_A_current_temperature_text
                text: bot.extruderACurrentTemp + "C"
                font.family: "Antenna"
                color: "#ffffff"
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pixelSize: 20
            }

            Rectangle {
                id: divider_rectangle1
                width: 1
                height: 25
                color: "#ffffff"
            }

            Text {
                id: extruder_A_target_temperature_text
                text: (bot.process.stateType == ProcessStateType.CoolingNozzle) ?
                           "50C" :
                           (bot.extruderATargetTemp + "C")
                font.family: "Antenna"
                color: "#ffffff"
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pixelSize: 20
            }

            Rectangle {
                width: 10
                color: "#000000"
            }

            Text {
                id: extruder_B_current_temperature_text
                text: bot.extruderBCurrentTemp + "C"
                font.family: "Antenna"
                color: "#ffffff"
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pixelSize: 20
            }

            Rectangle {
                id: divider_rectangle2
                width: 1
                height: 25
                color: "#ffffff"
            }

            Text {
                id: extruder_B_target_temperature_text
                text: (bot.process.stateType == ProcessStateType.CoolingNozzle) ?
                          "50C" :
                          (bot.extruderBTargetTemp + "C")
                font.family: "Antenna"
                color: "#ffffff"
                font.letterSpacing: 3
                font.weight: Font.Light
                font.pixelSize: 20
            }
        }
    }

    LoadingIcon {
        id: loadingIcon
        anchors.verticalCenterOffset: -30
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.verticalCenter: parent.verticalCenter
        opacity: 0
        visible: true
    }

    states: [
        State {
            name: "check_nozzle_clean"
            when: bot.process.type == ProcessType.CalibrationProcess &&
                  bot.process.stateType == ProcessStateType.CheckNozzleClean

            PropertyChanges {
                target: animated_image
                source: ""
                opacity: 0
            }

            PropertyChanges {
                target: header_image
                source: "qrc:/img/calib_check_nozzles_clean.png"
                opacity: 1
            }

            PropertyChanges {
                target: mainItem
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: "CHECK EXTRUDER NOZZLES"
                anchors.topMargin: -20
                font.pixelSize: 22
                opacity: 1.0
            }

            PropertyChanges {
                target: subtitle
                text: "If there is material on the tips of the extruders, use the steel brush to clean them in the next steps."
                font.pixelSize: 18
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton
                label_width: 300
                buttonWidth: 300
                label: "CLEAN EXTRUDERS"
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton2
                label: "SKIP"
                buttonWidth: 120
                buttonHeight: 50
                opacity: 1.0
            }

            PropertyChanges {
                target: loadingIcon
                opacity: 0
            }

            PropertyChanges {
                target: temperatureDisplay
                opacity: 0
            }
        },

        State {
            name: "heating_nozzle"
            when: bot.process.type == ProcessType.CalibrationProcess &&
                  bot.process.stateType == ProcessStateType.HeatingNozzle

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
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: "EXTRUDERS\nHEATING UP"
                font.pixelSize: 22
                opacity: 1.0
            }

            PropertyChanges {
                target: subtitle
                text: "The extruders are heating up. Please wait to clean nozzles."
                font.pixelSize: 18
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton
                opacity: 0
            }

            PropertyChanges {
                target: actionButton2
                opacity: 0
            }

            PropertyChanges {
                target: temperatureDisplay
                opacity: 1.0
            }

            PropertyChanges {
                target: loadingIcon
                opacity: 1.0
            }
        },

        State {
            name: "clean_nozzle"
            when: bot.process.type == ProcessType.CalibrationProcess &&
                  bot.process.stateType == ProcessStateType.CleanNozzle

            PropertyChanges {
                target: header_image
                opacity: 0
            }

            PropertyChanges {
                target: animated_image
                source: "qrc:/img/calib_scrub_nozzles.gif"
                playing: true
                opacity: 1
            }

            PropertyChanges {
                target: mainItem
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: "CLEAN EXTRUDER NOZZLES"
                font.pixelSize: 22
                opacity: 1.0
            }

            PropertyChanges {
                target: subtitle
                text: "Use the provided brush to clean the tips of the extruders for the most accurate calibration."
                font.pixelSize: 18
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton
                label_width: 100
                buttonWidth: 100
                label: "NEXT"
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton2
                opacity: 0
            }

            PropertyChanges {
                target: loadingIcon
                opacity: 0
            }

            PropertyChanges {
                target: temperatureDisplay
                opacity: 0
            }
        },

        State {
            name: "cooling_nozzle"
            when: bot.process.type == ProcessType.CalibrationProcess &&
                  bot.process.stateType == ProcessStateType.CoolingNozzle

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
                opacity: 1
            }

            PropertyChanges {
                target: title
                text: "COOLING EXTRUDER NOZZLES"
                font.pixelSize: 22
                opacity: 1.0
            }

            PropertyChanges {
                target: subtitle
                text: "Calibration will continue after the nozzles cool down."
                font.pixelSize: 18
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton
                opacity: 0
            }

            PropertyChanges {
                target: actionButton2
                opacity: 0
            }

            PropertyChanges {
                target: temperatureDisplay
                opacity: 1.0
            }

            PropertyChanges {
                target: loadingIcon
                opacity: 1.0
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
                text: "REMOVE BUILD PLATE"
                font.pixelSize: 22
                opacity: 1.0
            }

            PropertyChanges {
                target: subtitle
                text: "This part of the process is performed with the build plate removed."
                font.pixelSize: 18
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton
                label_width: 400
                buttonWidth: 400
                label: "BUILD PLATE IS REMOVED"
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton2
                opacity: 0
            }

            PropertyChanges {
                target: temperatureDisplay
                opacity: 0
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
                text: "INSERT\nBUILD PLATE"
                font.pixelSize: 22
                anchors.topMargin: 20
                opacity: 1.0
            }

            PropertyChanges {
                target: subtitle
                text: "This part of the process is performed with the build plate installed."
                font.pixelSize: 18
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton
                label_width: 400
                label: "BUILD PLATE IS INSTALLED"
                buttonWidth: 410
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton2
                opacity: 0
            }

            PropertyChanges {
                target: temperatureDisplay
                opacity: 0
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
                text: "CALIBRATING"
                font.pixelSize: 22
                anchors.topMargin: 40
                opacity: 1
            }

            PropertyChanges {
                target: subtitle
                text: "Please wait while the printer calibrates."
                font.pixelSize: 18
                opacity: 1
            }

            PropertyChanges {
                target: temperatureDisplay
                opacity: 0
            }

            PropertyChanges {
                target: actionButton
                opacity: 0
            }

            PropertyChanges {
                target: actionButton2
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
                text: "CALIBRATION SUCCESSFUL"
                anchors.topMargin: 0
                font.pixelSize: 22
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton2
                opacity: 0
            }

            PropertyChanges {
                target: subtitle
                text: "This pair of extruders are now calibrated and can now be used for printing."
                font.pixelSize: 18
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton
                label_width: 100
                label: "DONE"
                buttonWidth: 125
                opacity: 1.0
            }

            PropertyChanges {
                target: temperatureDisplay
                opacity: 0
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
                text: "CANCELLING"
                anchors.topMargin: 40
                font.pixelSize: 22
                opacity: 1.0
            }

            PropertyChanges {
                target: subtitle
                text: "Please wait."
                font.pixelSize: 18
                opacity: 1.0
            }

            PropertyChanges {
                target: temperatureDisplay
                opacity: 0
            }

            PropertyChanges {
                target: actionButton
                opacity: 0
            }

            PropertyChanges {
                target: actionButton2
                opacity: 0
            }
        }
    ]

    Popup {
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
                        text: "STOP CALIBRATION"
                        Layout.fillHeight: false
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Layout.fillWidth: false
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: "Antenna"
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
                        text: "CONTINUE"
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        font.letterSpacing: 3
                        font.weight: Font.Bold
                        font.family: "Antenna"
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
                    text: "STOP CALIBRATION?"
                    font.letterSpacing: 3
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: "Antenna"
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Text {
                    id: cancel_description_text
                    color: "#cbcbcb"
                    text: "Are you sure you want to cancel calibration?"
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.weight: Font.Light
                    wrapMode: Text.WordWrap
                    font.family: "Antenna"
                    font.pixelSize: 18
                    lineHeight: 1.3
                }
            }
        }
    }
}
