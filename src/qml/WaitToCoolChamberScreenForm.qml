import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import MachineTypeEnum 1.0

Item {
    id: mainItem
    width: 800
    height: 410

    property alias continueButton: continueButton
    property bool waitToCoolChamberScreenVisible: false
    property bool displayMagmaItem: bot.machineType == MachineType.Magma

    property int timeLeftSeconds: 0
    readonly property int minutesToCountDown: { (bot.machineType == MachineType.Magma) ? 240 : 15 }

    // Timer is now dual-use, depending on hardware configuration, such that on the sunflower spec,
    // the timer will now check on the temperature every 5-ish seconds over 4 hours for the chamber
    // temperature to have fallen below 50 deg C, while still retaining the existing functionality
    // of waiting a static 15 min to allow for cooling of the "hot" chamber contents.
    Timer {
        id: countdownTimer
        interval: { ((bot.machineType == MachineType.Magma) ? 5000 : 1000) }
        running: false; repeat: true
        onTriggered: timerUpdate()
    }

    function timerUpdate() {
        if (bot.machineType == MachineType.Magma) {
            countdown()
        } else {
            time.text = countdown().toString()
        }
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

        timeLeftSeconds -= (countdownTimer.interval / 1000) // interval is in milliseconds

        if ((bot.machineType == MachineType.Magma) && (bot.buildplaneCurrentTemp < printPage.waitToCoolTemperature)) {
            timeLeftSeconds *= -1
        }

        if (timeLeftSeconds <= 0) {
            countdownTimer.stop()
            waitToCoolChamberScreenVisible = false
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

    LoggingItem {
        id: waitToCoolTimeItem
        visible: !displayMagmaItem
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: "#bf000000"
            border.width: 1
            border.color: "#00ff00"
        }

        Image {
            id: image
            width: sourceSize.width
            height: sourceSize.height
            anchors.horizontalCenterOffset: -200
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/img/error.png"
        }

        ColumnLayout {
            id: instructionsContainer
            height: 240
            anchors.right: parent.right
            anchors.horizontalCenterOffset: -100
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: title_text
                color: "#cbcbcb"
                text: qsTr("BUILD PLATE\nNEEDS TO COOL")
                font.letterSpacing: 1
                font.wordSpacing: 3
                font.family: defaultFont.name
                font.pixelSize: 32
                font.weight: Font.Bold
                antialiasing: false
                smooth: false
                bottomPadding: 5
            }

            Text {
                id: description_text
                color: "#cbcbcb"
                text: qsTr("The build plane temperature is<br>at <b>%1 C.</b>").arg(bot.buildplaneCurrentTemp) +
                      qsTr(" Please wait <b>%2</b><br>minutes before removing the build<br>plate from the chamber.").arg(time.text)
                font.family: defaultFont.name
                font.pixelSize: 20
                font.weight: Font.Light
                rightPadding: 80
                lineHeight: 1.3
                antialiasing: false
                smooth: false
                bottomPadding: 5
            }

            RoundedButton {
                id: continueButton
                buttonWidth: 200
                buttonHeight: 50
                label_width: 200
                label_size: 20
                label: qsTr("ACKNOWLEDGE")
            }
        }
    }

    LoggingItem {
        id: waitToCoolTempItem
        visible: displayMagmaItem

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
        }

        ContentRightSide {
            id: contentRightSide
            textHeader {
                text: qsTr("WARNING")
                visible: true
            }
            textBody {
                text: qsTr("PLEASE WAIT FOR BUILD PLATE TO COOL BEFORE REMOVING.")
                visible: true
            }
            temperatureStatus {
                showExtruder: TemperatureStatus.Extruder.ChamberCool
                visible: true
            }
            buttonPrimary {
                text: qsTr("Confirm")
                visible: true
                onClicked: {
                    waitToCoolChamberScreenVisible = false
                }
            }
            visible: true
        }

    }
}
