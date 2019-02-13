import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import FreStepEnum 1.0

Item {
    id: main_fre_item
    width: 800
    height: 480
    property alias continueButton: continueButton

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Image {
        id: bot_image
        width: sourceSize.width
        height: sourceSize.height
        visible: currentFreStep == FreStep.Welcome ||
                 currentFreStep == FreStep.SetupComplete
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/img/sombrero_welcome.png"
    }

    Item {
        id: instructions_item
        width: 400
        height: 300
        visible: true
        anchors.left: parent.left
        anchors.leftMargin: 400
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: title_text
            color: "#ffffff"
            text: "WELCOME"
            font.letterSpacing: 2
            anchors.top: parent.top
            anchors.topMargin: 35
            font.family: "Antennae"
            font.weight: Font.Bold
            font.pixelSize: 28
            lineHeight: 1.2
        }

        Text {
            id: subtitle_text
            color: "#cbcbcb"
            text: "Follow these steps to set up your\nMethod Performance 3D Printer."
            anchors.top: title_text.bottom
            anchors.topMargin: 20
            font.family: "Antennae"
            font.weight: Font.Light
            font.pixelSize: 20
            lineHeight: 1.3
        }

        RoundedButton {
            id: continueButton
            anchors.top: subtitle_text.bottom
            anchors.topMargin: 30
            label: "BEGIN SETUP"
            label_width: 210
            buttonHeight: 50
            buttonWidth: 210
        }
    }

    Item {
        id: progress_item
        width: 800
        height: 100
        visible: false
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 45
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            id: progress_rectangle
            width: 2
            height: parent.width
            anchors.centerIn: parent
            rotation: -90
            gradient: Gradient {
                GradientStop {
                    id: startStep
                    position: 0.0
                    color: "#ffffff"
                }

                GradientStop {
                    id: midStep
                    position: 0.167
                    color: "#ffffff"
                }

                GradientStop {
                    id: endStep
                    position: 0.3
                    color: "#000000"
                }
            }
        }

        RowLayout {
            id: progress_circle_layout
            width: 650
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: rectangle1
                width: 14
                height: 14
                color: "#ffffff"
                radius: 7
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                Text {
                    id: text1
                    color: parent.color
                    text: "SETUP"
                    font.letterSpacing: 1
                    anchors.top: parent.bottom
                    anchors.topMargin: 18
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: "Antennae"
                    font.weight: Font.Bold
                    font.pixelSize: 14
                }
            }

            Rectangle {
                id: rectangle2
                width: 14
                height: 14
                color: "#ffffff"
                radius: 7
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                Text {
                    id: text2
                    color: parent.color
                    text: "LOG IN"
                    font.letterSpacing: 1
                    anchors.top: parent.bottom
                    anchors.topMargin: 18
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: "Antennae"
                    font.weight: Font.Bold
                    font.pixelSize: 14
                }
            }

            Rectangle {
                id: rectangle3
                width: 14
                height: 14
                color: "#ffffff"
                radius: 7
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                Text {
                    id: text3
                    color: parent.color
                    text: "EXTRUDERS"
                    font.letterSpacing: 1
                    anchors.top: parent.bottom
                    anchors.topMargin: 18
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: "Antennae"
                    font.weight: Font.Bold
                    font.pixelSize: 14
                }
            }

            Rectangle {
                id: rectangle4
                width: 14
                height: 14
                color: "#ffffff"
                radius: 7
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                Text {
                    id: text4
                    color: parent.color
                    text: "MATERIAL"
                    font.letterSpacing: 1
                    anchors.top: parent.bottom
                    anchors.topMargin: 18
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: "Antennae"
                    font.weight: Font.Bold
                    font.pixelSize: 14
                }
            }

            Rectangle {
                id: rectangle5
                width: 14
                height: 14
                color: "#ffffff"
                radius: 7
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

                Text {
                    id: text5
                    color: parent.color
                    text: "PRINT"
                    font.letterSpacing: 1
                    anchors.top: parent.bottom
                    anchors.topMargin: 18
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: "Antennae"
                    font.weight: Font.Bold
                    font.pixelSize: 14
                }
            }
        }
    }
    states: [
        State {
            name: "wifi_setup"

            PropertyChanges {
                target: bot_image
                visible: false
            }

            PropertyChanges {
                target: instructions_item
                anchors.leftMargin: 50
            }

            PropertyChanges {
                target: title_text
                text: {
                    if(bot.net.interface == "ethernet" ||
                       bot.net.interface == "wifi") {
                        "CONNECTED TO NETWORK"
                    }
                    else {
                        "WI-FI SETUP"
                    }
                }
                lineHeight: 1.2
                font.pixelSize: 28
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: subtitle_text
                text: {
                    if(bot.net.interface == "ethernet" ||
                       bot.net.interface == "wifi") {
                        "You seem to be connected to a network."
                    }
                    else {
                        "Connect to the internet to enable remote monitoring and\nprinting from any connected device."
                    }
                }
            }

            PropertyChanges {
                target: continueButton
                label_width: 300
                buttonWidth: {
                    if(bot.net.interface == "ethernet" ||
                       bot.net.interface == "wifi") {
                        175
                    }
                    else {
                        300
                    }
                }
                label: {
                    if(bot.net.interface == "ethernet" ||
                       bot.net.interface == "wifi") {
                        "CONTINUE"
                    }
                    else {
                        "CHOOSE NETWORK"
                    }
                }
                anchors.topMargin: 30
            }

            PropertyChanges {
                target: rectangle2
                color: "#595959"
            }

            PropertyChanges {
                target: rectangle3
                color: "#595959"
            }

            PropertyChanges {
                target: rectangle4
                color: "#595959"
            }

            PropertyChanges {
                target: rectangle5
                color: "#595959"
            }

            PropertyChanges {
                target: progress_item
                visible: true
            }
        },
        State {
            name: "software_update"

            PropertyChanges {
                target: bot_image
                visible: false
            }

            PropertyChanges {
                target: instructions_item
                anchors.leftMargin: 50
            }

            PropertyChanges {
                target: title_text
                text: "PRINTER SOFTWARE UPDATE AVAILABLE"
                lineHeight: 1.2
                font.pixelSize: 28
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: subtitle_text
                text: "Update the Method’s printer software for the most up to date\nfeatures and quality."
            }

            PropertyChanges {
                target: continueButton
                label_width: 175
                buttonWidth: 175
                label: "CONTINUE"
                anchors.topMargin: 30
            }

            PropertyChanges {
                target: rectangle2
                color: "#595959"
            }

            PropertyChanges {
                target: rectangle3
                color: "#595959"
            }

            PropertyChanges {
                target: rectangle4
                color: "#595959"
            }

            PropertyChanges {
                target: rectangle5
                color: "#595959"
            }

            PropertyChanges {
                target: progress_item
                visible: true
            }
        },
        State {
            name: "name_printer"

            PropertyChanges {
                target: bot_image
                visible: false
            }

            PropertyChanges {
                target: instructions_item
                anchors.leftMargin: 50
            }

            PropertyChanges {
                target: title_text
                text: "NAME PRINTER"
                lineHeight: 1.2
                font.pixelSize: 28
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: subtitle_text
                text: "Give this printer a name to find it easier."
            }

            PropertyChanges {
                target: continueButton
                label_width: 175
                buttonWidth: 175
                label: "CONTINUE"
                anchors.topMargin: 30
            }

            PropertyChanges {
                target: rectangle2
                color: "#595959"
            }

            PropertyChanges {
                target: rectangle3
                color: "#595959"
            }

            PropertyChanges {
                target: rectangle4
                color: "#595959"
            }

            PropertyChanges {
                target: rectangle5
                color: "#595959"
            }

            PropertyChanges {
                target: progress_item
                visible: true
            }
        },
        State {
            name: "set_time_date"

            PropertyChanges {
                target: bot_image
                visible: false
            }

            PropertyChanges {
                target: instructions_item
                anchors.leftMargin: 50
            }

            PropertyChanges {
                target: title_text
                text: "SET TIME AND DATE"
                lineHeight: 1.2
                font.pixelSize: 28
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: subtitle_text
                text: "Give this printer a time and date."
            }

            PropertyChanges {
                target: continueButton
                label_width: 175
                buttonWidth: 175
                label: "CONTINUE"
                anchors.topMargin: 30
            }

            PropertyChanges {
                target: rectangle2
                color: "#595959"
            }

            PropertyChanges {
                target: rectangle3
                color: "#595959"
            }

            PropertyChanges {
                target: rectangle4
                color: "#595959"
            }

            PropertyChanges {
                target: rectangle5
                color: "#595959"
            }

            PropertyChanges {
                target: progress_item
                visible: true
            }
        },
        State {
            name: "log_in"

            PropertyChanges {
                target: bot_image
                visible: false
            }

            PropertyChanges {
                target: instructions_item
                anchors.leftMargin: 50
            }

            PropertyChanges {
                target: title_text
                text: "LOG IN"
                lineHeight: 1.2
                font.pixelSize: 28
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: subtitle_text
                text: "Log in to add this printer to your MakerBot account."
            }

            PropertyChanges {
                target: continueButton
                label_width: 175
                label: "CONTINUE"
                buttonWidth: 175
                anchors.topMargin: 30
            }

            PropertyChanges {
                target: rectangle2
                color: "#ffffff"
            }

            PropertyChanges {
                target: rectangle3
                color: "#595959"
            }

            PropertyChanges {
                target: rectangle4
                color: "#595959"
            }

            PropertyChanges {
                target: rectangle5
                color: "#595959"
            }

            PropertyChanges {
                target: progress_item
                visible: true
            }

            PropertyChanges {
                target: midStep
                position: 0.334
            }

            PropertyChanges {
                target: endStep
                position: 0.469
            }
        },
        State {
            name: "attach_extruders"

            PropertyChanges {
                target: bot_image
                visible: false
            }

            PropertyChanges {
                target: instructions_item
                anchors.leftMargin: 50
            }

            PropertyChanges {
                target: title_text
                text: {
                    if(!bot.extruderAPresent || !bot.extruderBPresent) {
                        "ATTACH EXTRUDERS"
                    }
                    else {
                        "CALIBRATE EXTRUDERS"
                    }
                }
                lineHeight: 1.2
                font.pixelSize: 28
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: continueButton
                label_width: 175
                label: {
                    if(!bot.extruderAPresent || !bot.extruderBPresent) {
                        "CONTINUE"
                    }
                    else {
                        "CALIBRATE"
                    }
                }
                buttonWidth: {
                    if(!bot.extruderAPresent || !bot.extruderBPresent) {
                        175
                    }
                    else {
                        190
                    }
                }
                anchors.topMargin: 30
            }

            PropertyChanges {
                target: rectangle2
                color: "#ffffff"
            }

            PropertyChanges {
                target: rectangle3
                color: "#ffffff"
            }

            PropertyChanges {
                target: rectangle4
                color: "#595959"
            }

            PropertyChanges {
                target: rectangle5
                color: "#595959"
            }

            PropertyChanges {
                target: progress_item
                visible: true
            }

            PropertyChanges {
                target: midStep
                position: 0.499
            }

            PropertyChanges {
                target: endStep
                position: 0.637
            }

            PropertyChanges {
                target: subtitle_text
                text: {
                    if(!bot.extruderAPresent || !bot.extruderBPresent) {
                        "Follow the on screen steps to attach each extruder."
                    }
                    else {
                        "Calibration enables precise 3d printing. The printer must calibrate\nnew extruders for best print quality."
                    }
                }
            }
        },
        State {
            name: "load_material"

            PropertyChanges {
                target: bot_image
                visible: false
            }

            PropertyChanges {
                target: instructions_item
                anchors.leftMargin: 50
            }

            PropertyChanges {
                target: title_text
                text: "LOAD MATERIAL"
                lineHeight: 1.2
                font.pixelSize: 28
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: continueButton
                label_width: 175
                label: "CONTINUE"
                buttonWidth: 175
                anchors.topMargin: 30
            }

            PropertyChanges {
                target: rectangle2
                color: "#ffffff"
            }

            PropertyChanges {
                target: rectangle3
                color: "#ffffff"
            }

            PropertyChanges {
                target: rectangle4
                color: "#ffffff"
            }

            PropertyChanges {
                target: rectangle5
                color: "#595959"
            }

            PropertyChanges {
                target: progress_item
                visible: true
            }

            PropertyChanges {
                target: midStep
                position: 0.667
            }

            PropertyChanges {
                target: endStep
                position: 0.8
            }

            PropertyChanges {
                target: subtitle_text
                text: "Follow the on screen steps to load material into each bay."
            }
        },
        State {
            name: "test_print"

            PropertyChanges {
                target: bot_image
                visible: false
            }

            PropertyChanges {
                target: instructions_item
                anchors.leftMargin: 50
            }

            PropertyChanges {
                target: title_text
                text: "READY TO PRINT"
                lineHeight: 1.2
                font.pixelSize: 28
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: continueButton
                label_width: 175
                label: "CONTINUE"
                buttonWidth: 175
                anchors.topMargin: 30
            }

            PropertyChanges {
                target: rectangle2
                color: "#ffffff"
            }

            PropertyChanges {
                target: rectangle3
                color: "#ffffff"
            }

            PropertyChanges {
                target: rectangle4
                color: "#ffffff"
            }

            PropertyChanges {
                target: rectangle5
                color: "#ffffff"
            }

            PropertyChanges {
                target: progress_item
                visible: true
            }

            PropertyChanges {
                target: midStep
                position: 0.833
            }

            PropertyChanges {
                target: endStep
                position: 0.968
            }

            PropertyChanges {
                target: subtitle_text
                text: "Start a test print to ensure the printer is set up correctly."
            }
        },
        State {
            name: "setup_complete"

            PropertyChanges {
                target: bot_image
                visible: true
            }

            PropertyChanges {
                target: title_text
                text: "YOUR PRINTER IS\nSUCCESSFULLY SET UP"
                lineHeight: 1.4
                font.pixelSize: 25
                anchors.topMargin: 35
            }

            PropertyChanges {
                target: subtitle_text
                text: ""
                anchors.topMargin: 20
            }

            PropertyChanges {
                target: continueButton
                buttonWidth: 110
                label_width: 110
                label: "DONE"
            }

            PropertyChanges {
                target: instructions_item
                anchors.leftMargin: 400
            }

            PropertyChanges {
                target: progress_item
                visible: false
            }
        }
    ]
}
