import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import FreStepEnum 1.0
import MachineTypeEnum 1.0

LoggingItem {
    itemName: "FrePage"
    id: main_fre_item
    height: 480
    width: 800
    property alias continueButton: freContentRight.buttonPrimary
    property alias skipButton: freContentRight.buttonSecondary1
    property bool skipMagmaSteps: bot.machineType != MachineType.Magma
    property alias helpButton: freContentRight.help

    FreChooseLanguagePage {
        id: fre_choose_language
        z: 1
        visible: (currentFreStep == FreStep.StartSetLanguage)
    }

    Item {
        id: progress_item
        width: 400
        height: 480
        visible: !(currentFreStep == FreStep.StartSetLanguage) &&
                 !(currentFreStep == FreStep.SetupComplete)
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
                text: qsTr("SETUP")
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

    /*RowLayout {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10*/

        ContentLeftSide {
            id: freContentLeft
            anchors.verticalCenter: parent.verticalCenter
            loadingIcon {
                icon_image: LoadingIcon.Success
            }
            image {
                source: "qrc:/img/fre_help_qr_code.png"
            }
            visible: false
        }

        ContentRightSide {
            id: freContentRight
            anchors.verticalCenter: parent.verticalCenter

            textHeader {
                text: qsTr("WELCOME")
                visible: true
            }

            textBody {
                text: qsTr("The following procedure will help you set up your %1.").arg(productName.toUpperCase())
                visible: true
            }

            textBody1 {
                text: qsTr("")
                visible: false
            }

            buttonPrimary {
                text: qsTr("BEGIN SETUP")
                visible: true
            }

            buttonSecondary1 {
                text: (currentFreStep == FreStep.Welcome ||
                       currentFreStep == FreStep.SunflowerSetupGuide) ?
                          qsTr("< BACK") : qsTr("SKIP")
                visible: true
            }
        }
   // }

    onSkipMagmaStepsChanged: {
        fre.setStepEnable(FreStep.SunflowerSetupGuide, !skipMagmaSteps)
        fre.setStepEnable(FreStep.SunflowerUnpacking, !skipMagmaSteps)
        fre.setStepEnable(FreStep.MaterialCaseSetup, !skipMagmaSteps)
    }

    SunflowerUnpacking {
        id: sunflowerUnpacking
        visible: currentFreStep == FreStep.SunflowerUnpacking
    }

    states: [
        State {
            name: "wifi_setup"

            PropertyChanges {
                target: freContentLeft
                image.visible: false
                loadingIcon.visible: false
            }

            PropertyChanges {
                target: freContentRight.textHeader
                text: qsTr("WIFI AND NETWORK")
            }

            PropertyChanges {
                target: freContentRight.textBody
                text: qsTr("For the best experience using METHOD printers, "+
                           "it is recommended that you connect to a wi-fi network "+
                           "or plug in an ethernet cable.")
            }

            PropertyChanges {
                target: freContentRight.textBody1
                visible: false
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: {
                    if(isNetworkConnectionAvailable) {
                        qsTr("CONTINUE")
                    }
                    else {
                        qsTr("CONNECT TO NETWORK")
                    }
                }
            }

            PropertyChanges {
                target: freContentRight.buttonSecondary1
                text: qsTr("OFFLINE SET UP")
                enabled: !isNetworkConnectionAvailable
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
                target: freContentLeft
                image.visible: false
                loadingIcon.visible: false
            }

            PropertyChanges {
                target: freContentRight.textHeader
                text: qsTr("FIRMWARE UPDATE")
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: freContentRight.textBody
                text: qsTr("The latest firmware update is recommended to improve "+
                           "machine reliablility and print quality.")
            }

            PropertyChanges {
                target: freContentRight.textBody1
                visible: false
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("START")
            }

            PropertyChanges {
                target: freContentRight.buttonSecondary1
                visible: true
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
                target: freContentLeft
                image.visible: false
                loadingIcon.visible: false
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
                target: freContentRight.textBody1
                visible: false
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("NEXT")
            }

            PropertyChanges {
                target: freContentRight.buttonSecondary1
                visible: true
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
                target: freContentLeft
                image.visible: false
                loadingIcon.visible: false
            }

            PropertyChanges {
                target: freContentRight.textHeader
                text: qsTr("ATTACH EXTRUDERS")
            }

            PropertyChanges {
                target: freContentRight.textBody
                text: qsTr("This procedure will guide you through the process of attaching your extruders.")
            }

            PropertyChanges {
                target: freContentRight.textBody1
                visible: false
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("CONTINUE")
            }

            PropertyChanges {
                target: freContentRight.buttonSecondary1
                visible: false
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
        },
        State {
            name: "level_build_plate"

            PropertyChanges {
                target: freContentRight.textHeader
                text: qsTr("ASSISTED LEVELING")
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("START")
            }
            PropertyChanges {
                target: freContentRight
                style: ContentRightSideForm.ButtonWithHelp
            }

            PropertyChanges {
                target: freContentRight.buttonSecondary1
                visible: true
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
                text: qsTr("Assisted leveling will check your build platform and prompt you to make any adjustments.")
            }
        },
        State {
            name: "calibrate_extruders"

            PropertyChanges {
                target: freContentLeft
                image.visible: false
                loadingIcon.visible: false
            }

            PropertyChanges {
                target: freContentRight.textHeader
                text: qsTr("CALIBRATE EXTRUDERS")
            }

            PropertyChanges {
                target: freContentRight.textBody
                text: qsTr("Calibration enables precise 3d printing. The printer must calibrate\nnew extruders for best print quality.")
            }

            PropertyChanges {
                target: freContentRight.textBody1
                visible: false
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("CONTINUE")
            }

            PropertyChanges {
                target: freContentRight.buttonSecondary1
                visible: false
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
        },
        State {
            name: "material_case_setup"

            PropertyChanges {
                target: freContentRight.textHeader
                text: qsTr("MATERIAL CASE SET UP")
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: freContentRight.textBody
                text: qsTr("Follow the on screen steps to set up the material case and load materials.")
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("START")
            }

            PropertyChanges {
                target: freContentRight.buttonSecondary1
                visible: true
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
        },
        State {
            name: "load_material"

            PropertyChanges {
                target: freContentLeft
                image.visible: false
                loadingIcon.visible: false
            }

            PropertyChanges {
                target: freContentRight.textHeader
                text: qsTr("LOAD MATERIAL")
                anchors.topMargin: 25
            }

            PropertyChanges {
                target: freContentRight.textBody
                text: qsTr("Follow the on screen steps to load material into each bay.")
            }

            PropertyChanges {
                target: freContentRight.textBody1
                visible: false
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("CONTINUE")
            }

            PropertyChanges {
                target: freContentRight.buttonSecondary1
                visible: true
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
        },
        State {
            name: "test_print"

            PropertyChanges {
                target: freContentLeft
                image.visible: false
                loadingIcon.visible: false
            }

            PropertyChanges {
                target: freContentRight.textHeader
                text: qsTr("READY TO PRINT")
            }

            PropertyChanges {
                target: freContentRight.textBody
                text: qsTr("Start a test print to ensure the printer is set up correctly.")
            }

            PropertyChanges {
                target: freContentRight.textBody1
                visible: false
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("CONTINUE")
            }

            PropertyChanges {
                target: freContentRight.buttonSecondary1
                visible: true
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
        },
        State {
            name: "name_printer"

            PropertyChanges {
                target: freContentLeft
                image.visible: false
                loadingIcon.visible: false
            }

            PropertyChanges {
                target: freContentRight.textHeader
                text: qsTr("PRINTER NAME:\n\n") + bot.name
            }

            PropertyChanges {
                target: freContentRight.textBody
                text: qsTr("You can change the printer name at any point in the system settings.")
            }

            PropertyChanges {
                target: freContentRight.textBody1
                visible: false
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("NEXT")
            }

            PropertyChanges {
                target: freContentRight.buttonSecondary1
                text: qsTr("CHANGE PRINTER NAME")
                visible: true
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
            name: "magma_setup_guide1"

            PropertyChanges {
                target: freContentLeft
                image.source: "qrc:/img/fre_help_qr_code.png"
                image.visible: true
                loadingIcon.visible: false
                visible: true
            }

            PropertyChanges {
                target: freContentRight.textHeader
                text: qsTr("METHOD XL SETUP GUIDE")
            }

            PropertyChanges {
                target: freContentRight.textBody
                text: qsTr("We highly recommend following along for additional "+
                           "instructions + videos to guide you through your set up.")
            }

            PropertyChanges {
                target: freContentRight.textBody1
                visible: false
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("NEXT")
            }

            PropertyChanges {
                target: freContentRight.buttonSecondary1
                visible: true
            }

            PropertyChanges {
                target: progress_item
                visible: false
            }
        },
        State {
            name: "magma_setup_guide2"

            PropertyChanges {
                target: freContentLeft
                image.source: "qrc:/img/remove_upper_material.png"
                image.visible: true
                loadingIcon.visible: false
                visible: true
            }

            PropertyChanges {
                target: freContentRight.textHeader
                visible: false
            }

            PropertyChanges {
                target: freContentRight.textBody
                text: qsTr("Box 1 contains your material case and can be removed now.")
            }


            PropertyChanges {
                target: freContentRight.textBody1
                text: qsTr("Box 2 contains extruders and tools. The onboarding will "+
                           "guide you to remove that later in the process.")
                font.weight: Font.Normal
                visible: true
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("NEXT")
            }

            PropertyChanges {
                target: freContentRight.buttonSecondary1
                visible: true
            }

            PropertyChanges {
                target: progress_item
                visible: false
            }
        },

        State {
            name: "log_in"

            PropertyChanges {
                target: freContentLeft
                image.visible: false
                loadingIcon.visible: false
            }

            PropertyChanges {
                target: freContentRight.textHeader
                text: qsTr("CONNECT")
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("CONNECT ACCOUNT")
            }

            PropertyChanges {
                target: freContentRight.textBody
                text: qsTr("CloudPrint is a browser-based app that enables you to prepare & send files directly to your printer.\n\nCreate a MakerBot account and connect your printer to CloudPrint at:")
            }

            PropertyChanges {
                target: freContentRight.textBody1
                text: qsTr("cloudprint.makerbot.com")

            }

            PropertyChanges {
                target: freContentRight.buttonSecondary1
                visible: true
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
                target: freContentLeft
                image.visible: false
                loadingIcon.visible: true
                visible: true
            }

            PropertyChanges {
                target: freContentRight.textHeader
                text: qsTr("SETUP COMPLETE")
            }

            PropertyChanges {
                target: freContentRight.textBody
                text: qsTr("To learn how to prepare and send files to your printer, follow the instructions at:")
                anchors.topMargin: 20
            }

            PropertyChanges {
                target: freContentRight.textBody1
                font.weight: Font.Bold
                text: qsTr("cloudprint.makerbot.com")
                visible: true
            }

            PropertyChanges {
                target: freContentRight.buttonPrimary
                text: qsTr("FINISH")
            }


            PropertyChanges {
                target: freContentRight.buttonSecondary1
                visible: false
            }

            PropertyChanges {
                target: progress_item
                visible: false
            }
        }
    ]
}
