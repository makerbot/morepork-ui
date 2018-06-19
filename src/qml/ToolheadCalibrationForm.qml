import QtQuick 2.4
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    id: calibrationPage
    width: 800
    height: 440
    smooth: false
    antialiasing: false
    property alias buttonOk: buttonOk
    property alias actionButton: actionButton
    property alias cancelCalibrationPopup: cancelCalibrationPopup
    property alias continueButton: continue_mouseArea
    property alias stopButton: stop_mouseArea
    signal processDone
    property int errorCode
    property bool hasFailed: bot.process.errorCode !== 0
    onHasFailedChanged: {
        if(bot.process.type == ProcessType.CalibrationProcess) {
            errorCode = bot.process.errorCode
            state = "failed"
        }
    }

    property int currentState: bot.process.stateType
    onCurrentStateChanged: {
        if(bot.process.type == ProcessType.CalibrationProcess) {
            switch(currentState) {
            case ProcessStateType.Cancelling:
                state = "cancelling"
                break;
            case ProcessStateType.CleaningUp:
               if(state != "cancelling") {
                   state = "calibration_finished"
               }
               break;
            default:
                break;
            }
        }
        else if(bot.process.type == ProcessType.None) {
            if(state == "cancelling") {
                calibrateToolheadsItem.altBack()
            }
        }
    }

    Image {
        id: error_image
        width: sourceSize.width
        height: sourceSize.height
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        visible: false
        source: "qrc:/img/firmware_update_error.png"

        Text {
            id: text1
            text: "CALIBRATION FAILED"
            anchors.top: parent.bottom
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#ffffff"
            font.letterSpacing: 2
            font.family: "Antennae"
            font.pixelSize: 24
            font.weight: Font.Light
        }

        Text {
            id: text2
            text: "Error " + errorCode
            anchors.top: text1.bottom
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#ffffff"
            font.family: "Antennae"
            font.pixelSize: 24
            font.weight: Font.Light
        }

        RoundedButton {
            id: buttonOk
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: text2.bottom
            anchors.topMargin: 25
            buttonHeight: 50
            buttonWidth: 80
            label: "OK"
        }
    }

    Image {
        id: header_image
        width: sourceSize.width
        height: sourceSize.height
        anchors.verticalCenterOffset: -20
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/calib_extruder.png"
        visible: true

        Item {
            id: mainItem
            width: 400
            height: 250
            visible: true
            anchors.left: parent.right
            anchors.leftMargin: 0
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 30

            Text {
                id: title
                width: 252
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
                font.family: "Antennae"
                font.pixelSize: 26
                font.weight: Font.Bold
                lineHeight: 1.2
                visible: true
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
                font.family: "Antennae"
                font.pixelSize: 18
                font.weight: Font.Light
                text: "Use this process anytime an extruder (new or used) is attached to the printer."
                lineHeight: 1.2
                visible: true
            }

            RoundedButton {
                id: actionButton
                label: "BEGIN CALIBRATION"
                buttonWidth: 310
                buttonHeight: 50
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: subtitle.bottom
                anchors.topMargin: 20
                visible: true
            }
        }
    }

    LoadingIcon {
        id: loadingIcon
        anchors.verticalCenterOffset: -40
        anchors.left: parent.left
        anchors.leftMargin: 100
        anchors.verticalCenter: parent.verticalCenter
        loading: visible
        visible: false

        Text {
            id: processText
            width: 275
            text: "CALIBRATING"
            wrapMode: Text.WordWrap
            anchors.left: parent.right
            anchors.leftMargin: 75
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -35
            color: "#e6e6e6"
            font.family: "Antennae"
            font.pixelSize: 22
            font.weight: Font.Bold
            lineHeight: 1.2
            font.letterSpacing: 3
            visible: parent.visible
        }

        Text {
            id: processDescText
            width: 275
            text: "Please wait while the printer performs the calibration process."
            wrapMode: Text.WordWrap
            anchors.left: parent.right
            anchors.leftMargin: 75
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 35
            color: "#e6e6e6"
            font.family: "Antennae"
            font.pixelSize: 18
            font.weight: Font.Light
            lineHeight: 1.2
            visible: parent.visible
        }
    }

    states: [

        State {
            name: "remove_build_plate"
            when: bot.process.type == ProcessType.CalibrationProcess &&
                  bot.process.stateType == ProcessStateType.RemoveBuildPlate

            PropertyChanges {
                target: loadingIcon
                visible: false
            }

            PropertyChanges {
                target: header_image
                source: "qrc:/img/calib_remove_build_plate.png"
            }

            PropertyChanges {
                target: title
                text: "REMOVE BUILD PLATE"
            }

            PropertyChanges {
                target: subtitle
                text: "This part of the process is performed with the build plate removed."
            }

            PropertyChanges {
                target: actionButton
                label_width: 400
                buttonWidth: 400
                label: "BUILD PLATE IS REMOVED"
            }
        },
        State {
            name: "install_build_plate"
            when: bot.process.type == ProcessType.CalibrationProcess &&
                  bot.process.stateType == ProcessStateType.InstallBuildPlate

            PropertyChanges {
                target: loadingIcon
                visible: false
            }

            PropertyChanges {
                target: header_image
                source: "qrc:/img/calib_insert_build_plate.png"
            }

            PropertyChanges {
                target: title
                text: "INSERT     BUILD PLATE"
            }

            PropertyChanges {
                target: subtitle
                text: "This part of the process is performed with the build plate installed."
            }

            PropertyChanges {
                target: actionButton
                label_width: 400
                label: "BUILD PLATE IS INSTALLED"
                buttonWidth: 410
            }
        },
        State {
            name: "calibrating"
            when: bot.process.type == ProcessType.CalibrationProcess &&
                  bot.process.stateType == ProcessStateType.CalibratingToolheads

            PropertyChanges {
                target: header_image
                visible: false
            }

            PropertyChanges {
                target: loadingIcon
                anchors.verticalCenterOffset: -20
                visible: true
            }
        },
        State {
            name: "calibration_finished"

            // See switch case at top of file for the logic
            // to get into this state

            PropertyChanges {
                target: loadingIcon
                visible: false
            }

            PropertyChanges {
                target: loadingIcon
                visible: false
            }

            PropertyChanges {
                target: header_image
                source: "qrc:/img/calib_successful.png"
            }

            PropertyChanges {
                target: title
                text: "CALIBRATION SUCCESSFUL"
            }

            PropertyChanges {
                target: subtitle
                text: "This pair of extruders are now calibrated and can now be used for printing."
            }

            PropertyChanges {
                target: actionButton
                label_width: 100
                label: "FINISH"
                buttonWidth: 125
            }
        },

        State {
            name: "failed"
            // See switch case at top of the file for
            // the logic to get into this state.

            PropertyChanges {
                target: error_image
                visible: true
            }

            PropertyChanges {
                target: header_image
                visible: false
            }

            PropertyChanges {
                target: loadingIcon
                visible: false
            }
        },
        State {
            name: "cancelling"

            PropertyChanges {
                target: header_image
                visible: false
            }

            PropertyChanges {
                target: loadingIcon
                visible: true
                anchors.verticalCenterOffset: "-20"
            }

            PropertyChanges {
                target: processText
                text: "CANCELLING"
            }

            PropertyChanges {
                target: processDescText
                text: "Please wait."
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
            anchors.verticalCenterOffset: rotation == 180 ? 40 : -40
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
                        font.family: "Antennae"
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
                        font.family: "Antennae"
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
                    font.family: "Antennae"
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
                    font.family: "Antennae"
                    font.pixelSize: 18
                    lineHeight: 1.3
                }
            }
        }
    }
}
