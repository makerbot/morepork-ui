import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: mainItem
    width: 800
    height: 440

    property alias continueButton: continueButton
    property int timeLeftSeconds: 0
    readonly property int minutesToCountDown: 15
    property bool waitToCoolChamberScreenVisible: false

    Timer {
        id: countdownTimer
        interval: 1000; running: false; repeat: true
        onTriggered: time.text = countdown().toString()
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
        //countdown() is called every second. Timer gets started
        // when startTimer() gets called and stops when timeLeftSeconds
        // decrements to zero.

        if (timeLeftSeconds == 0) {
            countdownTimer.stop()
            waitToCoolChamberScreenVisible = false
            return "00:00"
        }

        timeLeftSeconds--;

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

    Rectangle {
        anchors.fill: parent
        color: "#000000"
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
