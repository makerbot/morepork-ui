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
    height: 408
    property alias contentLeftSide: contentLeftSide
    property alias contentRightSide: contentRightSide
    property alias cleanExtrudersSequence: cleanExtrudersSequence
    property alias cancelCalibrationPopup: cancelCalibrationPopup
    property alias resumeManualCalibrationPopup: resumeManualCalibrationPopup
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
                processDone()
            }
        }
    }

    property bool chooseMaterial: false

    ContentLeftSide {
        id: contentLeftSide
        image {
            source: "qrc:/img/calibrate_extruders.png"
            visible: true
        }
        processStatusIcon {
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
                processStatusIcon {
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
                target: contentLeftSide.processStatusIcon
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
                target: contentLeftSide.processStatusIcon
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
                source: ("qrc:/img/%1.gif").arg(getImageForPrinter("insert_build_plate"))
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.processStatusIcon
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("INSERT BUILD PLATE")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("Insert the build plate by first placing the rear edge down and sliding it back until it fits snugly and looks aligned.")
                visible: true
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
            name: "secure_build_plate"

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
                source: "qrc:/img/secure_build_plate.png"
                visible: true
            }

            PropertyChanges {
                target: contentLeftSide.animatedImage
                visible: false
            }

            PropertyChanges {
                target: contentLeftSide.processStatusIcon
                visible: false
            }

            PropertyChanges {
                target: contentRightSide.textHeader
                text: qsTr("CONFIRM AND CLOSE DOOR")
                visible: true
            }

            PropertyChanges {
                target: contentRightSide.textBody
                text: qsTr("Check the corners of your build plate to ensure it is secured properly.")+
                      "\n\n"+ qsTr("The build plate should be flush.")

                visible: true
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
            name: "heating_for_hot_cal"
            when: bot.process.type == ProcessType.CalibrationProcess &&
                  bot.process.stateType == ProcessStateType.HeatingForHotCal

            PropertyChanges {
                target: contentLeftSide
                image {
                    visible: false
                }
                processStatusIcon {
                    processStatus: ProcessStatusIcon.Loading
                    visible: true
                }
            }

            PropertyChanges {
                target: contentRightSide
                textHeader {
                    text: qsTr("PREPARING")
                    visible: true
                }
                temperatureStatus {
                    showComponent: TemperatureStatus.ChamberAndHeatedBuildPlate
                    component1.componentName: qsTr("HEATING CHAMBER")
                    component2.componentName: qsTr("HEATING BUILD PLATE")
                    visible: true
                }
                textBody {
                    visible: false
                }
                buttonPrimary {
                    visible: false
                }
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
                target: contentLeftSide.processStatusIcon
                processStatus: ProcessStatusIcon.Loading
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
                target: contentLeftSide.processStatusIcon
                processStatus: ProcessStatusIcon.Success
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
                target: contentLeftSide.processStatusIcon
                processStatus: ProcessStatusIcon.Loading
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
        }
    ]

    CustomPopup {
        popupName: "CancelCalibration"
        id: cancelCalibrationPopup
        popupWidth: 720
        popupHeight: 250
        showTwoButtons: true

        leftButtonText: qsTr("BACK")
        leftButton.onClicked: {
            cancelCalibrationPopup.close()
        }

        rightButtonText: qsTr("CONFIRM")
        rightButton.onClicked: {
            state = "cancelling"
            bot.cancel()
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
        leftButtonText: qsTr("EXIT")
        leftButton.onClicked: {
            resumeManualCalibrationPopup.close()
        }

        rightButtonText: qsTr("START")
        rightButton.onClicked: {
            extruderSettingsSwipeView.swipeToItem(ExtruderSettingsPage.CalibrationProceduresPage)
            calibrationProceduresSwipeView.swipeToItem(CalibrationProceduresPage.ManualZCalibrationPage)
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
