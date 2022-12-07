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
        if (count == 12) {
            // Month
            data = modelData + 1
            if (data.toString().length < 2) {
                data = "0" + data
            }
            return data
        } else if(count == 31 || count == 30 || count == 28 || count == 29) {
            // Date
            data = modelData + 1
            if (data.toString().length < 2) {
                data = "0" + data
            }
            return data
        } else if(count == 100) {
            // Year
            data = modelData + 2000
            return data
        }
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
            opacity: 1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 100
            font.weight: Font.Light
            font.family: defaultFont.name
            color: "#ffffff"
        }
    }

    Item {
        anchors.left: parent.left
        anchors.leftMargin: 40
        anchors.right: setDateButton.left
        anchors.bottom: parent.bottom
        anchors.top: parent.top

        Tumbler {
            id: monthTumbler
            anchors.verticalCenter: parent.verticalCenter
            width: 120
            height: parent.height
            visibleItemCount: 3
            model: 12
            delegate: delegateComponent

            Rectangle {
                id: topLineMonth
                width: parent.width
                height: 1
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -65
            }


            Rectangle {
                id: bottomLineMonth
                width: parent.width
                height: 1
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 50

                TextSubheader {
                    text: qsTr("MONTH")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.bottom
                    anchors.topMargin: 10
                }
            }
        }

        Tumbler {
            id: dateTumbler
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: monthTumbler.right
            anchors.leftMargin: 24
            width: 120
            height: parent.height
            visibleItemCount: 3
            model: {
                if (monthTumbler.currentItem.text == 2) {
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
            }

            delegate: delegateComponent


            Rectangle {
                id: topLineDate
                width: parent.width
                height: 1
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -65
            }

            Rectangle {
                id: bottomLineDate
                width: parent.width
                height: 1
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 50

                TextSubheader {
                    text: qsTr("DAY")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.bottom
                    anchors.topMargin: 10
                }
            }
        }

        Tumbler {
            id: yearTumbler
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: dateTumbler.right
            anchors.leftMargin: 24
            width: 300
            height: parent.height*1.65
            model: 100
            delegate: delegateComponent

            Rectangle {
                id: topLineYear
                width: parent.width
                height: 1
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -65
            }

            Rectangle {
                id: bottomLineYear
                width: parent.width
                height: 1
                color: "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 50

                TextSubheader {
                    text: qsTr("YEAR")
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.bottom
                    anchors.topMargin: 10
                }
            }
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
            timeSwipeView.swipeToItem(TimePage.BasePage)
            console.log(parent.width)
            console.log(parent.height)
        }
        enabled: {
            !monthTumbler.moving && !dateTumbler.moving && !yearTumbler.moving
        }
    }
}
