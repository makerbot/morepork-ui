import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

Item {
    id: cleanExtrudersSequence
    width: 800
    height: 440

    property alias actionButton: actionButton
    property alias actionButton2: actionButton2

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
        source: ""
        opacity: 1.0
    }

    Item {
        id: mainItem
        width: 400
        height: 250
        visible: true
        anchors.left: parent.left
        anchors.leftMargin: 400
        anchors.verticalCenter: parent.verticalCenter
        opacity: 1.0

        Text {
            id: title
            width: 350
            text: qsTr("CHECK EXTRUDER NOZZLES")
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
            text: qsTr("If there is material on the tips of the extruders, use the steel brush to clean them in the next steps.")
            lineHeight: 1.2
            opacity: 1.0
        }

        RoundedButton {
            id: actionButton
            label: qsTr("CLEAN EXTRUDERS")
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
            label: qsTr("SKIP")
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
                font.family: defaultFont.name
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
                font.family: defaultFont.name
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
                font.family: defaultFont.name
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
                font.family: defaultFont.name
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
            when: bot.process.stateType == ProcessStateType.CheckNozzleClean

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
                text: qsTr("CHECK EXTRUDER NOZZLES")
                anchors.topMargin: -20
                font.pixelSize: 22
                opacity: 1.0
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("If there is material on the tips of the extruders, use the steel brush to clean them in the next steps.")
                font.pixelSize: 18
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton
                label_width: 300
                buttonWidth: 300
                label: qsTr("CLEAN EXTRUDERS")
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton2
                label: qsTr("SKIP")
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
            when: bot.process.stateType == ProcessStateType.HeatingNozzle

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
                text: qsTr("EXTRUDERS\nHEATING UP")
                font.pixelSize: 22
                opacity: 1.0
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("The extruders are heating up. Please wait to clean nozzles.")
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
            when: bot.process.stateType == ProcessStateType.CleanNozzle ||
                  bot.process.stateType == ProcessStateType.FinishCleaning

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
                text: qsTr("CLEAN EXTRUDER NOZZLES")
                font.pixelSize: 22
                opacity: 1.0
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("Use the provided brush to clean the tips of the extruders for the most accurate calibration.")
                font.pixelSize: 18
                opacity: 1.0
            }

            PropertyChanges {
                target: actionButton
                label_width: 100
                buttonWidth: 100
                label: qsTr("NEXT")
                opacity: {
                    bot.process.stateType == ProcessStateType.FinishCleaning ?
                                1.0 : 0
                }
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
            when: bot.process.stateType == ProcessStateType.CoolingNozzle

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
                text: qsTr("COOLING EXTRUDER NOZZLES")
                font.pixelSize: 22
                opacity: 1.0
            }

            PropertyChanges {
                target: subtitle
                text: qsTr("The process will continue after the nozzles cool down.")
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
        }
    ]
}
