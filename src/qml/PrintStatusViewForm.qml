import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessStateTypeEnum 1.0
import MachineTypeEnum 1.0

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
    property bool model_extruder_used_
    property bool support_extruder_used_
    property string print_model_material_
    property string print_support_material_
    property string printerName: bot.name
    property int timeLeftSeconds: bot.process.timeRemaining
    property int timeLeftMinutes: timeLeftSeconds/60
    property string doneByDayString: "DEFAULT_STRING"
    property string doneByTimeString: "99:99"
    property string timeLeftString: "99:99"
    property alias printStatusSwipeView: printStatusSwipeView
    property bool testPrintComplete: false
    property string extruderAExtrusionDistance: bot.extruderAExtrusionDistance
    property string extruderBExtrusionDistance: bot.extruderBExtrusionDistance

    property alias acknowledgePrintFinished: acknowledgePrintFinished
    onTimeLeftMinutesChanged: updateTime()

    function updateTime() {
        var currentTime = new Date()
        var endMS = currentTime.getTime() + timeLeftSeconds*1000
        var endTime = new Date()
        endTime.setTime(endMS)
        var daysLeft = endTime.getDate() - currentTime.getDate()

        // Is there a better way to do this.....
        var timeLeft_s = timeLeftSeconds
        // (86400 seconds in a day)
        var timeLeft_d = Math.floor(timeLeft_s / 86400)
        timeLeft_s %= 86400
        // (3600 seconds in an hour)
        var timeLeft_h = Math.floor(timeLeft_s / 3600)
        timeLeft_s %= 3600
        var timeLeft_m = Math.floor(timeLeft_s / 60)
        timeLeft_s %= 60

        if (timeLeft_d > 0) {
            timeLeftString = qsTr("%1D %2HR %3M").arg(timeLeft_d).arg(timeLeft_h).arg(timeLeft_m)
        } else if (timeLeft_h > 0) {
            timeLeftString = qsTr("%1HR %2M").arg(timeLeft_h).arg(timeLeft_m)
        } else {
            timeLeftString = qsTr("%1M").arg(timeLeft_m)
        }

        if (daysLeft > 1) {
            doneByDayString = qsTr("DONE IN %1 DAYS BY").arg(daysLeft)
        } else if (daysLeft === 1) {
            doneByDayString = qsTr("DONE TOMORROW BY")
        } else {
            doneByDayString = qsTr("DONE TODAY BY")
        }

        doneByTimeString = endTime.toLocaleTimeString(Qt.locale(),"hh:mm")
    }

    enum SwipeIndex {
        Page0,
        Page1,
        Page2,
        Page3,
        Page4
    }

    FailurePrintFeedback {
        id: failurePrintFeedback
        visible: (bot.process.stateType == ProcessStateType.Completed ||
                 bot.process.stateType == ProcessStateType.Cancelled) &&
                 !bot.process.printFeedbackReported &&
                 acknowledgePrintFinished.failureFeedbackSelected
        z: 1
    }

    SwipeView {
        id: printStatusSwipeView
        smooth: false
        currentIndex: PrintStatusView.Page0
        anchors.fill: parent
        visible: true

        // The third page of the Print Status is the Extruder Page
        // with the Extruder Lifetime stats. Make sure these update
        // similar to the same way that the ExtruderForm.qml updates.
        onCurrentIndexChanged: {
            if(currentIndex == PrintStatusView.Page2) {
                bot.getToolStats(0);
                bot.getToolStats(1);
            }
        }
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
                height: children.height
                smooth: false
                anchors.left: parent.left
                anchors.leftMargin: 400
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: {
                    if(acknowledgePrintFinished.state == "print_successful_feedback_reported" ||
                       acknowledgePrintFinished.state == "print_failed") {
                        50
                    } else {
                        0
                    }
                }
                spacing: {
                    if(bot.process.stateType == ProcessStateType.Cancelled) {
                        -10
                    } else {
                        20
                    }
                }

                Text {
                    id: status_text0
                    color: "#cbcbcb"
                    text: {
                        switch(bot.process.stateType) {
                        case ProcessStateType.Loading:
                            qsTr("GETTING READY")
                            break;
                        case ProcessStateType.Printing:
                            qsTr("PRINTING")
                            break;
                        case ProcessStateType.Pausing:
                            qsTr("PAUSING")
                            break;
                        case ProcessStateType.Resuming:
                            qsTr("RESUMING")
                            break;
                        case ProcessStateType.Paused:
                        case ProcessStateType.UnloadingFilament: // Out of filament during print
                        case ProcessStateType.Preheating:
                            qsTr("PAUSED")
                            break;
                        case ProcessStateType.Completed:
                            fileName_
                            break;
                        case ProcessStateType.Failed:
                            qsTr("PRINT FAILED")
                            break;
                        case ProcessStateType.Cancelled:
                            qsTr("PRINT CANCELLED")
                            break;
                        case ProcessStateType.Cancelling:
                            qsTr("CANCELLING")
                            break;
                        case ProcessStateType.CleaningUp:
                            if(bot.process.complete) {
                                qsTr("FINISHING UP")
                            }
                            else {
                                qsTr("CANCELLING")
                            }
                            break;
                        default:
                            ""
                            break;
                        }
                    }
                    antialiasing: false
                    smooth: false
                    font.letterSpacing: 5
                    font.family: defaultFont.name
                    font.weight: Font.Bold
                    font.pixelSize: 18
                    elide: Text.ElideMiddle
                    Layout.preferredWidth: parent.width - 40
                }

                Text {
                    id: subtext0
                    color: "#cbcbcb"
                    text: {
                        switch(bot.process.stateType) {
                        case ProcessStateType.Loading:
                            if(bot.process.stepStr == "waiting_for_file") {
                                qsTr("WAITING FOR PRINT FILE")
                            } else if(bot.process.stepStr == "transfer") {
                                qsTr("TRANSFERRING PRINT FILE")
                            } else if(bot.process.stepStr == "heating_chamber") {
                                qsTr("HEATING UP CHAMBER")
                            } else if(bot.process.stepStr == "heating_build_platform") {
                                qsTr("HEATING UP BUILD PLATFORM")
                            } else if(bot.extruderATargetTemp > 0) {
                                qsTr("HEATING UP EXTRUDER")
                            } else {
                                qsTr("HEATING UP CHAMBER")
                            }
                            break;
                        case ProcessStateType.Printing:
                            fileName_
                            break;
                        case ProcessStateType.Pausing:
                        case ProcessStateType.Resuming:
                        case ProcessStateType.Paused:
                            (bot.process.errorCode?
                                qsTr("Error %1").arg(bot.process.errorCode) :
                                fileName_)
                            break;
                        case ProcessStateType.Completed:
                            qsTr("%1 PRINT TIME").arg(print_time_)
                            break;
                        case ProcessStateType.Failed:
                            qsTr("Error %1").arg(bot.process.errorCode)
                            break;
                        case ProcessStateType.UnloadingFilament:
                        case ProcessStateType.Preheating: //Out of filament while printing
                            qsTr("OUT OF FILAMENT - UNLOADING")
                            break;
                        default:
                            ""
                            break;
                        }
                    }
                    antialiasing: false
                    smooth: false
                    font.letterSpacing: 3
                    font.family: defaultFont.name
                    font.weight: Font.Light
                    font.pixelSize: 18
                    elide: Text.ElideMiddle
                    Layout.preferredWidth: parent.width - 40
                }

                Text {
                    id: subtext1
                    color: "#cbcbcb"
                    text: {
                        switch(bot.process.stateType) {
                        case ProcessStateType.Loading:
                            if(bot.process.stepStr == "waiting_for_file") {
                                ""
                            } else if(bot.process.stepStr == "transfer") {
                                bot.process.printPercentage + "%"
                            } else if(bot.process.stepStr == "heating_chamber") {
                                (qsTr("%1 C").arg(bot.buildplaneCurrentTemp) + " | " + qsTr("%1 C").arg(bot.buildplaneTargetTemp))
                            } else if(bot.process.stepStr == "heating_build_platform") {
                                (qsTr("%1 C").arg(Math.floor(bot.hbpCurrentTemp)) + " | " + qsTr("%1 C").arg(bot.hbpTargetTemp))
                            } else if(bot.extruderATargetTemp > 0) {
                                (qsTr("%1 C").arg(bot.extruderACurrentTemp) + " | " + qsTr("%1 C").arg(bot.extruderATargetTemp) +
                                 (support_extruder_used_ ?
                                     (qsTr("\n%1 C").arg(bot.extruderBCurrentTemp) + " | " + qsTr("%1 C").arg(bot.extruderBTargetTemp)) :
                                     "\n"))
                            } else {
                                (qsTr("%1 C").arg(bot.buildplaneCurrentTemp) + " | " + qsTr("%1 C").arg(bot.buildplaneTargetTemp))
                            }
                            break;
                        case ProcessStateType.Printing:
                        case ProcessStateType.Pausing:
                        case ProcessStateType.Resuming:
                        case ProcessStateType.Paused: {
                            timeLeftString == "0M" ?
                                        qsTr("FINISHING UP") :
                                        qsTr("%1 REMAINING").arg(timeLeftString)
                        }
                            break;
                        case ProcessStateType.Failed:
                            qsTr("%1 PRINT TIME").arg(print_time_)
                            break;
                        case ProcessStateType.Completed:
                            qsTr("PRINT COMPLETE")
                            break;
                        default:
                            ""
                            break;
                        }
                    }
                    antialiasing: false
                    smooth: false
                    font.letterSpacing: 3
                    font.family: defaultFont.name
                    font.weight: Font.Light
                    font.pixelSize: 18
                    lineHeight: 1.4
                }

                RoundedButton {
                    id: print_again_button
                    buttonWidth: 290
                    buttonHeight: 50
                    label: qsTr("RETRY TEST PRINT")
                    visible: {
                        if(inFreStep) {
                            bot.process.stateType == ProcessStateType.Completed ||
                             bot.process.stateType == ProcessStateType.Failed
                        }
                        else {
                            false
                        }
                    }
                    button_mouseArea.onClicked: {
                        if(!disable_button) {
                            printAgain = true
                            printPage.getPrintTimes(printPage.lastPrintTimeSec)
                            printPage.printSwipeView.swipeToItem(PrintPage.StartPrintConfirm)
                        }
                    }
                }

                AcknowledgePrintFinished {
                    id: acknowledgePrintFinished
                    visible: bot.process.stateType == ProcessStateType.Completed ||
                             bot.process.stateType == ProcessStateType.Failed ||
                             bot.process.stateType == ProcessStateType.Cancelled
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
                    font.family: defaultFont.name
                    font.weight: Font.Bold
                    font.pixelSize: 20
                    Layout.preferredWidth: parent.width
                    elide: Text.ElideMiddle
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
                            text: qsTr("INFILL")
                            antialiasing: false
                            smooth: false
                            font.wordSpacing: 2
                            font.family: defaultFont.name
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                            visible: false
                        }

                        Text {
                            id: supports_label
                            color: "#cbcbcb"
                            text: qsTr("SUPPORTS")
                            antialiasing: false
                            smooth: false
                            font.wordSpacing: 2
                            font.family: defaultFont.name
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                            visible: false
                        }

                        Text {
                            id: rafts_label
                            color: "#cbcbcb"
                            text: qsTr("RAFTS")
                            antialiasing: false
                            smooth: false
                            font.wordSpacing: 2
                            font.family: defaultFont.name
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                            visible: false
                        }

                        Text {
                            id: model_label
                            color: "#cbcbcb"
                            text: qsTr("MODEL")
                            antialiasing: false
                            smooth: false
                            font.wordSpacing: 2
                            font.family: defaultFont.name
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                        }

                        Text {
                            id: support_label
                            color: "#cbcbcb"
                            text: qsTr("SUPPORT")
                            antialiasing: false
                            smooth: false
                            font.wordSpacing: 2
                            font.family: defaultFont.name
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.pixelSize: 18
                            visible: support_extruder_used_
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
                            text: qsTr("99.99%")
                            antialiasing: false
                            smooth: false
                            font.family: defaultFont.name
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                            visible: false
                        }

                        Text {
                            id: supports_text
                            color: "#ffffff"
                            text: uses_support_
                            antialiasing: false
                            smooth: false
                            font.family: defaultFont.name
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                            visible: false
                        }

                        Text {
                            id: rafts_text
                            color: "#ffffff"
                            text: uses_raft_
                            antialiasing: false
                            smooth: false
                            font.family: defaultFont.name
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                            visible: false
                        }

                        Text {
                            id: model_text
                            color: "#ffffff"
                            text: qsTr("%1 %2").arg(model_mass_).arg(print_model_material_)
                            antialiasing: false
                            smooth: false
                            font.family: defaultFont.name
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                            font.capitalization: Font.AllUppercase
                        }

                        Text {
                            id: support_text
                            color: "#ffffff"
                            text: qsTr("%1 %2").arg(support_mass_).arg(print_support_material_)
                            antialiasing: false
                            smooth: false
                            font.family: defaultFont.name
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            font.pixelSize: 18
                            font.capitalization: Font.AllUppercase
                            visible: support_extruder_used_
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
                    text: qsTr("%1 INFO").arg(printerName)
                    antialiasing: false
                    smooth: false
                    font.family: defaultFont.name
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
                    id: row_extruder_info
                    width: 100
                    height: 100
                    smooth: false
                    spacing: 35

                    ColumnLayout {
                        id: column_labels_1
                        width: 100
                        height: 100
                        smooth: false
                        spacing: 10

                        Text {
                            id: extruder1_temp_label
                            color: "#cbcbcb"
                            text: qsTr("EX 1 TEMP")
                            antialiasing: false
                            smooth: false
                            font.family: defaultFont.name
                            font.pixelSize: 18
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.wordSpacing: 2
                        }

                        Text {
                            id: extruder2_temp_label
                            color: "#cbcbcb"
                            text: qsTr("EX 2 TEMP")
                            antialiasing: false
                            smooth: false
                            font.family: defaultFont.name
                            font.pixelSize: 18
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.wordSpacing: 2
                        }

                        Text {
                            id: extruder1_life_label
                            color: "#cbcbcb"
                            text: qsTr("EX 1 LIFE")
                            antialiasing: false
                            smooth: false
                            font.family: defaultFont.name
                            font.pixelSize: 18
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.wordSpacing: 2
                        }

                        Text {
                            id: extruder2_life_label
                            color: "#cbcbcb"
                            text: qsTr("EX 2 LIFE")
                            antialiasing: false
                            smooth: false
                            font.pixelSize: 18
                            font.family: defaultFont.name
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.wordSpacing: 2
                        }
                    }

                    ColumnLayout {
                        id: column_text_1
                        width: 100
                        height: 100
                        smooth: false
                        spacing: 10

                        Text {
                            id: extruder1_temp_text
                            color: "#ffffff"
                            text: qsTr("%1C").arg(bot.extruderACurrentTemp)
                            antialiasing: false
                            smooth: false
                            font.family: defaultFont.name
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                        }

                        Text {
                            id: extruder2_temp_text
                            color: "#ffffff"
                            text: qsTr("%1C").arg(bot.extruderBCurrentTemp)
                            antialiasing: false
                            smooth: false
                            font.family: defaultFont.name
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                        }

                        Text {
                            id: extruder1_life_text
                            color: "#ffffff"
                            text: qsTr("%1mm").arg(extruderAExtrusionDistance)
                            antialiasing: false
                            smooth: false
                            font.family: defaultFont.name
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                        }

                        Text {
                            id: extruder2_life_text
                            color: "#ffffff"
                            text: qsTr("%1mm").arg(extruderBExtrusionDistance)
                            antialiasing: false
                            smooth: false
                            font.family: defaultFont.name
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                        }
                    }
                }
                // Add some space here for Magma, due to addition
                // of hbp temp in the info
                Item {
                    id: divider_item3
                    width: 200
                    height: 5
                    smooth: false
                    visible: bot.machineType == MachineType.Magma
                }

                RowLayout {
                    id: row_buildplane_info
                    width: 100
                    height: 100
                    smooth: false
                    spacing: 18

                    ColumnLayout {
                        id: column_labels_2
                        width: 100
                        height: 100
                        smooth: false
                        spacing: 10

                        Text {
                            id: buildplane_temp_label
                            color: "#cbcbcb"
                            text: qsTr("CHAMBER TEMP. (BUILD PLANE)")
                            antialiasing: false
                            smooth: false
                            font.pixelSize: 16
                            font.family: defaultFont.name
                            font.weight: Font.Light
                            font.letterSpacing: 1
                        }

                        Text {
                            id: hbp_temp_label
                            color: "#cbcbcb"
                            text: qsTr("HEATED BP TEMP")
                            antialiasing: false
                            smooth: false
                            font.pixelSize: 18
                            font.family: defaultFont.name
                            font.weight: Font.Light
                            font.letterSpacing: 3
                            font.wordSpacing: 2
                            visible: bot.machineType == MachineType.Magma
                        }
                    }

                    ColumnLayout {
                        id: column_text_2
                        width: 100
                        height: 100
                        smooth: false
                        spacing: 10

                        Text {
                            id: buildplane_temp_text
                            color: "#ffffff"
                            text: qsTr("%1C").arg(bot.buildplaneCurrentTemp)
                            antialiasing: false
                            smooth: false
                            font.family: defaultFont.name
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                        }

                        Text {
                            id: hbp_temp_text
                            color: "#ffffff"
                            text: qsTr("%1C").arg(bot.hbpCurrentTemp)
                            antialiasing: false
                            smooth: false
                            font.family: defaultFont.name
                            font.pixelSize: 18
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            visible: bot.machineType == MachineType.Magma
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
                    horizontalAlignment: Text.AlignHCenter
                    antialiasing: false
                    smooth: false
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: defaultFont.name
                    font.pixelSize: 15
                    font.weight: Font.Light
                    font.letterSpacing: 3
                    Layout.preferredWidth: page3.width - 80
                    elide: Text.ElideMiddle
                }

                Text {
                    id: end_time_text
                    color: "#ffffff"
                    text: doneByTimeString
                    horizontalAlignment: Text.AlignHCenter
                    antialiasing: false
                    smooth: false
                    font.pixelSize: 145
                    font.family: defaultFont.name
                    font.weight: Font.Light
                    font.letterSpacing: 3
                    Layout.preferredWidth: page3.width - 80
                    elide: Text.ElideMiddle
                }

                Text {
                    id: printer_name_is_printing_text
                    color: "#cbcbcb"
                    text: qsTr("%1 IS PRINTING").arg(printerName)
                    horizontalAlignment: Text.AlignHCenter
                    antialiasing: false
                    smooth: false
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: defaultFont.name
                    font.pixelSize: 15
                    font.weight: Font.Light
                    font.letterSpacing: 3
                    Layout.preferredWidth: page3.width - 80
                    elide: Text.ElideMiddle
                }

                Text {
                    id: fileName_text3
                    color: "#ffffff"
                    text: fileName_
                    horizontalAlignment: Text.AlignHCenter
                    antialiasing: false
                    smooth: false
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    font.family: defaultFont.name
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    font.letterSpacing: 3
                    Layout.preferredWidth: page3.width - 80
                    elide: Text.ElideMiddle
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
                    font.family: defaultFont.name
                    font.weight: Font.Bold
                    font.letterSpacing: 0

                    Text {
                        id: is_printing_label
                        color: "#cbcbcb"
                        text: qsTr("IS PRINTING")
                        antialiasing: false
                        smooth: false
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: -30
                        font.pixelSize: 16
                        font.family: defaultFont.name
                        font.weight: Font.Light
                        font.letterSpacing: 3

                        Text {
                            id: filename_text4
                            color: "#ffffff"
                            text: fileName_
                            antialiasing: false
                            smooth: false
                            anchors.left: parent.right
                            anchors.leftMargin: 10
                            font.pixelSize: 16
                            font.family: defaultFont.name
                            font.weight: Font.Bold
                            font.letterSpacing: 3
                            width: page4.width - 200
                            elide: Text.ElideMiddle
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
                            font.family: defaultFont.name
                            font.weight: Font.Light
                            font.letterSpacing: 3

                            Text {
                                id: end_time_text4
                                color: "#ffffff"
                                text: doneByTimeString
                                antialiasing: false
                                smooth: false
                                anchors.left: parent.right
                                anchors.leftMargin: 10
                                font.pixelSize: 16
                                font.family: defaultFont.name
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
