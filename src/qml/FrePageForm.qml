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
            text: "WELCOME TO\nYOUR NEW PRINTER"
            font.letterSpacing: 2
            anchors.top: parent.top
            anchors.topMargin: 35
            font.family: "Antennae"
            font.weight: Font.Bold
            font.pixelSize: 22
            lineHeight: 1.35
        }

        Text {
            id: subtitle_text
            color: "#cbcbcb"
            text: ""
            anchors.top: title_text.bottom
            anchors.topMargin: 20
            font.family: "Antennae"
            font.weight: Font.Light
            font.pixelSize: 20
        }

        RoundedButton {
            id: continueButton
            anchors.top: subtitle_text.bottom
            anchors.topMargin: 20
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
                        "WIFI SETUP"
                    }
                }
                font.pixelSize: 28
            }

            PropertyChanges {
                target: subtitle_text
                text: {
                    if(bot.net.interface == "ethernet" ||
                       bot.net.interface == "wifi") {
                        "You already seem to be connected to a network."
                    }
                    else {
                        "Connect to Wi-Fi"
                    }
                }
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
                text: "SOFTWARE UPDATE"
                font.pixelSize: 28
            }

            PropertyChanges {
                target: subtitle_text
                text: "Check for software updates"
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
                font.pixelSize: 28
            }

            PropertyChanges {
                target: subtitle_text
                text: "Name your printer"
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
                font.pixelSize: 28
            }

            PropertyChanges {
                target: subtitle_text
                text: "Log-in to your MakerBot account"
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
                font.pixelSize: 28
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
                        "Now we will guide you through the process of attaching the extruders."
                    }
                    else {
                        "Now we will guide you through the process of calibrating the extruders."
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
                font.pixelSize: 28
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
                text: "Now we will guide you to load material into the extruders."
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
                font.pixelSize: 28
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
                text: "You are now ready to start your first print."
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
