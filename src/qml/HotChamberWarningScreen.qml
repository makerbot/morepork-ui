import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import MachineTypeEnum 1.0
import ProcessTypeEnum 1.0
import ProcessStateTypeEnum 1.0

LoggingItem {
    id: hotChamberWarning
    width: 800
    height: 480

    // Make this overlay screen opaque to touches.
    MouseArea {
        id: emptyMouseArea
        z: -1
        anchors.fill: parent
    }

    enum WaitType {
        TimedCheck,
        TemperatureCheck
    }

    property int waitType: {
        if(bot.machineType == MachineType.Magma) {
            HotChamberWarningScreen.TemperatureCheck
        } else {
            HotChamberWarningScreen.TimedCheck
        }
    }

    property bool temperatureCheckOverridden: true
    property bool timedCheckComplete: true
    property var timedCheckEndTime: new Date()
    property string timedCheckTimeRemaining

    readonly property int buildplaneTemperatureThreshold: 70
    readonly property int hbpTemperatureThreshold: 50

    property bool isProcessDone: (bot.process.type == ProcessType.Print ||
                                 bot.process.type == ProcessType.CalibrationProcess) &&
                                 bot.process.stateType == ProcessStateType.CleaningUp ||
                                 bot.process.stateType == ProcessStateType.Completed ||
                                 bot.process.stateType == ProcessStateType.Failed ||
                                 bot.process.stateType == ProcessStateType.Cancelling

    onIsProcessDoneChanged: {
        if(isProcessDone) {
            if(waitType == HotChamberWarningScreen.WaitType.TemperatureCheck) {
                temperatureCheckOverridden = false
            } else {
                timedCheckComplete = false
                startTimedCheck()
            }
        } else {
            if(!visible) {
                timedCheckCountdown.stop()
                timedCheckComplete = true
                temperatureCheckOverridden = true
            }
        }
    }

    visible: {
        if(waitType == HotChamberWarningScreen.WaitType.TemperatureCheck) {
            (bot.hbpCurrentTemp > hbpTemperatureThreshold) && !temperatureCheckOverridden
        } else {
            (bot.buildplaneCurrentTemp > buildplaneTemperatureThreshold) && !timedCheckComplete
        }
    }

    function startTimedCheck() {
        var t = new Date()
        t.setMinutes(t.getMinutes() + 15)
        timedCheckEndTime = t
        timedCheckCountdown.start()
    }

    Timer {
        id: timedCheckCountdown
        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date()
            if (timedCheckEndTime > now) {
                var dt = new Date(timedCheckEndTime - now)
                var s = dt.getSeconds()
                timedCheckTimeRemaining = dt.getMinutes() + ":" + (s >= 10 ? s : "0" + s)
            } else {
                timedCheckCountdown.stop()
                timedCheckComplete = true
            }
        }
    }

    ContentLeftSide {
        id: contentLeftSide
        image {
            source: "qrc:/img/error.png"
            visible: true
        }
        loadingIcon {
            visible: false
        }
        visible: true
        anchors.verticalCenter: parent.verticalCenter
    }

    ContentRightSide {
        id: contentRightSide
        buttonPrimary {
            onClicked: {
                if(hotChamberWarning.state == "temperature_check") {
                    temperatureCheckOverridden = true
                } else {
                    timedCheckCountdown.stop()
                    timedCheckComplete = true
                }
            }
        }
        anchors.verticalCenter: parent.verticalCenter
        visible: true
    }

    states: [
        State {
            name: "temperature_check"
            when: waitType == HotChamberWarningScreen.WaitType.TemperatureCheck

            PropertyChanges {
                target: contentRightSide
                textHeader {
                    text: qsTr("WARNING")
                    visible: true
                }
                textBody {
                    text: qsTr("PLEASE WAIT FOR BUILD PLATE TO COOL BEFORE REMOVING.")
                    visible: true
                }
                temperatureStatus {
                    showComponent: TemperatureStatus.Generic
                    component1 {
                        showComponentName: false
                        customCurrentTemperature: bot.hbpCurrentTemp
                        customTargetTemperature: hbpTemperatureThreshold
                    }
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("CONFIRM")
                    visible: true
                }
                visible: true
            }
        },

        State {
            name: "timed_check"
            when: waitType == HotChamberWarningScreen.WaitType.TimedCheck

            PropertyChanges {
                target: contentRightSide
                textHeader {
                    text: qsTr("BUILD PLATE NEEDS TO COOL")
                    visible: true
                }
                textBody {
                    text: qsTr("The build plane temperature is at %1.").arg("<b>"+bot.buildplaneCurrentTemp+" C</b>") + "\n\n" +
                          qsTr("Please wait %1 minutes before removing the build plate from the chamber.").arg("<b>"+timedCheckTimeRemaining+"</b>")
                    visible: true
                }
                buttonPrimary {
                    text: qsTr("ACKNOWLEDGE")
                    visible: true
                }
                visible: true
            }
        }
    ]
}
