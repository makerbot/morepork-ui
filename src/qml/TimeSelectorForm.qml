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
        var time_element = time_elements[1] // 18:04:16
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
        return ((count > 12 && data.toString().length < 2) ? "0" + data : data)
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
            opacity: 1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Tumbler.tumbler.count > 2 ? 175 : 60
            font.weight: Font.Light
            font.family: defaultFont.name
            color: "#ffffff"
        }
    }

    Row {
        id: row
        spacing: 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Tumbler {
            id: hoursTumbler
            width: 250
            height: 500
            anchors.verticalCenter: parent.verticalCenter
            visibleItemCount: 3
            model: 12
            delegate: delegateComponent
        }

        Text {
            id: time_separator_text
            width: 50
            color: "#ffffff"
            text: ":"
            leftPadding: -15
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: parent.verticalCenter
            font.family: defaultFont.name
            font.pixelSize: 135
        }

        Tumbler {
            id: minutesTumbler
            width: 250
            height: 500
            anchors.verticalCenter: parent.verticalCenter
            visibleItemCount: 3
            model: 60
            delegate: delegateComponent
        }

        Text {
            id: spacingItem
            width: 50
            anchors.verticalCenter: parent.verticalCenter
        }

        Tumbler {
            id: meridianTumbler
            width: 100
            height: 640
            anchors.verticalCenter: parent.verticalCenter
            model: ["AM", "PM"]
            delegate: delegateComponent
        }
    }

    Item {
        id: overlayItem
        width: 500
        height: 175
        anchors.left: parent.left
        anchors.leftMargin: 75
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -10

        Rectangle {
            id: topLeftLine
            width: 200
            height: 1
            color: "#ffffff"
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
        }

        Rectangle {
            id: topRightLine
            width: 200
            height: 1
            color: "#ffffff"
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
        }

        Rectangle {
            id: bottomLeftLine
            width: 200
            height: 1
            color: "#ffffff"
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
        }

        Rectangle {
            id: bottomRightLine
            width: 200
            height: 1
            color: "#ffffff"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
        }

        Rectangle {
            id: topFadeItem
            width: 800
            height: 150
            anchors.horizontalCenterOffset: 20
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "#000000"
                }

                GradientStop {
                    position: 1
                    color: "#00000000"
                }
            }
            anchors.bottom: parent.top
            anchors.bottomMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            id: bottomFadeItem
            width: 800
            height: 150
            anchors.horizontalCenterOffset: 20
            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "#00000000"
                }

                GradientStop {
                    position: 1
                    color: "#000000"
                }
            }
            anchors.top: parent.bottom
            anchors.topMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter
        }

    }

    RoundedButton {
        id: setTimeButton
        buttonHeight: 50
        buttonWidth: 120
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        label: qsTr("DONE")
        opacity: {
            button_mouseArea.enabled ? 1.0 : 0.1
        }

        Behavior on opacity {
            OpacityAnimator {
                duration: 100
            }
        }

        button_mouseArea {
            onClicked: {
                setTime()
                if(inFreStep) {
                    timeSwipeView.swipeToItem(TimePage.SetDate)
                    settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                    mainSwipeView.swipeToItem(MoreporkUI.BasePage)
                    fre.gotoNextStep(currentFreStep)
                }
                else {
                    timeSwipeView.swipeToItem(TimePage.SetDate)
                    settingsSwipeView.swipeToItem(SettingsPage.BasePage)
                }
            }
            enabled: {
                !hoursTumbler.moving && !minutesTumbler.moving && !meridianTumbler.moving
            }
        }
    }
}
