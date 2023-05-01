import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import MachineTypeEnum 1.0

Item {
    id: mainItem
    width: 800
    height: 410

    property bool waitToCoolScreenVisible: false           // the container for both cards
    property bool waitToCoolBuildplaneScreenVisible: false // the buildplane cooldown timer card
    property bool waitToCoolHBPScreenVisible: false        // the HBP cooldown temperature card

    property int timeLeftSeconds: 0
    readonly property int minutesToCountDown: 15

    function initMon() {
        if(bot.machineType == MachineType.Magma) {
            waitToCoolTempItem.startTemperatureWatchdog()
        } else {
            waitToCoolTimeItem.startTimer()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    LoggingItem {
        id: waitToCoolTimeItem
        visible: waitToCoolBuildplaneScreenVisible
        anchors.fill: parent

        Timer {
            id: countdownTimer
            interval: 1000; running: false; repeat: true
            onTriggered: waitToCoolTimeItem.timerUpdate()
        }

        function timerUpdate() {
            time.text = waitToCoolTimeItem.countdown().toString()
        }

        Text {
            id: time
            text: minutesToCountDown+":00"
        }

        function startTimer() {
            timeLeftSeconds = minutesToCountDown * 60;
            countdownTimer.start()
        }

        function countdown() {
            // countdown() is called every second. Timer gets started
            // when startTimer() gets called and stops when timeLeftSeconds
            // decrements to zero.
            timeLeftSeconds--

            if ((timeLeftSeconds <= 0) || (bot.buildplaneCurrentTemp <= printPage.waitToCoolBuildplaneTemperature)) {
                countdownTimer.stop()
                waitToCoolScreenVisible = false
                return "00:00"
            }

            var seconds = timeLeftSeconds;
            var minutes = Math.floor(seconds / 60);

            minutes %= 60;
            seconds %= 60;

            var minutes_str = minutes;
            var seconds_str = seconds;

            // Output proper format for edge cases
            if (minutes <= 0) {
                minutes_str = "00";
            } else if (minutes < 10) {
                minutes_str = "0"+minutes;
            }
            if (seconds == 60) {
                seconds_str = "00";
            } else if (seconds < 10) {
                seconds_str = "0"+seconds;
            }

            return minutes_str + ":" + seconds_str;
        }

        ContentLeftSide {
            id: timeContentLeftSide
            image {
                source: "qrc:/img/error.png"
                visible: true
            }
            loadingIcon {
                visible: false
            }
            visible: true
        }

        ContentRightSide {
            id: timeContentRightSide
            textHeader {
                text: qsTr("BUILD PLATE\nNEEDS TO COOL")
                visible: true
            }
            textBody {
                text: qsTr("The build plane temperature is<br>at <b>%1 C.</b>").arg(bot.buildplaneCurrentTemp) +
                      qsTr(" Please wait <b>%2</b><br>minutes before removing the build<br>plate from the chamber.").arg(time.text)
                visible: true
            }
            temperatureStatus {
                showExtruder: TemperatureStatus.Extruder.BuildplaneCool
                visible: true
            }
            buttonPrimary {
                text: qsTr("ACKNOWLEDGE")
                visible: true
                onClicked: {
                    countdownTimer.stop()
                    waitToCoolScreenVisible = false
                }
            }
            visible: true
        }
    }

    LoggingItem {
        id: waitToCoolTempItem
        visible: waitToCoolHBPScreenVisible
        anchors.fill: parent

        Timer {
            id: temperatureWatchdogTimer
            interval: 5000; running: false; repeat: true
            onTriggered: waitToCoolTempItem.temperatureUpdate()
        }

        function startTemperatureWatchdog() {
            temperatureWatchdogTimer.start()
        }

        function temperatureUpdate() {
            if (bot.hbpCurrentTemp <= printPage.waitToCoolHBPTemperature) {
                temperatureWatchdogTimer.stop()
                waitToCoolScreenVisible = false
            }
        }

        ContentLeftSide {
            id: tempContentLeftSide
            image {
                source: "qrc:/img/error.png"
                visible: true
            }
            loadingIcon {
                visible: false
            }
            visible: true
        }

        ContentRightSide {
            id: tempContentRightSide
            textHeader {
                text: qsTr("WARNING")
                visible: true
            }
            textBody {
                text: qsTr("PLEASE WAIT FOR BUILD PLATE TO COOL BEFORE REMOVING.")
                visible: true
            }
            temperatureStatus {
                showExtruder: TemperatureStatus.Extruder.HBPCool
                visible: true
            }
            buttonPrimary {
                text: qsTr("Confirm")
                visible: true
                onClicked: {
                    temperatureWatchdogTimer.stop()
                    waitToCoolScreenVisible = false
                }
            }
            visible: true
        }

    }
}
