import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import FreStepEnum 1.0

Item {
    anchors.fill: parent

    property alias setDateButton: setDateButton
    property alias monthTumbler: monthTumbler
    property alias dateTumbler: dateTumbler
    property alias yearTumbler: yearTumbler

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

        // Days count depends on month & year, so they should be assigned
        // first to not affect the date tumbler.
        yearTumbler.currentIndex = parseInt(current_year, 10) - 2000
        monthTumbler.currentIndex = parseInt(current_month, 10) - 1
        dateTumbler.currentIndex = parseInt(current_day, 10) - 1
    }

    function formatText(count, modelData) {
        var data = 0
        // Month & Date tumbler
        if (count == 12 || count == 31 || count == 30 || count == 29 || count == 28) {
            data = modelData + 1
            if (data.toString().length < 2) {
                data = "0" + data
            }
        } else if(count == 50) {
            // Year
            data = modelData + 2000
        }
        return data
    }

    function setTime() {
        var current_time = bot.systemTime
        var time_split = current_time.split(' ')
        var set_month = monthTumbler.currentItem.text
        var set_date = dateTumbler.currentItem.text
        var set_year = yearTumbler.currentItem.text
        current_time = set_year + "-" + set_month + "-" + set_date + " " + time_split[1]
        bot.setSystemTime(current_time)
    }

    Component {
        id: delegateComponent
        Text {
            text: formatText(Tumbler.tumbler.count, modelData)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: (Tumbler.tumbler.currentItem && Tumbler.tumbler.currentItem.text == text) ? 100 : 64
            font.weight: Font.Light
            font.family: defaultFont.name
            color: (Tumbler.tumbler.currentItem && Tumbler.tumbler.currentItem.text == text) ? "#ffffff" : "#B2B2B2"

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
        anchors.right: setDateButton.left
        anchors.bottom: parent.bottom
        anchors.top: parent.top

        VerticalTumbler {
            id: monthTumbler
            anchors.verticalCenter: parent.verticalCenter
            width: 130
            height: parent.height
            visibleItemCount: 3
            model: 12
            delegate: delegateComponent
            tumblerName: qsTr("MONTH")
        }

        VerticalTumbler {
            id: dateTumbler
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: monthTumbler.right
            anchors.leftMargin: 24
            width: 130
            height: parent.height
            visibleItemCount: 3

            model: {
                if(!monthTumbler.moving) {
                    if(monthTumbler.currentItem.text == 2) {
                        if (parseInt(yearTumbler.currentItem.text, 10) % 4 == 0) {
                            29
                        } else {
                            28
                        }
                    } else if(monthTumbler.currentItem.text == 1 ||
                              monthTumbler.currentItem.text == 3 ||
                              monthTumbler.currentItem.text == 5 ||
                              monthTumbler.currentItem.text == 7 ||
                              monthTumbler.currentItem.text == 8 ||
                              monthTumbler.currentItem.text == 10 ||
                              monthTumbler.currentItem.text == 12 ) {
                        31
                    } else {
                        30
                    }
                } else {
                    model
                }
            }
            delegate: delegateComponent
            tumblerName: qsTr("DAY")
        }

        VerticalTumbler {
            id: yearTumbler
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: dateTumbler.right
            anchors.leftMargin: 24
            width: 265
            height: parent.height*1.65
            model: 50
            delegate: delegateComponent
            tumblerName: qsTr("YEAR")
        }
    }

    ButtonRectanglePrimary {
        id: setDateButton
        width: 120
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.verticalCenter: parent.verticalCenter
        text: qsTr("SAVE")

        onClicked: {
            setTime()
            goToNextStep.start()
        }
        enabled: {
            !monthTumbler.moving && !dateTumbler.moving && !yearTumbler.moving
        }
    }
}
