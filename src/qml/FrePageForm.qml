import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import FreStepEnum 1.0
import MachineTypeEnum 1.0

LoggingItem {
    itemName: "FrePage"
    id: main_fre_item
    width: 800
    height: 480
    property alias continueButton: freContentRight.buttonPrimary

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

    ContentRightSide {
        id: freContentRight
        textHeader {
            text: qsTr("WELCOME")
            visible: true
        }

        textBody {
            text: qsTr("Follow these steps to set up your\n%1 Performance 3D Printer.").arg(productName)
            visible: true
        }

        buttonPrimary {
            text: qsTr("BEGIN SETUP")
            visible: true
        }

    }

    Item {
        id: progress_item
        width: 400
        height: 480
        visible: false
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        Rectangle {
            id: progress_rectangle
            width: 2
            height: parent.width
            anchors.left: parent.left
            anchors.leftMargin: 59
            anchors.top: parent.top
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

        ColumnLayout {
            id: progress_circle_layout
            width: 400
            anchors.left: parent.left
            anchors.leftMargin: 53
            anchors.top: parent.top
            anchors.topMargin: 67
            spacing: 60

            FreProgressItem{
                id: setupProgress
                text: qsTr("SET UP")
                Layout.leftMargin: 32
                state: FreProgressItem.Active
            }

            FreProgressItem{
                id: extrudersProgress
                text: qsTr("EXTRUDERS")
                Layout.leftMargin: 32
                state: FreProgressItem.Disabled
            }

            FreProgressItem{
                id: materialProgress
                text: qsTr("MATERIAL")
                Layout.leftMargin: 32
                state: FreProgressItem.Disabled
            }

            FreProgressItem{
                id: printProgress
                text: qsTr("PRINT")
                Layout.leftMargin: 32
                state: FreProgressItem.Disabled
            }

            FreProgressItem{
                id: connectProgress
                text: qsTr("CONNECT")
                Layout.leftMargin: 32
                state: FreProgressItem.Disabled
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

    property bool skipUnpacking: bot.machineType != MachineType.Magma

    onSkipUnpackingChanged: {
        fre.setStepEnable(FreStep.SunflowerUnpacking, !skipUnpacking)
    }

    SunflowerUnpacking {
        id: sunflowerUnpacking
        visible: currentFreStep == FreStep.SunflowerUnpacking
    }

    states: [
        State {
            name: "wifi_setup"

            PropertyChanges {
                target: bot_image
                visible: false
            }

            PropertyChanges {
                target: freContentRight.textHeader
                text: {
                    if(isNetworkConnectionAvailable) {
                        qsTr("CONNECTED TO NETWORK")
                    }
                    else {
                        qsTr("WI-FI SETUP")
                    }
                }
            }

            PropertyChanges {
                target: freContentRight.textBody
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
                target: freContentRight.buttonPrimary
                text: {
                    if(isNetworkConnectionAvailable) {
                        qsTr("CONTINUE")
                    }
                    else {
                        qsTr("CHOOSE NETWORK")
                    }
                }
            }

            PropertyChanges {
                target: setupProgress
                state: FreProgressItem.Active
            }

            PropertyChanges {
                target: extrudersProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: materialProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: printProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: connectProgress
                state: FreProgressItem.Disabled
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
                target: freContentRight.textHeader
                text: qsTr("PRINTER SOFTWARE UPDATE AVAILABLE")
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: freContentRight.textBody
                text: qsTr("Update the %1's printer software for the most up to date\nfeatures and quality.").arg(productName)
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("CONTINUE")
            }

            PropertyChanges {
                target: setupProgress
                state: FreProgressItem.Active
            }

            PropertyChanges {
                target: extrudersProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: materialProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: printProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: connectProgress
                state: FreProgressItem.Disabled
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
                target: freContentRight.textHeader
                text: qsTr("NAME PRINTER")
            }

            PropertyChanges {
                target: freContentRight.textBody
                text: qsTr("Give this printer a name to find it easier.")
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("CONTINUE")
            }

            PropertyChanges {
                target: setupProgress
                state: FreProgressItem.Active
            }

            PropertyChanges {
                target: extrudersProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: materialProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: printProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: connectProgress
                state: FreProgressItem.Disabled
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
                target: freContentRight.textHeader
                text: qsTr("SET THE PRINTER'S CLOCK")
            }

            PropertyChanges {
                target: freContentRight.textBody
                text: qsTr("Input your local date and time for accurate print estimates.")
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("CONTINUE")
            }

            PropertyChanges {
                target: setupProgress
                state: FreProgressItem.Active
            }

            PropertyChanges {
                target: extrudersProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: materialProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: printProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: connectProgress
                state: FreProgressItem.Disabled
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
                target: freContentRight.textHeader
                text: qsTr("ATTACH EXTRUDERS")
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("CONTINUE")
            }

            PropertyChanges {
                target: setupProgress
                state: FreProgressItem.Enabled
            }

            PropertyChanges {
                target: extrudersProgress
                state: FreProgressItem.Active
            }

            PropertyChanges {
                target: materialProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: printProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: connectProgress
                state: FreProgressItem.Disabled
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
                target: freContentRight.textHeader
                text: qsTr("LEVEL BUILD PLATFORM")
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("CONTINUE")
            }

            PropertyChanges {
                target: setupProgress
                state: FreProgressItem.Enabled
            }

            PropertyChanges {
                target: extrudersProgress
                state: FreProgressItem.Active
            }

            PropertyChanges {
                target: materialProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: printProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: connectProgress
                state: FreProgressItem.Disabled
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
                target: freContentRight.textBody
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
                target: freContentRight.textHeader
                text: qsTr("CALIBRATE EXTRUDERS")
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("CONTINUE")
            }

            PropertyChanges {
                target: setupProgress
                state: FreProgressItem.Enabled
            }

            PropertyChanges {
                target: extrudersProgress
                state: FreProgressItem.Active
            }

            PropertyChanges {
                target: materialProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: printProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: connectProgress
                state: FreProgressItem.Disabled
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
                target: freContentRight.textBody
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
                target: freContentRight.textHeader
                text: qsTr("LOAD MATERIAL")
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("CONTINUE")
            }

            PropertyChanges {
                target: setupProgress
                state: FreProgressItem.Enabled
            }

            PropertyChanges {
                target: extrudersProgress
                state: FreProgressItem.Enabled
            }

            PropertyChanges {
                target: materialProgress
                state: FreProgressItem.Active
            }

            PropertyChanges {
                target: printProgress
                state: FreProgressItem.Disabled
            }

            PropertyChanges {
                target: connectProgress
                state: FreProgressItem.Disabled
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
                target: freContentRight.textBody
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
                target: freContentRight.textHeader
                text: qsTr("READY TO PRINT")
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("CONTINUE")
            }

            PropertyChanges {
                target: setupProgress
                state: FreProgressItem.Enabled
            }

            PropertyChanges {
                target: extrudersProgress
                state: FreProgressItem.Enabled
            }

            PropertyChanges {
                target: materialProgress
                state: FreProgressItem.Enabled
            }

            PropertyChanges {
                target: printProgress
                state: FreProgressItem.Active
            }

            PropertyChanges {
                target: connectProgress
                state: FreProgressItem.Disabled
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
                target: freContentRight.textBody
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
                target: setupProgress
                state: FreProgressItem.Enabled
            }

            PropertyChanges {
                target: extrudersProgress
                state: FreProgressItem.Enabled
            }

            PropertyChanges {
                target: materialProgress
                state: FreProgressItem.Enabled
            }

            PropertyChanges {
                target: printProgress
                state: FreProgressItem.Enabled
            }

            PropertyChanges {
                target: connectProgress
                state: FreProgressItem.Active
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
                target: freContentRight.textHeader
                text: qsTr("YOUR PRINTER IS\nSUCCESSFULLY SET UP")
            }

            PropertyChanges {
                target: freContentRight.textBody
                text: qsTr("Log onto MakerBot CloudPrint<br>to prepare your own files for this<br>printer.")
                anchors.topMargin: 20
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("DONE")
            }

            PropertyChanges {
                target: progress_item
                visible: false
            }
        }
    ]
}
