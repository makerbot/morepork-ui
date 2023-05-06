import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import ProcessStateTypeEnum 1.0
import MachineTypeEnum 1.0

LoggingItem {
    id: printStatusPage
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
            doneByDayString = qsTr("%1 DAYS").arg(daysLeft)
        } else if (daysLeft === 1) {
            doneByDayString = qsTr("TOMORROW")
        } else {
            doneByDayString = qsTr("TODAY")
        }

        doneByTimeString = endTime.toLocaleTimeString(Qt.locale(),"hh:mm")
    }

    enum SwipeIndex {
        Page0,
        Page1,
        Page2,
        Page3
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

            ColumnLayout {
                height: parent.height
                width: parent.width/2
                anchors.left: parent.left

                PrintIcon {
                    id: printIcon
                    showActionButtons: {
                        bot.process.stateType != ProcessStateType.Cancelled &&
                        bot.process.stateType != ProcessStateType.Completed &&
                        bot.process.stateType != ProcessStateType.Failed
                    }
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                }
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
                    acknowledgePrintFinished.state == "print_successful_feedback_reported" ||
                       acknowledgePrintFinished.state == "print_failed" ?
                        50 : 0
                }
                spacing: {
                    bot.process.stateType == ProcessStateType.Cancelled ?
                        -10 : 20
                }
                TextHeadline {
                    id: status_text0
                    style: TextHeadline.Large
                    text: {
                        switch(bot.process.stateType) {
                        case ProcessStateType.Loading:
                            (bot.process.stepStr == "waiting_for_file" || bot.process.stepStr == "transfer") ?
                                qsTr("GETTING READY") : qsTr("HEATING")
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
                            qsTr("COMPLETED")
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
                            (bot.process.complete) ? qsTr("FINISHING UP") : qsTr("CANCELLING")
                            break;
                        default:
                            ""
                            break;
                        }
                    }
                    Layout.preferredWidth: parent.width - 40
                }

                TextBody {
                    id: subtext0
                    style: TextBody.Base
                    opacity: 0.7
                    visible: !(bot.process.stateType == ProcessStateType.Loading && !(bot.process.stepStr == "waiting_for_file" || bot.process.stepStr == "transfer"))
                    text: {
                        switch(bot.process.stateType) {
                        case ProcessStateType.Loading:
                            if(bot.process.stepStr == "waiting_for_file") {
                                qsTr("WAITING FOR PRINT FILE")
                            } else if(bot.process.stepStr == "transfer") {
                                qsTr("TRANSFERRING PRINT FILE")
                            }
                            break;
                        case ProcessStateType.Printing:
                            fileName_
                            break;
                        case ProcessStateType.Pausing:
                        case ProcessStateType.Resuming:
                        case ProcessStateType.Paused:
                            fileName_
                            break;
                        case ProcessStateType.Completed:
                            fileName_
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
                    Layout.preferredWidth: parent.width - 40
                    horizontalAlignment: Text.AlignTop
                    elide: Text.ElideRight
                }

                TextHeadline{
                    id: minutes_remaining_printing_paused
                    visible: (bot.process.stateType == ProcessStateType.Paused || bot.process.stateType == ProcessStateType.Printing)
                    style: TextHeadline.Large

                    text: qsTr("%1").arg(timeLeftString)
                }

                TextBody {
                    id: subtext1
                    style: TextBody.Base
                    opacity: 0.7
                    visible: !(bot.process.stateType == ProcessStateType.Loading && !(bot.process.stepStr == "waiting_for_file" || bot.process.stepStr == "transfer"))
                    text: {
                        switch(bot.process.stateType) {
                        case ProcessStateType.Loading:
                            if(bot.process.stepStr == "waiting_for_file") {
                                ""
                            } else if(bot.process.stepStr == "transfer") {
                                bot.process.printPercentage + "%"
                            }
                            break;
                        case ProcessStateType.Printing:
                        case ProcessStateType.Pausing:
                        case ProcessStateType.Resuming:
                        case ProcessStateType.Paused:
                            timeLeftString == "0M" ?
                                        qsTr("FINISHING UP") :
                                        qsTr("Remaining")
                            break;
                        case ProcessStateType.Failed:
                            qsTr("%1 Print Time").arg(print_time_)
                            break;
                        case ProcessStateType.Completed:
                            qsTr("%1 Print Time").arg(print_time_)
                            break;
                        default:
                            emptyString
                            break;
                        }
                    }
                }

                TemperatureStatus {
                    visible: bot.process.stateType == ProcessStateType.Loading &&
                             bot.process.stepStr != "waiting_for_file" &&
                             bot.process.stepStr != "transfer"
                    showComponent: {
                        if(bot.process.stepStr == "heating_chamber") {
                            TemperatureStatus.Chamber
                        } else if(bot.process.stepStr == "heating_build_platform") {
                            TemperatureStatus.HeatedBuildPlate
                        } else if(bot.extruderATargetTemp > 0) {
                            TemperatureStatus.BothExtruders
                        } else {
                            TemperatureStatus.Chamber
                        }
                    }
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

            PrintModelInfoPage {
                anchors.fill: parent.fill
                startPrintButtonVisible: false
                customModelSource: "image://thumbnail/" + filePathName
            }
        }

        Item {
            id: page2

            PrintFileInfoPage {

            }
        }

        Item {
            id: page3

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 50
                anchors.topMargin: 15
                spacing: -55

                TextHeadline{
                    id: name_printer
                    text: printerName
                    style: TextHeadline.ExtraLarge
                    font.weight: Font.Light
                }

                ColumnLayout {
                    spacing: 15

                    TextBody {
                        id: done_by
                        text: qsTr("DONE BY")
                        font.weight: Font.Light
                        opacity: 0.8
                    }

                    TextHeadline {
                        id: day
                        text: doneByDayString
                        style: TextHeadline.ExtraLarge
                        font.weight: Font.Light
                    }

                    TextHeadline {
                        id: time
                        text: doneByTimeString
                        style: TextHeadline.ExtraLarge
                        font.weight: Font.Light
                    }

                    TextBody {
                        id: filename_header
                        text: qsTr("FILENAME")
                        font.weight: Font.Light
                        opacity: 0.8
                    }

                    TextBody {
                        id: printjob_name
                        text: fileName_
                        font.capitalization: Font.AllUppercase
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
