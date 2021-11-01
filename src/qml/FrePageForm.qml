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
        visible: {
            // Login step has it's own flow within the FRE unlike the
            // other steps which use the same template.
            currentFreStep != FreStep.LoginMbAccount
        }
        anchors.left: parent.left
        anchors.leftMargin: 400
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: title_text
            color: "#ffffff"
            text: qsTr("WELCOME")
            font.letterSpacing: 2
            anchors.top: parent.top
            anchors.topMargin: 35
            font.family: defaultFont.name
            font.weight: Font.Bold
            font.pixelSize: 28
            lineHeight: 1.2
        }

        Text {
            id: subtitle_text
            color: "#cbcbcb"
            text: qsTr("Follow these steps to set up your\n%1 Performance 3D Printer.").arg(productName)
            anchors.top: title_text.bottom
            anchors.topMargin: 20
            font.family: defaultFont.name
            font.weight: Font.Light
            font.pixelSize: 20
            lineHeight: 1.3
        }

        RoundedButton {
            id: continueButton
            anchors.top: subtitle_text.bottom
            anchors.topMargin: 30
            label: qsTr("BEGIN SETUP")
            buttonHeight: 50
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
                    text: qsTr("SET UP")
                    font.letterSpacing: 2
                    anchors.top: parent.bottom
                    anchors.topMargin: 18
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: defaultFont.name
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
                    text: qsTr("EXTRUDERS")
                    font.letterSpacing: 2
                    anchors.top: parent.bottom
                    anchors.topMargin: 18
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: defaultFont.name
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
                    text: qsTr("MATERIAL")
                    font.letterSpacing: 2
                    anchors.top: parent.bottom
                    anchors.topMargin: 18
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: defaultFont.name
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
                    text: qsTr("PRINT")
                    font.letterSpacing: 2
                    anchors.top: parent.bottom
                    anchors.topMargin: 18
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: defaultFont.name
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
                    text: qsTr("CONNECT")
                    font.letterSpacing: 2
                    anchors.top: parent.bottom
                    anchors.topMargin: 18
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: defaultFont.name
                    font.weight: Font.Bold
                    font.pixelSize: 14
                }
            }
        }
    }

    FreAuthorizeWithCode {
        id: authorizeWithCode
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        visible: currentFreStep == FreStep.LoginMbAccount
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
                    if(isNetworkConnectionAvailable) {
                        qsTr("CONNECTED TO NETWORK")
                    }
                    else {
                        qsTr("WI-FI SETUP")
                    }
                }
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: subtitle_text
                text: {
                    if(isNetworkConnectionAvailable) {
                        qsTr("You seem to be connected to a network.")
                    }
                    else {
                        qsTr("Connect to the internet to enable remote monitoring and\nprinting from any connected device.")
                    }
                }
            }

            PropertyChanges {
                target: continueButton
                label: {
                    if(isNetworkConnectionAvailable) {
                        qsTr("CONTINUE")
                    }
                    else {
                        qsTr("CHOOSE NETWORK")
                    }
                }
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
                text: qsTr("PRINTER SOFTWARE UPDATE AVAILABLE")
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: subtitle_text
                text: qsTr("Update the %1's printer software for the most up to date\nfeatures and quality.").arg(productName)
            }

            PropertyChanges {
                target: continueButton
                label: qsTr("CONTINUE")
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
                text: qsTr("NAME PRINTER")
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: subtitle_text
                text: qsTr("Give this printer a name to find it easier.")
            }

            PropertyChanges {
                target: continueButton
                label: qsTr("CONTINUE")
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
                text: qsTr("SET THE PRINTER'S CLOCK")
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: subtitle_text
                text: qsTr("Input your local date and time for accurate print estimates.")
            }

            PropertyChanges {
                target: continueButton
                label: qsTr("CONTINUE")
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
                text: qsTr("ATTACH EXTRUDERS")
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: continueButton
                label: qsTr("CONTINUE")
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

            PropertyChanges {
                target: subtitle_text
                text: qsTr("Follow the on screen steps to attach each extruder.")
            }
        },
        State {
            name: "level_build_plate"

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
                text: qsTr("LEVEL BUILD PLATFORM")
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: continueButton
                label: qsTr("CONTINUE")
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

            PropertyChanges {
                target: subtitle_text
                text: qsTr("Follow the on-screen steps to level the build plate.")
            }
        },
        State {
            name: "calibrate_extruders"

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
                text: qsTr("CALIBRATE EXTRUDERS")
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: continueButton
                label: qsTr("CONTINUE")
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

            PropertyChanges {
                target: subtitle_text
                text: qsTr("Calibration enables precise 3d printing. The printer must calibrate\nnew extruders for best print quality.")
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
                text: qsTr("LOAD MATERIAL")
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: continueButton
                label: qsTr("CONTINUE")
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
                text: qsTr("Follow the on screen steps to load material into each bay.")
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
                text: qsTr("READY TO PRINT")
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: continueButton
                label: qsTr("CONTINUE")
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
                text: qsTr("Start a test print to ensure the printer is set up correctly.")
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
        },
        State {
            name: "setup_complete"

            PropertyChanges {
                target: bot_image
                visible: true
            }

            PropertyChanges {
                target: title_text
                text: qsTr("YOUR PRINTER IS\nSUCCESSFULLY SET UP")
                lineHeight: 1.4
                font.pixelSize: 25
                anchors.topMargin: 35
            }

            PropertyChanges {
                target: subtitle_text
                text: qsTr("Log onto MakerBot CloudPrint<br>to prepare your own files for this<br>printer.")
                anchors.topMargin: 20
            }

            PropertyChanges {
                target: continueButton
                label: qsTr("DONE")
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
