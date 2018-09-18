import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessStateTypeEnum 1.0

Item {
    id: printStatusPage
    width: 800
    height: 440
    smooth: false
    property string fileName_
    property string filePathName
    property string support_mass_
    property string model_mass_
    property string uses_support_
    property string uses_raft_
    property string print_time_
    property string printerName: bot.name
    property int timeLeftSeconds: bot.process.timeRemaining
    property int timeLeftMinutes: timeLeftSeconds/60
    property string doneByDayString: "DEFAULT_STRING"
    property string doneByTimeString: "99:99"
    property string timeLeftString: "99:99"
    property string doneByMeridianString
    property alias printStatusSwipeView: printStatusSwipeView
    onTimeLeftMinutesChanged: updateTime()

    function updateTime() {
        var timeLeft = new Date("", "", "", "", "", timeLeftSeconds)
        var currentTime = new Date()
        var endMS = currentTime.getTime() + timeLeftSeconds*1000
        var endTime = new Date()
        endTime.setTime(endMS)
        var daysLeft = endTime.getDate() - currentTime.getDate()
        timeLeftString = timeLeft.getDate() != 31 ? timeLeft.getDate() + "D " + timeLeft.getHours() + "HR " + timeLeft.getMinutes() + "M" :
                                                    timeLeft.getHours() != 0 ? timeLeft.getHours() + "HR " + timeLeft.getMinutes() + "M" :
                                                                               timeLeft.getMinutes() + "M"
        doneByDayString = daysLeft > 1 ? "DONE IN " + daysLeft + " DAYS BY" :
                                         daysLeft == 1 ? "DONE TOMMORROW BY" : "DONE TODAY BY"
        doneByTimeString = endTime.getHours() % 12 == 0 ? endTime.getMinutes() < 10 ? "12" + ":0" + endTime.getMinutes() :
                                                                                      "12" + ":" + endTime.getMinutes() :
                                                          endTime.getMinutes() < 10 ? endTime.getHours() % 12 + ":0" + endTime.getMinutes() :
                                                                                      endTime.getHours() % 12 + ":" + endTime.getMinutes()
        doneByMeridianString = endTime.getHours() >= 12 ? "PM" : "AM"
    }

    SwipeView {
        id: printStatusSwipeView
        smooth: false
        currentIndex: 0 // Should never be non zero
        anchors.fill: parent
        visible: true
        Item {
            id: page0
            width: 800
            height: 420
            smooth: false
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20

            PrintIcon {
                anchors.verticalCenterOffset: 7
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 65
            }

            ColumnLayout {
                id: columnLayout_page0
                width: 400
                height: bot.process.stateType == ProcessStateType.Completed ? 245 :
                            bot.process.stateType == ProcessStateType.Failed ? 210 : 100
                smooth: false
                anchors.left: parent.left
                anchors.leftMargin: 400
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: status_text0
                    color: "#cbcbcb"
                    text: {
                        switch(bot.process.stateType) {
                        case ProcessStateType.Loading:
                            "GETTING READY"
                            break;
                        case ProcessStateType.Printing:
                            "PRINTING"
                            break;
                        case ProcessStateType.Pausing:
                            "PAUSING"
                            break;
                        case ProcessStateType.Resuming:
                            "RESUMING"
                            break;
                        case ProcessStateType.Paused:
                        case ProcessStateType.UnloadingFilament: // Out of filament during print
                        case ProcessStateType.Preheating:
                            "PAUSED"
                            break;
                        case ProcessStateType.Completed:
                            "PRINT COMPLETE"
                            break;
                        case ProcessStateType.Failed:
                            "PRINT FAILED"
                            break;
                        case ProcessStateType.Cancelling:
                        case ProcessStateType.CleaningUp:
                            "CANCELLING"
                            break;
                        default:
                            ""
                            break;
                        }
                    }
                    antialiasing: false
                    smooth: false
                    font.letterSpacing: 5
                    font.family: "Antenna"
                    font.weight: Font.Bold
                    font.pixelSize: 18
                }

                Text {
                    id: subtext0
                    color: "#cbcbcb"
                    text: {
                        switch(bot.process.stateType) {
                        case ProcessStateType.Loading:
                            bot.extruderATargetTemp > 0 ? "HEATING UP EXTRUDER..." :
                                                          "HEATING UP CHAMBER..."
                            break;
                        case ProcessStateType.Printing:
                            fileName_
                            break;
                        case ProcessStateType.Pausing:
                        case ProcessStateType.Resuming:
                        case ProcessStateType.Paused:
                            (bot.process.errorCode?
                                "Error " + bot.process.errorCode :
                                fileName_)
                            break;
                        case ProcessStateType.Completed:
                            print_time_ + " PRINT TIME"
                            break;
                        case ProcessStateType.Failed:
                            "Error " + bot.process.errorCode
                            break;
                        case ProcessStateType.UnloadingFilament:
                        case ProcessStateType.Preheating: //Out of filament while printing
                            "OUT OF FILAMENT - UNLOADING"
                            break;
                        default:
                            ""
                            break;
                        }
                    }
                    antialiasing: false
                    smooth: false
                    font.letterSpacing: 3
                    font.family: "Antenna"
                    font.weight: Font.Light
                    font.pixelSize: 18
                }

                Text {
                    id: subtext1
                    color: "#cbcbcb"
                    text: {
                        switch(bot.process.stateType) {
                        case ProcessStateType.Loading:
                            bot.extruderATargetTemp > 0 ?
                                (bot.extruderACurrentTemp + " C" + " | " + bot.extruderATargetTemp + " C") :
                                (bot.chamberCurrentTemp + " C" + " | " + bot.chamberTargetTemp + " C")
                            break;
                        case ProcessStateType.Printing:
                        case ProcessStateType.Pausing:
                        case ProcessStateType.Resuming:
                        case ProcessStateType.Paused:
                            timeLeftString + " REMAINING"
                            break;
                        case ProcessStateType.Failed:
                            print_time_ + " PRINT TIME"
                            break;
                        default:
                            ""
                            break;
                        }
                    }
                    antialiasing: false
                    smooth: false
                    font.letterSpacing: 3
                    font.family: "Antenna"
                    font.weight: Font.Light
                    font.pixelSize: 18
                }

                RoundedButton {
                    id: print_again_button
                    buttonWidth: 200
                    buttonHeight: 45
                    label: "PRINT AGAIN"
                    visible: bot.process.stateType == ProcessStateType.Completed ||
                             bot.process.stateType == ProcessStateType.Failed
                    button_mouseArea.onClicked: {
                        printAgain = true
                        printPage.getPrintTimes(printPage.lastPrintTimeSec)
                        printPage.printSwipeView.swipeToItem(2)
                    }
                }

                RoundedButton {
                    id: start_next_print_button
                    buttonWidth: 300
                    buttonHeight: 45
                    label: "START NEXT PRINT"
                    visible: bot.process.stateType == ProcessStateType.Completed
                }

                RoundedButton {
                    id: done_button
                    buttonWidth: 100
                    buttonHeight: 45
                    label: "DONE"
                    visible: bot.process.stateType == ProcessStateType.Completed ||
                             bot.process.stateType == ProcessStateType.Failed
                    button_mouseArea.onClicked: {
                        if(bot.process.stateType == ProcessStateType.Failed) {
                            bot.done("acknowledge_failure")
                        }
                        else if(bot.process.stateType == ProcessStateType.Completed) {
                            bot.done("acknowledge_completed")
                        }
                        printPage.resetPrintFileDetails()
                    }
                }
            }
        }

        Item {
            id: page1
            width: 800
            height: 420
            smooth: false
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20

            Image {
                id: model_image2
                smooth: false
                sourceSize.width: 212
                sourceSize.height: 300
                anchors.left: parent.left
                anchors.leftMargin: 100
                anchors.verticalCenter: parent.verticalCenter
                source: "image://thumbnail/" + filePathName
            }

            ColumnLayout {
                id: columnLayout_page1
                width: 400
                height: 195
                smooth: false
                spacing: 3
                anchors.left: parent.left
                anchors.leftMargin: 400
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: fileName_text1
                    color: "#cbcbcb"
                    text: fileName_
                    antialiasing: false
                    smooth: false
                    font.letterSpacing: 3
                    font.family: "Antenna"
                    font.weight: Font.Bold
                    font.pixelSize: 20
                }

                Item {
                    id: divider_item1
                    width: 200
                    height: 15
                    smooth: false
                }

                RowLayout {
                    id: rowLayout1
                    width: 100
                    height: 100
                    smooth: false
                    spacing: 65

                    ColumnLayout {
                        id: columnLayout1
                        width: 100
                        height: 100
                        smooth: false
                        spacing: 10

                        Text {
                            id: infill_label
                            color: "#cbcbcb"
                            text: "INFILL"
                            antialiasing: false
                            smooth: false
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
                            antialiasing: false
                            smooth: false
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
                            antialiasing: false
                            smooth: false
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
                            antialiasing: false
                            smooth: false
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
                            antialiasing: false
                            smooth: false
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
                        smooth: false
                        spacing: 10

                        Text {
                            id: infill_text
                            color: "#ffffff"
                            text: "99.99%"
                            antialiasing: false
                            smooth: false
                            font.family: "Antenna"
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                        Text {
                            id: supports_text
                            color: "#ffffff"
                            text: uses_support_
                            antialiasing: false
                            smooth: false
                            font.family: "Antenna"
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                        Text {
                            id: rafts_text
                            color: "#ffffff"
                            text: uses_raft_
                            antialiasing: false
                            smooth: false
                            font.family: "Antenna"
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                        Text {
                            id: model_text
                            color: "#ffffff"
                            text: model_mass_ + " PLA"
                            antialiasing: false
                            smooth: false
                            font.family: "Antenna"
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                        Text {
                            id: support_text
                            color: "#ffffff"
                            text: support_mass_ + " PVA"
                            antialiasing: false
                            smooth: false
                            font.family: "Antenna"
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }
                    }
                }
            }
        }

        Item {
            id: page2
            width: 800
            height: 420
            smooth: false
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20

            Image {
                id: sombrero_image
                smooth: false
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
                smooth: false
                anchors.leftMargin: 400
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3

                Text {
                    id: printerName_text2
                    color: "#cbcbcb"
                    text: printerName + " INFO"
                    antialiasing: false
                    smooth: false
                    font.family: "Antenna"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    font.letterSpacing: 3
                }

                Item {
                    id: divider_item2
                    width: 200
                    height: 15
                    smooth: false
                }

                RowLayout {
                    id: rowLayout2
                    width: 100
                    height: 100
                    smooth: false
                    spacing: 45

                    ColumnLayout {
                        id: columnLayout3
                        width: 100
                        height: 100
                        smooth: false
                        spacing: 10

                        Text {
                            id: extruder1_temp_label
                            color: "#cbcbcb"
                            text: "EX 1 TEMP"
                            antialiasing: false
                            smooth: false
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
                            antialiasing: false
                            smooth: false
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
                            antialiasing: false
                            smooth: false
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
                            antialiasing: false
                            smooth: false
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
                            antialiasing: false
                            smooth: false
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
                        smooth: false
                        spacing: 10

                        Text {
                            id: extruder1_temp_text
                            color: "#ffffff"
                            text: bot.extruderACurrentTemp + "C"
                            antialiasing: false
                            smooth: false
                            font.family: "Antenna"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                        }

                        Text {
                            id: extruder2_temp_text
                            color: "#ffffff"
                            text: bot.extruderBCurrentTemp + "C"
                            antialiasing: false
                            smooth: false
                            font.family: "Antenna"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                        }

                        Text {
                            id: extruder1_life_text
                            color: "#ffffff"
                            text: "9999HR"
                            antialiasing: false
                            smooth: false
                            font.family: "Antenna"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                        }

                        Text {
                            id: extruder2_life_text
                            color: "#ffffff"
                            text: "9999HR"
                            antialiasing: false
                            smooth: false
                            font.family: "Antenna"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                        }

                        Text {
                            id: chamber_temp_text
                            color: "#ffffff"
                            text: bot.chamberCurrentTemp + "C"
                            antialiasing: false
                            smooth: false
                            font.family: "Antenna"
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                        }
                    }
                }
            }
        }

        Item {
            id: page3
            width: 800
            height: 420
            smooth: false
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20

            ColumnLayout {
                id: columnLayout_page3
                smooth: false
                spacing: 10
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    id: done_by_label0
                    color: "#cbcbcb"
                    text: doneByDayString
                    antialiasing: false
                    smooth: false
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
                    antialiasing: false
                    smooth: false
                    font.pixelSize: 145
                    font.family: "Antenna"
                    font.weight: Font.Light
                    font.letterSpacing: 3

                    Text {
                        id: am_pm_text
                        color: "#ffffff"
                        text: doneByMeridianString
                        antialiasing: false
                        smooth: false
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
                    antialiasing: false
                    smooth: false
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
                    antialiasing: false
                    smooth: false
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: "Antenna"
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    font.letterSpacing: 3
                }
            }
        }

        Item {
            id: page4
            width: 800
            height: 420
            smooth: false
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20

            Item {
                id: baseItem
                width: 750
                height: 160
                smooth: false
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: printerName_text4
                    color: "#ffffff"
                    text: printerName
                    antialiasing: false
                    smooth: false
                    font.pixelSize: 85
                    font.family: "Antenna"
                    font.weight: Font.Bold
                    font.letterSpacing: 0

                    Text {
                        id: is_printing_label
                        color: "#cbcbcb"
                        text: "IS PRINTING"
                        antialiasing: false
                        smooth: false
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
                            antialiasing: false
                            smooth: false
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
                            text: doneByDayString
                            antialiasing: false
                            smooth: false
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
                                antialiasing: false
                                smooth: false
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
        smooth: false
        visible: printStatusSwipeView.visible
        count: printStatusSwipeView.count
        currentIndex: printStatusSwipeView.currentIndex
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter

        delegate: Rectangle {
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
