import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import FreStepEnum 1.0

Item {

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

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

        dateTumbler.currentIndex = parseInt(current_day, 10) - 1
        monthTumbler.currentIndex = parseInt(current_month, 10) - 1
        yearTumbler.currentIndex = parseInt(current_year, 10) - 2000
    }

    function formatText(count, modelData) {
        if (count == 12) {
            // Month
            var data = modelData + 1
            if (data.toString().length < 2) {
                data = "0" + data
            }
            return data
        } else if(count == 31 || count == 30 || count == 28 || count == 29) {
            // Date
            var data = modelData + 1
            if (data.toString().length < 2) {
                data = "0" + data
            }
            return data
        } else if(count == 100) {
            // Year
            var data = modelData + 2000
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
            font.pixelSize: 110
            font.weight: Font.Light
            font.family: defaultFont.name
            color: "#ffffff"
        }
    }

    Item {
        id: element
        width: 800
        height: 200
        anchors.verticalCenterOffset: -20
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        Tumbler {
            id: monthTumbler
            width: 180
            height: 430
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.verticalCenter: parent.verticalCenter
            visibleItemCount: 3
            model: 12
            delegate: delegateComponent
        }

        Tumbler {
            id: dateTumbler
            width: 180
            height: 430
            anchors.left: parent.left
            anchors.leftMargin: 240
            anchors.verticalCenter: parent.verticalCenter
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
        }

        Tumbler {
            id: yearTumbler
            width: 300
            height: 700
            anchors.right: parent.right
            anchors.rightMargin: 30
            anchors.verticalCenter: parent.verticalCenter
            model: 100
            delegate: delegateComponent
        }
    }

    Item {
        id: overlayItem
        width: 800
        height: 150
        anchors.verticalCenterOffset: -28
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            id: topLeftLine
            width: 150
            height: 1
            color: "#ffffff"
            anchors.top: parent.top
            anchors.topMargin: 18
            anchors.left: parent.left
            anchors.leftMargin: 45
        }

        Rectangle {
            id: topCenterLine
            width: 150
            height: 1
            color: "#ffffff"
            anchors.top: parent.top
            anchors.topMargin: 18
            anchors.left: parent.left
            anchors.leftMargin: 255
        }

        Rectangle {
            id: topRightLine
            width: 290
            height: 1
            color: "#ffffff"
            anchors.top: parent.top
            anchors.topMargin: 18
            anchors.right: parent.right
            anchors.rightMargin: 40
        }

        Rectangle {
            id: bottomLeftLine
            width: 150
            height: 1
            color: "#ffffff"
            anchors.left: parent.left
            anchors.leftMargin: 45
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 18

            Text {
                text: qsTr("MONTH")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.bottom
                anchors.topMargin: 10
                font.pixelSize: 15
                font.weight: Font.Light
                font.family: defaultFont.name
                font.letterSpacing: 3
                color: "#ffffff"
            }
        }

        Rectangle {
            id: bottomCenterLine
            width: 150
            height: 1
            color: "#ffffff"
            anchors.left: parent.left
            anchors.leftMargin: 255
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 18

            Text {
                text: qsTr("DAY")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.bottom
                anchors.topMargin: 10
                font.pixelSize: 15
                font.weight: Font.Light
                font.family: defaultFont.name
                font.letterSpacing: 3
                color: "#ffffff"
            }
        }

        Rectangle {
            id: bottomRightLine
            width: 290
            height: 1
            color: "#ffffff"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 18
            anchors.right: parent.right
            anchors.rightMargin: 40

            Text {
                text: qsTr("YEAR")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.bottom
                anchors.topMargin: 10
                font.pixelSize: 15
                font.weight: Font.Light
                font.family: defaultFont.name
                font.letterSpacing: 3
                color: "#ffffff"
            }
        }

        Rectangle {
            id: topFadeItem
            width: 800
            height: 170
            anchors.horizontalCenter: parent.horizontalCenter
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
        }

        Rectangle {
            id: bottomFadeItem
            width: 800
            height: 170
            anchors.horizontalCenter: parent.horizontalCenter
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
        }
    }

    RoundedButton {
        id: setDateButton
        buttonHeight: 50
        buttonWidth: 120
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        label: qsTr("NEXT")
        opacity: {
            button_mouseArea.enabled ? 1.0 : 0.1
        }
        is_button_transparent: false

        Behavior on opacity {
            OpacityAnimator {
                duration: 100
            }
        }

        button_mouseArea {
            onClicked: {
                setTime()
                timeSwipeView.swipeToItem(TimePage.SetTimeZone)
            }
            enabled: {
                !monthTumbler.moving && !dateTumbler.moving && !yearTumbler.moving
            }
        }
    }
}
