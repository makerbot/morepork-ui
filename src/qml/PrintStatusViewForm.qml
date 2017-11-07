import QtQuick 2.4
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

Item {
    id: item1
    width: 800
    height: 440

    property string fileName_
    property string printerName: bot.name
    property int timeLeftSeconds: bot.process.timeRemaining
    property string doneByDayString: "DEFAULT_STRING"
    property string doneByTimeString: "99:99"
    property string timeLeftString: "99:99"
    property string doneByMeridianString

    onTimeLeftSecondsChanged: updateTime()

    function updateTime()
    {
        var timeLeft = new Date("", "", "", "", "", timeLeftSeconds)
        var currentTime = new Date()
        var endMS = currentTime.getTime() + timeLeftSeconds*1000
        var endTime = new Date()
        endTime.setTime(endMS)
        var daysLeft = endTime.getDate() - currentTime.getDate()
        timeLeftString = timeLeft.getDate() != 31 ? timeLeft.getDate() + "D " + timeLeft.getHours() + "HR " + timeLeft.getMinutes() + "M" : timeLeft.getHours() != 0 ? timeLeft.getHours() + "HR " + timeLeft.getMinutes() + "M" : timeLeft.getMinutes() + "M"
        doneByDayString = daysLeft > 1 ? "DONE IN " + daysLeft + " DAYS BY" : daysLeft == 1 ? "DONE TOMMORROW BY" : "DONE TODAY BY"
        doneByTimeString = endTime.getHours() == 0 ? endTime.getMinutes() < 10 ? "12" + ":0" + endTime.getMinutes() : "12" + ":" + endTime.getMinutes() : endTime.getMinutes() < 10 ? endTime.getHours() % 12 + ":0" + endTime.getMinutes() : endTime.getHours() % 12 + ":" + endTime.getMinutes()
        doneByMeridianString = endTime.getHours() >= 12 ? "PM" : "AM"
    }

    Rectangle {
        id: rectangle
        color: "#000000"
        visible: true
        anchors.fill: parent
    }

    SwipeView {
        id: printStatusSwipeView
        currentIndex: 0 // Should never be non zero
        anchors.fill: parent
        visible: true

        Item {
            id: page0
            PrintIcon{
                anchors.verticalCenterOffset: 7
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 65
            }

            ColumnLayout {
                id: columnLayout_page0
                width: 400
                height: 180
                anchors.left: parent.left
                anchors.leftMargin: 400
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: status_text0
                    color: "#cbcbcb"
                    text: "PRINTING"
                    font.letterSpacing: 5
                    font.family: "Antenna"
                    font.weight: Font.Light
                    font.pixelSize: 22
                }

                Text {
                    id: fileName_text0
                    color: "#cbcbcb"
                    text: fileName_
                    font.letterSpacing: 3
                    font.family: "Antenna"
                    font.weight: Font.Light
                    font.pixelSize: 18
                }

                Item {
                    id: divider_item0
                    width: 200
                    height: 20
                }

                RowLayout {
                    id: rowLayout0
                    width: 100
                    height: 100
                    spacing: 65

                    ColumnLayout {
                        id: columnLayout0_1
                        width: 100
                        height: 100

                        Text {
                            id: timeLeft_label
                            color: "#cbcbcb"
                            text: "TIME LEFT"
                            font.wordSpacing: 2
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                        Text {
                            id: bay1_label0
                            color: "#cbcbcb"
                            text: "BAY 1"
                            font.wordSpacing: 2
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                        Text {
                            id: bay2_label0
                            color: "#cbcbcb"
                            text: "BAY 2"
                            font.wordSpacing: 2
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }
                    }

                    ColumnLayout {
                        id: columnLayout0_2
                        width: 100
                        height: 100

                        Text {
                            id: timeLeft_text0
                            color: "#ffffff"
                            text:
                            {
                                timeLeftString
                            }
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                        Text {
                            id: bay1_text0
                            color: "#ffffff"
                            text: ".999 KG PLA"
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                        Text {
                            id: bay2_text0
                            color: "#ffffff"
                            text: ".999 KG PLA"
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }


                    }
                }
            }
        }

        Item {
            id: page1
            Item {
                id: modelItem
                width: 212
                height: 300
                anchors.left: parent.left
                anchors.leftMargin: 100
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: back_image
                    anchors.fill: parent
                    source: "qrc:/img/back_build_volume.png"
                }

                Image {
                    id: model_image
                    anchors.verticalCenterOffset: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    source: "qrc:/img/model.png"
                }

                Image {
                    id: front_image
                    anchors.fill: parent
                    source: "qrc:/img/front_build_volume.png"
                }
            }

            ColumnLayout {
                id: columnLayout_page1
                width: 400
                height: 195
                spacing: 3
                anchors.left: parent.left
                anchors.leftMargin: 400
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: fileName_text1
                    color: "#cbcbcb"
                    text: fileName_
                    font.letterSpacing: 3
                    font.family: "Antenna"
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Item {
                    id: divider_item1
                    width: 200
                    height: 15
                }

                RowLayout {
                    id: rowLayout1
                    width: 100
                    height: 100
                    spacing: 65

                    ColumnLayout {
                        id: columnLayout1
                        width: 100
                        height: 100
                        spacing: 10

                        Text {
                            id: infill_label
                            color: "#cbcbcb"
                            text: "INFILL"
                            font.wordSpacing: 2
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                        Text {
                            id: supports_label
                            color: "#cbcbcb"
                            text: "SUPPORTS"
                            font.wordSpacing: 2
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                        Text {
                            id: rafts_label
                            color: "#cbcbcb"
                            text: "RAFTS"
                            font.wordSpacing: 2
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                        Text {
                            id: model_label
                            color: "#cbcbcb"
                            text: "MODEL"
                            font.wordSpacing: 2
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                        Text {
                            id: support_label
                            color: "#cbcbcb"
                            text: "SUPPORT"
                            font.wordSpacing: 2
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }
                    }

                    ColumnLayout {
                        id: columnLayout2
                        width: 100
                        height: 100
                        spacing: 10

                        Text {
                            id: infill_text
                            color: "#ffffff"
                            text: "99.99%"
                            font.family: "Antenna"
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                        Text {
                            id: supports_text
                            color: "#ffffff"
                            text: "NULL"
                            font.family: "Antenna"
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                        Text {
                            id: rafts_text
                            color: "#ffffff"
                            text: "NULL"
                            font.family: "Antenna"
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                        Text {
                            id: model_text
                            color: "#ffffff"
                            text: "99.99KG PLA"
                            font.family: "Antenna"
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                        Text {
                            id: support_text
                            color: "#ffffff"
                            text: "99.99KG PVA"
                            font.family: "Antenna"
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }
                    }
                }
            }

        }

        Item{
            id: page2

            Image {
                id: sombrero_image
                sourceSize.height: 342
                sourceSize.width: 221
                anchors.left: parent.left
                anchors.leftMargin: 100
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/img/sombrero.png"
            }

            ColumnLayout {
                id: columnLayout_page2
                width: 400
                height: 195
                anchors.leftMargin: 400
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3
                Text {
                    id: printerName_text2
                    color: "#cbcbcb"
                    text: printerName + " INFO"
                    font.family: "Antenna"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    font.letterSpacing: 3
                }

                Item {
                    id: divider_item2
                    width: 200
                    height: 15
                }

                RowLayout {
                    id: rowLayout2
                    width: 100
                    height: 100
                    spacing: 45
                    ColumnLayout {
                        id: columnLayout3
                        width: 100
                        height: 100
                        spacing: 10
                        Text {
                            id: extruder1_temp_label
                            color: "#cbcbcb"
                            text: "EX 1 TEMP"
                            font.family: "Antenna"
                            font.pixelSize: 18
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.wordSpacing: 2
                        }

                        Text {
                            id: extruder2_temp_label
                            color: "#cbcbcb"
                            text: "EX 2 TEMP"
                            font.family: "Antenna"
                            font.pixelSize: 18
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.wordSpacing: 2
                        }

                        Text {
                            id: extruder1_life_label
                            color: "#cbcbcb"
                            text: "EX 1 LIFE"
                            font.family: "Antenna"
                            font.pixelSize: 18
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.wordSpacing: 2
                        }

                        Text {
                            id: extruder2_life_label
                            color: "#cbcbcb"
                            text: "EX 2 LIFE"
                            font.pixelSize: 18
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.wordSpacing: 2
                        }

                        Text {
                            id: chamber_temp_label
                            color: "#cbcbcb"
                            text: "CHAMBER TEMP"
                            font.pixelSize: 18
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.wordSpacing: 2
                        }
                    }

                    ColumnLayout {
                        id: columnLayout4
                        width: 100
                        height: 100
                        spacing: 10
                        Text {
                            id: extruder1_temp_text
                            color: "#ffffff"
                            text: bot.extruderACurrentTemp + "C"
                            font.family: "Antenna"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                        }

                        Text {
                            id: extruder2_temp_text
                            color: "#ffffff"
                            text: bot.extruderBCurrentTemp + "C"
                            font.family: "Antenna"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                        }

                        Text {
                            id: extruder1_life_text
                            color: "#ffffff"
                            text: "9999HR"
                            font.family: "Antenna"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                        }

                        Text {
                            id: extruder2_life_text
                            color: "#ffffff"
                            text: "9999HR"
                            font.family: "Antenna"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                        }

                        Text {
                            id: chamber_temp_text
                            color: "#ffffff"
                            text: bot.chamberCurrentTemp + "C"
                            font.family: "Antenna"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                        }
                    }
                }
            }
        }

        Item{
            id: page3

            ColumnLayout {
                id: columnLayout_page3
                spacing: 10
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: done_by_label0
                    color: "#cbcbcb"
                    text:
                    {
                        doneByDayString
                    }
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: "Antenna"
                    font.pixelSize: 15
                    font.weight: Font.Light
                    font.letterSpacing: 3
                }

                Text {
                    id: end_time_text
                    color: "#ffffff"
                    text: doneByTimeString
                    font.pixelSize: 145
                    font.family: "Antenna"
                    font.weight: Font.Light
                    font.letterSpacing: 3

                    Text {
                        id: am_pm_text
                        color: "#ffffff"
                        text: doneByMeridianString
                        anchors.right: parent.right
                        anchors.rightMargin: -24
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 26
                        font.pixelSize: 15
                        font.family: "Antenna"
                        font.weight: Font.Light
                        font.letterSpacing: 3
                    }
                }

                Text {
                    id: printer_name_is_printing_text
                    color: "#cbcbcb"
                    text: printerName + " IS PRINTING"
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: "Antenna"
                    font.pixelSize: 15
                    font.weight: Font.Light
                    font.letterSpacing: 3
                }

                Text {
                    id: fileName_text3
                    color: "#ffffff"
                    text: fileName_
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: "Antenna"
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    font.letterSpacing: 3
                }
            }
        }

        Item{
            id: page4
            Item {
                id: baseItem
                width: 750
                height: 160
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: printerName_text4
                    color: "#ffffff"
                    text: printerName
                    font.pixelSize: 85
                    font.family: "Antenna"
                    font.weight: Font.Bold
                    font.letterSpacing: 0

                    Text {
                        id: is_printing_label
                        color: "#cbcbcb"
                        text: "IS PRINTING"
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -30
                        font.pixelSize: 16
                        font.family: "Antenna"
                        font.weight: Font.Light
                        font.letterSpacing: 3

                        Text {
                            id: filename_text4
                            color: "#ffffff"
                            text: fileName_
                            anchors.left: parent.left
                            anchors.leftMargin: 145
                            font.pixelSize: 16
                            font.family: "Antenna"
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                        }

                        Text {
                            id: done_by_label1
                            color: "#cbcbcb"
                            text:
                            {
                                doneByDayString
                            }
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: -30
                            font.pixelSize: 16
                            font.family: "Antenna"
                            font.weight: Font.Light
                            font.letterSpacing: 3

                            Text {
                                id: end_time_text4
                                color: "#ffffff"
                                text: doneByTimeString + doneByMeridianString
                                anchors.right: parent.right
                                anchors.rightMargin: -90
                                font.pixelSize: 16
                                font.family: "Antenna"
                                font.weight: Font.Bold
                                font.letterSpacing: 3
                            }
                        }
                    }
                }
            }
        }
    }

    PageIndicator {
        id: indicator
        visible: printStatusSwipeView.visible
        count: printStatusSwipeView.count
        currentIndex: printStatusSwipeView.currentIndex
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter

        delegate: Rectangle{
            implicitWidth: 12
            implicitHeight: 12

            radius: width / 2
            border.width: 1
            border.color: "#ffffff"

            color: index === indicator.currentIndex ? "#ffffff" : "#00000000"

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }
    }
}
