import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import FreStepEnum 1.0

Item {
    anchors.fill: parent

    property alias setTimeButton: setTimeButton
    property alias meridianTumbler: meridianTumbler
    property alias hoursTumbler: hoursTumbler
    property alias minutesTumbler: minutesTumbler

    property string systemTime: bot.systemTime
    property string displayTime
    property string displayDate
    onSystemTimeChanged: {
        formatTime()
    }

    function formatTime() {
        if (systemTime.indexOf(" ") < 0) {
            // not ready for parsing; do nothing
            return
        }
        // 2018-09-10 18:04:16
        var time_elements = systemTime.split(" ")
        var date_element = time_elements[0] // 2018-09-10
        displayDate = date_element
        var time_element = time_elements[1] // 18:04:16
        displayTime = time_element
        var time_split = time_element.split(":")
        var current_hour = time_split[0] // 18
        var current_minute = time_split[1] // 04
        var current_second = time_split[2] // 16
        var date_split = date_element.split("-")
        var current_year = date_split[0] // 2018
        var current_month = date_split[1] // 09
        var current_day = date_split[2] //10

        meridianTumbler.currentIndex = ((current_hour >= 12) ? 1 : 0)
        current_hour %= 12
        current_hour = (current_hour == 0 ? 12 : current_hour)
        hoursTumbler.currentIndex = current_hour - 1
        minutesTumbler.currentIndex = current_minute
    }

    function formatText(count, modelData) {
        var data = count === 12 ? modelData + 1 : modelData
        return ((data.toString().length < 2) ? "0" + data : data)
    }

    function setTime() {
        var current_time = bot.systemTime
        var current_date = current_time.split(' ')

        var set_hour = hoursTumbler.currentIndex + 1
        if(meridianTumbler.currentIndex == 1 && set_hour != 12) {
            set_hour = set_hour + 12
        }
        else if(meridianTumbler.currentIndex == 0 && set_hour == 12) {
            set_hour = "00"
        }

        if(set_hour.toString().length < 2) {
            set_hour = "0" + set_hour
        }
        var set_minute = minutesTumbler.currentIndex
        if(set_minute.toString().length < 2) {
            set_minute = "0" + set_minute
        }

        current_time = current_date[0] + " " + set_hour + ":" + set_minute + ":" + "00"

        bot.setSystemTime(current_time)
    }

    Component {
        id: delegateComponent
        Text {
            text: formatText(Tumbler.tumbler.count, modelData)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: {
                if(Tumbler.tumbler.currentItem.text === text &&
                   Tumbler.tumbler.count > 2) {
                    100
                } else {
                    64
                }
            }
            font.weight: Font.Light
            font.family: defaultFont.name
            color: Tumbler.tumbler.currentItem.text === text ? "#ffffff" : "#B2B2B2"

            Behavior on font.pixelSize {
                NumberAnimation {
                    duration: 50
                }
            }
        }
    }

    Item {
        anchors.left: parent.left
        anchors.leftMargin: 40
        anchors.right: setTimeButton.left
        anchors.bottom: parent.bottom
        anchors.top: parent.top

        VerticalTumbler {
            id: hoursTumbler
            width: 140
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            visibleItemCount: 3
            model: 12
            delegate: delegateComponent
        }

        Text {
            id: timeSeparator
            color: "#ffffff"
            text: ":"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.left: hoursTumbler.right
            anchors.leftMargin: 40
            anchors.verticalCenter: parent.verticalCenter
            font.family: defaultFont.name
            font.pixelSize: 100
        }

        VerticalTumbler {
            id: minutesTumbler
            width: 140
            height: parent.height
            anchors.left: timeSeparator.right
            anchors.leftMargin: 40
            anchors.verticalCenter: parent.verticalCenter
            visibleItemCount: 3
            model: 60
            delegate: delegateComponent
        }

        VerticalTumbler {
            id: meridianTumbler
            width: 120
            height: parent.height*1.6
            anchors.left: minutesTumbler.right
            anchors.leftMargin: 40
            anchors.verticalCenter: parent.verticalCenter
            model: ["AM", "PM"]
            delegate: delegateComponent
        }
    }

    ButtonRectanglePrimary {
        id: setTimeButton
        width: 120
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.verticalCenter: parent.verticalCenter
        text: qsTr("SAVE")

        onClicked: {
            setTime()
            if(inFreStep) {
                timeSwipeView.swipeToItem(TimePage.SetDate)
                settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                mainSwipeView.swipeToItem(MoreporkUI.BasePage)
                fre.gotoNextStep(currentFreStep)
            }
            else {
                timeSwipeView.swipeToItem(TimePage.BasePage)
            }
        }
        enabled: {
            !hoursTumbler.moving && !minutesTumbler.moving && !meridianTumbler.moving
        }
    }
}
